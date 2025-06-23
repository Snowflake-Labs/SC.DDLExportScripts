#!/bin/bash

# Get all changed files (staged for commit) that are .sh or .sql
CHANGED_FILES=$(git diff --cached --name-only | grep -E "\.sh$|\.sql$" | grep -v "^\.github/" || true)

# Check if VERSION file is modified
VERSION_MODIFIED=$(git diff --cached --name-only | grep -c "^VERSION$" || true)

# If there are .sh or .sql files modified outside .github/ but VERSION is not modified
if [ -n "$CHANGED_FILES" ] && [ "$VERSION_MODIFIED" -eq 0 ]; then
  echo "⚠️ WARNING: You have modified .sh or .sql files, but the VERSION file has not been updated."
  echo "⚠️ Please update the VERSION file and run the VERSION-UPDATE.sh script to propagate the version."
  echo "⚠️ Changed files:"
  echo "$CHANGED_FILES"
  echo ""
  echo "⚠️ You can still commit with --no-verify if this is intentional."
  exit 1
fi

exit 0
