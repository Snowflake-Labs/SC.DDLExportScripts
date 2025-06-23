#!/bin/bash

set -e

display_banner() {
  echo "==============================================="
  echo "  Update Version in README Files"
  echo "==============================================="
}

find_repo_root() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  REPO_ROOT="$( cd "$SCRIPT_DIR/../../" && pwd )"
  
  if [ ! -f "$REPO_ROOT/VERSION" ]; then
    echo "ERROR: VERSION file not found at $REPO_ROOT/VERSION!"
    echo "This script needs to be in the .github/scripts directory of the repository."
    exit 1
  fi
  
  cd "$REPO_ROOT"
  echo "Working from repository root: $REPO_ROOT"
}

extract_version() {
  VERSION=$(grep '__version__' VERSION | sed 's/.*"\(.*\)".*/\1/')
  
  if [ -z "$VERSION" ]; then
    echo "ERROR: Could not extract version from VERSION file!"
    exit 1
  fi
  
  echo "Extracted version: $VERSION"
  echo "Updating version to: $VERSION"
}

find_readme_files() {
  README_FILES=$(find . -name "README.md" -type f -exec grep -l "^## Version" {} \; 2>/dev/null || true)
  
  if [ -z "$README_FILES" ]; then
    echo "No README.md files with '## Version' section found."
    exit 0
  fi
  
  echo "Found README.md files with '## Version' section:"
  for file in $README_FILES; do
    if file "$file" | grep -q "CRLF"; then
      echo "- $file (Windows CRLF line endings)"
    else
      echo "- $file (Unix LF line endings)"
    fi
  done
}

update_version_in_files() {
  UPDATED_FILES=""
  CHANGES_MADE=false
  SUMMARY=""
  
  for file in $README_FILES; do
    echo "Processing file: $file"
    
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
      echo "Warning: Cannot access file $file - skipping"
      continue
    fi
    
    if file "$file" | grep -q "CRLF"; then
      echo "File uses Windows CRLF line endings"
      HAS_CRLF=true
    else
      echo "File uses Unix LF line endings"
      HAS_CRLF=false
    fi
    
    CURRENT_VERSION=$(grep -A1 "^## Version" "$file" | tail -n1 | tr -d '\r' | xargs)
    
    TEMP_FILE=$(mktemp)
    
    if [ "$HAS_CRLF" = true ]; then
      line_after_version=false
      while IFS= read -r line || [ -n "$line" ]; do
        clean_line=$(echo "$line" | tr -d '\r')
        if $line_after_version; then
          echo -ne "$VERSION\r\n" >> "$TEMP_FILE"
          line_after_version=false
        else
          echo -ne "$line\r\n" >> "$TEMP_FILE"
          if [[ "$clean_line" == "## Version" ]]; then
            line_after_version=true
          fi
        fi
      done < "$file"
    else
      line_after_version=false
      while IFS= read -r line; do
        if $line_after_version; then
          echo "$VERSION" >> "$TEMP_FILE"
          line_after_version=false
        else
          echo "$line" >> "$TEMP_FILE"
          if [[ "$line" == "## Version" ]]; then
            line_after_version=true
          fi
        fi
      done < "$file"
    fi
    
    mv "$TEMP_FILE" "$file"
    
    NEW_VERSION=$(grep -A1 "^## Version" "$file" | tail -n1 | tr -d '\r' | xargs)
    if [ "$NEW_VERSION" = "$VERSION" ] && [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
      echo "Updated $file: changed '$CURRENT_VERSION' to '$VERSION'"
      UPDATED_FILES="$UPDATED_FILES $file"
      SUMMARY="$SUMMARY\n- Updated $file: '$CURRENT_VERSION' → '$VERSION'"
      CHANGES_MADE=true
    else
      echo "No change needed in $file (already at version $VERSION)"
      SUMMARY="$SUMMARY\n- No change needed in $file (already at version $VERSION)"
    fi
  done
}

commit_and_push_changes() {
  if [ "$CHANGES_MADE" = "true" ]; then
    echo -e "\n✅ Changes made to files:"
    echo -e "$SUMMARY"
    
    read -p "Do you want to commit these changes? (y/N): " COMMIT
    if [[ "$COMMIT" =~ ^[Yy]$ ]]; then
      git config --local user.email "$(git config user.email || echo "script@local")"
      git config --local user.name "$(git config user.name || echo "Version Update Script")"
      
      for file in $UPDATED_FILES; do
        git add "$file"
      done
      
      git commit -m "Update version to $VERSION in README files [skip ci]"
      
      read -p "Do you want to push these changes? (y/N): " PUSH
      if [[ "$PUSH" =~ ^[Yy]$ ]]; then
        git push
        echo "Changes pushed successfully!"
      else
        echo "Changes committed but not pushed. Use 'git push' to push when ready."
      fi
    else
      echo "Changes were made to files but not committed."
    fi
  else
    echo -e "\n✅ No changes were needed. All files are already at version $VERSION."
  fi
}

verify_version_in_files() {
  echo -e "\nVerifying version in README.md files..."
  
  MISMATCHED_FILES=""
  MISMATCH_FOUND=false
  
  for file in $(find . -name "README.md" -type f -exec grep -l "^## Version" {} \; 2>/dev/null || true); do
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
      continue
    fi
    
    FILE_VERSION=$(grep -A1 "^## Version" "$file" | tail -n1 | tr -d '\r' | xargs)
    
    if [ "$FILE_VERSION" != "$VERSION" ]; then
      echo "❌ Version mismatch in $file: found '$FILE_VERSION', expected '$VERSION'"
      MISMATCHED_FILES="$MISMATCHED_FILES\n- $file: found '$FILE_VERSION', expected '$VERSION'"
      MISMATCH_FOUND=true
    else
      echo "✅ Version match in $file: '$VERSION'"
    fi
  done
  
  if [ "$MISMATCH_FOUND" = "true" ]; then
    echo -e "\n⚠️ WARNING: Some files have mismatched versions:"
    echo -e "$MISMATCHED_FILES"
    echo "Please run the script again to fix these issues."
    return 1
  else
    echo -e "\n✅ All README.md files have the correct version: $VERSION"
    return 0
  fi
}

display_completion() {
  echo -e "\n==============================================="
  echo "  Version update process completed!"
  echo "==============================================="
}

main() {
  display_banner
  find_repo_root
  extract_version
  find_readme_files
  update_version_in_files
  #commit_and_push_changes
  verify_version_in_files
  display_completion
}

main
