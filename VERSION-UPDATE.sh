#!/bin/bash

set -e

find_repo_root() {
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ ! -f "$REPO_ROOT/VERSION" ]; then
    echo "ERROR: VERSION file not found. This script must be executed from the repository root."
    exit 1
  fi
}

extract_version() {
  VERSION=$(grep '__version__' "$REPO_ROOT/VERSION" | sed 's/.*"\(.*\)".*/\1/')

  if [ -z "$VERSION" ]; then
    echo "ERROR: Could not extract version from VERSION file."
    exit 1
  fi

  echo "Extracted version: $VERSION"
}

verify_normalize_script() {
  NORMALIZE_SCRIPT="$REPO_ROOT/.github/scripts/common-normalize-version.sh"

  if [ ! -f "$NORMALIZE_SCRIPT" ]; then
    echo "ERROR: common-normalize-version.sh script not found at $NORMALIZE_SCRIPT."
    exit 1
  fi
}

execute_normalize_script() {
  echo "Executing common-normalize-version.sh..."
  "$NORMALIZE_SCRIPT"
}

update_powershell_scripts() {
  echo "Updating version in PowerShell scripts..."

  find "$REPO_ROOT" -name "*.ps1" -type f -print0 | while IFS= read -r -d '' PS_FILE; do
    echo "Checking $PS_FILE..."

    cp "$PS_FILE" "$PS_FILE.bak"

    # Primary: replace $VERSION or $version assignments preserving variable and spacing
    perl -i -pe "s/^(\s*\\\$[Vv][Ee][Rr][Ss][Ii][Oo][Nn]\s*=\s*)['\\\"][^'\\\"]*['\\\"]/\$1\"${VERSION}\"/m" "$PS_FILE"

    # Fallback: if unchanged, normalize any line starting with a 'version' variable-like token
    if diff -q "$PS_FILE" "$PS_FILE.bak" >/dev/null; then
      perl -i -pe "s/^\s*\\\$?[Vv][Ee][Rr][Ss][Ii][Oo][Nn][^\r\n]*$/\\\$VERSION = \"${VERSION}\"/m" "$PS_FILE"
    fi

    rm -f "$PS_FILE.bak"

    if grep -qE "^[[:space:]]*\\$[Vv][Ee][Rr][Ss][Ii][Oo][Nn][[:space:]]*=[[:space:]]*\"${VERSION}\"" "$PS_FILE"; then
      echo "  Successfully updated $PS_FILE to version $VERSION"
    else
      echo "  Failed to update version in $PS_FILE"
    fi
  done
}

update_bash_scripts() {
  echo "Updating version in Bash scripts..."

  find "$REPO_ROOT" -name "*.sh" -type f -print0 | while IFS= read -r -d '' BASH_FILE; do
    echo "Checking $BASH_FILE..."

    case "$BASH_FILE" in
      *"VERSION-UPDATE.sh")
        echo "  Skipping $BASH_FILE (this script)"
        continue
        ;;
    esac

    if grep -q "VERSION=[\"'][^\"']*[\"']" "$BASH_FILE"; then
      echo "  Found hardcoded version in $BASH_FILE, updating..."

      cp "$BASH_FILE" "$BASH_FILE.bak"

      sed -i '' "s/VERSION=[\"'][^\"']*[\"']/VERSION=\"${VERSION}\"/" "$BASH_FILE"

      if diff -q "$BASH_FILE" "$BASH_FILE.bak" >/dev/null; then
        echo "  Warning: Version not updated in $BASH_FILE. Trying alternative method..."
        perl -i -pe "s/VERSION=[\"'][^\"']*[\"']/VERSION=\"${VERSION}\"/" "$BASH_FILE"
      fi

      rm -f "$BASH_FILE.bak"

      if grep -q "VERSION=[\"']${VERSION}[\"']" "$BASH_FILE"; then
        echo "  Successfully updated $BASH_FILE to version $VERSION"
      else
        echo "  Failed to update version in $BASH_FILE"
      fi
    fi
  done
}

update_batch_scripts() {
  echo "Updating version in Batch (.bat) scripts..."

  find "$REPO_ROOT" -name "*.bat" -type f -print0 | while IFS= read -r -d '' BAT_FILE; do
    echo "Checking $BAT_FILE..."
    cp "$BAT_FILE" "$BAT_FILE.bak"
    # Normalize various SET forms to SET VERSION=<VERSION>
    sed -i '' -E "s/^[[:space:]]*[Ss][Ee][Tt][[:space:]]+VERSION[[:space:]]*=.*/SET VERSION=${VERSION}/" "$BAT_FILE" || true
    sed -i '' -E "s/^[[:space:]]*[Ss][Ee][Tt][[:space:]]+\"VERSION=[^\"]*\"/SET VERSION=${VERSION}/" "$BAT_FILE" || true
    if diff -q "$BAT_FILE" "$BAT_FILE.bak" >/dev/null; then
      echo "  Warning: Version not updated in $BAT_FILE. Trying alternative method..."
      perl -i -pe "s/^(\s*[Ss][Ee][Tt]\s+)(\"?)VERSION\2\s*=\s*(\"?)[^\r\n]*\3/\$1VERSION=${VERSION}/" "$BAT_FILE"
    fi
    rm -f "$BAT_FILE.bak"
    if grep -qi "^SET[[:space:]]\+VERSION[[:space:]]*=${VERSION}" "$BAT_FILE"; then
      echo "  Successfully updated $BAT_FILE to version $VERSION"
    else
      echo "  Failed to update version in $BAT_FILE"
    fi
  done
}

update_python_scripts() {
  echo "Updating version in Python scripts..."

  find "$REPO_ROOT" -name "*.py" -type f -print0 | while IFS= read -r -d '' PY_FILE; do
    echo "Checking $PY_FILE..."

    if grep -qE "^[[:space:]]*(VERSION|__version__)[[:space:]]*=[[:space:]]*['\\\"][^'\\\"]*['\\\"]" "$PY_FILE"; then
      echo "  Found hardcoded version in $PY_FILE, updating..."

      cp "$PY_FILE" "$PY_FILE.bak"

      sed -i '' -E \
        -e "s/^([[:space:]]*VERSION[[:space:]]*=[[:space:]]*)['\\\"][^'\\\"]*['\\\"]/\\1\"${VERSION}\"/" \
        -e "s/^([[:space:]]*__version__[[:space:]]*=[[:space:]]*)['\\\"][^'\\\"]*['\\\"]/\\1\"${VERSION}\"/" \
        "$PY_FILE"

      rm -f "$PY_FILE.bak"

      if grep -qE "^[[:space:]]*(VERSION|__version__)[[:space:]]*=[[:space:]]*\"${VERSION}\"" "$PY_FILE"; then
        echo "  Successfully updated $PY_FILE to version $VERSION"
      else
        echo "  Failed to update version in $PY_FILE"
      fi
    fi
  done
}

main() {
  find_repo_root
  extract_version
  verify_normalize_script
  execute_normalize_script
  update_powershell_scripts
  update_bash_scripts
  update_batch_scripts
  update_python_scripts
}

main
exit $?
