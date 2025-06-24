#!/bin/bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing pre-commit hooks for the repository at $REPO_ROOT"

create_post_checkout_hook() {
  POST_CHECKOUT_HOOK="$REPO_ROOT/.git/hooks/post-checkout"
  
  if [ -f "$POST_CHECKOUT_HOOK" ]; then
    if grep -q "install-hooks.sh" "$POST_CHECKOUT_HOOK"; then
      return 0
    fi
    
    cp "$POST_CHECKOUT_HOOK" "$POST_CHECKOUT_HOOK.bak"
  fi
  
  cat > "$POST_CHECKOUT_HOOK" << 'EOF'
#!/bin/bash
"$(dirname "$(git rev-parse --git-dir)")/.github/scripts/post-clone-message.sh"
EOF
  
  chmod +x "$POST_CHECKOUT_HOOK"
  echo "Created post-checkout hook to remind about hook installation"
}

# Create a post-merge hook to run the install-hooks script after pull/merge
create_post_merge_hook() {
  POST_MERGE_HOOK="$REPO_ROOT/.git/hooks/post-merge"
  
  if [ -f "$POST_MERGE_HOOK" ]; then
    if grep -q "install-hooks.sh" "$POST_MERGE_HOOK"; then
      return 0
    fi
    
    cp "$POST_MERGE_HOOK" "$POST_MERGE_HOOK.bak"
  fi
  
  cat > "$POST_MERGE_HOOK" << 'EOF'
#!/bin/bash
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "install-hooks.sh\|.pre-commit-config.yaml"; then
  echo "Detected changes in hook configuration. Running install-hooks.sh..."
  "$(dirname "$(git rev-parse --git-dir)")/.github/scripts/install-hooks.sh"
fi
EOF
  
  chmod +x "$POST_MERGE_HOOK"
  echo "Created post-merge hook to auto-update hooks after pull/merge"
}

if ! command -v pre-commit &> /dev/null; then
  echo "Error: pre-commit is not installed."
  echo "Please install it using: pip install pre-commit"
  echo "or: brew install pre-commit"
  exit 1
fi

echo "Installing pre-commit hooks..."
pre-commit install

create_post_checkout_hook
create_post_merge_hook

echo "Installation completed successfully!"
echo "The VERSION-UPDATE check will now run every time you commit changes to .sh or .sql files."
echo ""
echo "Note: You can bypass this check with 'git commit --no-verify' if needed."
