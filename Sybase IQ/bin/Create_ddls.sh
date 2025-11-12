#!/usr/bin/env bash

set -euo pipefail

VERSION="0.1.1"

usage() {
    echo "Usage: $0 -c <ConnectionString> -o <OutputPath> -i <IqunloadPath>"
    echo
    echo "  -c, --connection-string    Sybase IQ connection string (e.g. 'DBN=mydb;UID=user;PWD=pass;...')"
    echo "  -o, --output-path          Directory to write extracted files"
    echo "  -i, --iqunload-path        Path to iqunload executable (or .bat on Windows via WSL)"
    echo "  -h, --help                 Show this help message"
}

# -----------------------------
# Parse arguments
# -----------------------------
connection_string=""
output_path=""
iqunload_path=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--connection-string)
            connection_string="${2:-}"; shift 2 ;;
        -o|--output-path)
            output_path="${2:-}"; shift 2 ;;
        -i|--iqunload-path)
            iqunload_path="${2:-}"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            echo "Unknown argument: $1" >&2
            usage; exit 1 ;;
    esac
done

if [[ -z "${connection_string}" || -z "${output_path}" || -z "${iqunload_path}" ]]; then
    echo "Missing required arguments." >&2
    usage
    exit 1
fi

if [[ ! -x "${iqunload_path}" && ! -f "${iqunload_path}" ]]; then
    echo "iqunload not found: ${iqunload_path}" >&2
    exit 1
fi

mkdir -p "${output_path}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------
# Helpers
# -----------------------------
trim() {
    # Trim leading/trailing whitespace
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf "%s" "$s"
}

safe_name() {
    # Replace filesystem-unsafe chars with underscore
    echo "$1" | sed -E 's/[<>:"\/\\|?*]/_/g'
}

# Store connection string key/values as lines "key=value" (lowercased keys)
conn_map_lines=""
IFS=';' read -r -a _conn_parts <<< "${connection_string}"
for part in "${_conn_parts[@]}"; do
    part="$(trim "$part")"
    [[ -z "$part" ]] && continue
    if [[ "$part" == *"="* ]]; then
        local_key="$(trim "${part%%=*}")"
        local_val="$(trim "${part#*=}")"
        # Strip surrounding quotes
        local_val="$(echo "$local_val" | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/")"
        local_key="$(echo "$local_key" | tr '[:upper:]' '[:lower:]')"
        conn_map_lines+="${local_key}=${local_val}"$'\n'
    fi
done
unset _conn_parts

conn_get() {
    # Print value for a given lowercased key (first match)
    local key="$1"
    printf "%s" "$conn_map_lines" | awk -F'=' -v k="$key" 'tolower($1)==k { $1=""; sub("^=",""); print; exit }'
}

# Determine database name
db_name=""
for k in dbn database db dbname "initial catalog"; do
    v="$(conn_get "$k" || true)"
    if [[ -n "$v" ]]; then
        db_name="$v"
        break
    fi
done
if [[ -z "$db_name" ]]; then
    dbf_val="$(conn_get "dbf" || true)"
    if [[ -n "$dbf_val" ]]; then
        base="$(basename "$dbf_val")"
        db_name="${base%.*}"
    fi
fi
if [[ -z "$db_name" ]]; then
    db_name="database"
fi

safe_db_name="$(safe_name "$db_name")"
output_file="${output_path}/${safe_db_name}.sql"

# -----------------------------
# Run iqunload to export DDL
# -----------------------------
"${iqunload_path}" -c "${connection_string}" -n -r "${output_file}"

# -----------------------------
# Prepare for splitting
# -----------------------------
input_sql="${output_file}"
if [[ ! -f "${input_sql}" ]]; then
    input_sql="${script_dir}/script.sql"
fi
if [[ ! -f "${input_sql}" ]]; then
    echo "Input SQL not found: ${input_sql}" >&2
    exit 1
fi

split_root="${output_path}"
mkdir -p "${split_root}"
echo "Splitting SQL file: ${input_sql}"
echo "Output split root: ${split_root}"

# Metadata file
sc_file="${split_root}/.sc_extraction"
tz="$(date +%z)"; tz_colon="${tz:0:3}:${tz:3:2}"
extracted_on="$(date +%Y-%m-%dT%H:%M:%S)${tz_colon}"
{
    printf "script_version=%s\n" "${VERSION}"
    printf "extracted_on=%s\n" "${extracted_on}"
    printf "source_engine=SybaseIQ\n"
    printf "database_name=%s\n" "${db_name}"
} > "${sc_file}"
echo "Generated metadata file: ${sc_file}"
echo "Extraction summary: version ${VERSION}, database ${db_name}"

write_statement_to_object_file() {
    local schema="$1"
    local type_dir="$2"
    local object_name="$3"
    local statement="$4"

    local schema_safe; schema_safe="$(safe_name "$schema")"
    local object_safe; object_safe="$(safe_name "$object_name")"
    local target_dir="${split_root}/${schema_safe}/${type_dir}"
    mkdir -p "${target_dir}"
    local target_file="${target_dir}/${object_safe}.sql"

    local trimmed; trimmed="$(printf "%s" "$statement" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf "%s\ngo\n\n" "$trimmed" >> "${target_file}"
}

# -----------------------------
# Split statements by lines exactly 'go' (case-insensitive)
# -----------------------------
tmp_dir="${split_root}/.split_tmp"
mkdir -p "${tmp_dir}"

idx=0
_buf=""
_flush() {
    local content="$1"
    local trimmed; trimmed="$(printf "%s" "$content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if [[ -z "$trimmed" ]]; then
        return 0
    fi
    idx=$((idx+1))
    printf "%s\n" "$trimmed" > "${tmp_dir}/stmt_$(printf "%05d" "${idx}").sql"
}

while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ ^[[:space:]]*[Gg][Oo][[:space:]]*$ ]]; then
        _flush "${_buf}"
        _buf=""
    else
        if [[ -z "${_buf}" ]]; then
            _buf="${line}"
        else
            _buf+=$'\n'"${line}"
        fi
    fi
done < "${input_sql}"
_flush "${_buf}"
echo "Statements detected: ${idx}"

# -----------------------------
# Pass 1: discover created objects
# -----------------------------
known_file="${tmp_dir}/known.txt"
: > "${known_file}"

known_add() {
    local schema="$1"
    local type="$2"
    local name="$3"
    [[ -z "$schema" || -z "$type" || -z "$name" ]] && return 0
    echo "${schema}|${type}|${name}" >> "${known_file}"
}

resolve_type_for_object() {
    local schema="$1"
    local name="$2"
    for t in Tables Views Procedures Functions Sequences Triggers; do
        if grep -qxF "${schema}|${t}|${name}" "${known_file}" 2>/dev/null; then
            echo "${t}"
            return 0
        fi
    done
    return 1
}

shopt -s nocasematch
for f in "${tmp_dir}"/stmt_*.sql; do
    [[ -e "$f" ]] || break
    s="$(cat "$f")"
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+TABLE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Tables" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+VIEW[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Views" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+PROCEDURE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Procedures" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+FUNCTION[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Functions" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+SEQUENCE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Sequences" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+TRIGGER[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        known_add "${BASH_REMATCH[1]}" "Triggers" "${BASH_REMATCH[2]}"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+[[:alnum:]_]*[[:space:]]*INDEX[[:space:]]+\"([^\"]+)\"[[:space:]]+ON[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        # Track index as object under Indexes using table's schema for folder
        known_add "${BASH_REMATCH[2]}" "Indexes" "${BASH_REMATCH[1]}"
        continue
    fi
done

# -----------------------------
# Pass 2: route statements to files
# -----------------------------
for f in "${tmp_dir}"/stmt_*.sql; do
    [[ -e "$f" ]] || break
    s="$(cat "$f")"

    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+TABLE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Tables" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*COMMENT[[:space:]]+ON[[:space:]]+TABLE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        schema="${BASH_REMATCH[1]}"; name="${BASH_REMATCH[2]}"
        if ! type_dir="$(resolve_type_for_object "$schema" "$name")"; then type_dir="Tables"; fi
        write_statement_to_object_file "$schema" "$type_dir" "$name" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*ALTER[[:space:]]+TABLE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        schema="${BASH_REMATCH[1]}"; name="${BASH_REMATCH[2]}"
        if ! type_dir="$(resolve_type_for_object "$schema" "$name")"; then type_dir="Tables"; fi
        write_statement_to_object_file "$schema" "$type_dir" "$name" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*GRANT[[:space:]].*[[:space:]]ON[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        schema="${BASH_REMATCH[1]}"; name="${BASH_REMATCH[2]}"
        if ! type_dir="$(resolve_type_for_object "$schema" "$name")"; then type_dir="Grants"; fi
        write_statement_to_object_file "$schema" "$type_dir" "$name" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+VIEW[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Views" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:pace:]]*COMMENT[[:space:]]+ON[[:space:]]+VIEW[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Views" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+PROCEDURE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Procedures" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*COMMENT[[:space:]]+ON[[:space:]]+PROCEDURE[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Procedures" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+FUNCTION[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        write_statement_to_object_file "${BASH_REMATCH[1]}" "Functions" "${BASH_REMATCH[2]}" "$s"
        continue
    fi
    if [[ "$s" =~ ^[[:space:]]*CREATE[[:space:]]+[[:alnum:]_]*[[:space:]]*INDEX[[:space:]]+\"([^\"]+)\"[[:space:]]+ON[[:space:]]+\"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        index_name="${BASH_REMATCH[1]}"; schema="${BASH_REMATCH[2]}"
        write_statement_to_object_file "${schema}" "Indexes" "${index_name}" "$s"
        continue
    fi

    # Unclassified: drop into Schema/Misc/Misc.sql (or GLOBAL/Misc/Misc.sql)
    schema="GLOBAL"
    if [[ "$s" =~ \"([^\"]+)\"[[:space:]]*\.[[:space:]]*\"([^\"]+)\" ]]; then
        schema="${BASH_REMATCH[1]}"
    fi
    misc_dir="${split_root}/$(safe_name "$schema")/Misc"
    mkdir -p "${misc_dir}"
    misc_file="${misc_dir}/Misc.sql"
    trimmed_misc="$(printf "%s" "$s" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf "%s\ngo\n\n" "$trimmed_misc" >> "${misc_file}"
done
shopt -u nocasematch

# -----------------------------
# Cleanup
# -----------------------------
if [[ -f "${output_file}" ]]; then
    rm -f "${output_file}"
    echo "Removed consolidated file: ${output_file}"
fi
rm -rf "${tmp_dir}"


