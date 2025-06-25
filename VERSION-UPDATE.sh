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

  POWERSHELL_FILES=$(find "$REPO_ROOT" -name "*.ps1" -type f)

  for PS_FILE in $POWERSHELL_FILES; do
    echo "Checking $PS_FILE..."

    if grep -q "\$version = ['\\\"]\(v\)\?[0-9][0-9.]*['\\\"]\|^\$version = ['\\\"].*['\\\"]" "$PS_FILE"; then
      echo "  Found hardcoded version in $PS_FILE, updating..."

      cp "$PS_FILE" "$PS_FILE.bak"

      sed -i '' "s/\$version = ['\\\"]\(v\)\?[0-9][0-9.]*['\\\"]/\$version = '${VERSION}'/" "$PS_FILE"

      if diff -q "$PS_FILE" "$PS_FILE.bak" >/dev/null; then
        echo "  Warning: Version not updated in $PS_FILE. Trying alternative method..."
        perl -i -pe "s/\\\$version = ['\\\"](?:v)?[0-9][0-9.]*['\\\"]/\\\$version = '${VERSION}'/" "$PS_FILE"
      fi

      rm -f "$PS_FILE.bak"

      if grep -q "\$version = ['\\\"]\(v\)\?${VERSION}['\\\"]\|^\$version = ['\\\"]\(v\)\?${VERSION}['\\\"]\$" "$PS_FILE"; then
        echo "  Successfully updated $PS_FILE to version $VERSION"
      else
        echo "  Failed to update version in $PS_FILE"
      fi
    fi
  done
}

update_bash_scripts() {
  echo "Updating version in Bash scripts..."

  BASH_FILES=$(find "$REPO_ROOT" -name "*.sh" -type f)

  for BASH_FILE in $BASH_FILES; do
    echo "Checking $BASH_FILE..."

    if [[ "$BASH_FILE" == *"VERSION-UPDATE.sh" ]]; then
      echo "  Skipping $BASH_FILE (this script)"
      continue
    fi

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

main() {
  find_repo_root
  extract_version
  verify_normalize_script
  execute_normalize_script
  update_powershell_scripts
  update_bash_scripts
}

main
exit $?
