#!/bin/bash

# This script is executed after cloning the repository to provide important setup instructions.
echo "==============================================="
echo "  SC.DDLExportScripts Repository Setup"
echo "==============================================="
echo ""
echo "Welcome to the SC.DDLExportScripts repository!"
echo ""
if [ -f ".git/hooks/post-checkout" ] && [ -f ".git/hooks/post-merge" ]; then
    echo "✅ Git hooks are already installed!"
    echo "The repository is properly configured for version management."
else
    echo "⚠️  IMPORTANT: Please run './.github/scripts/install-hooks.sh' to set up Git hooks"
    echo "This ensures proper version management in the repository."
    echo ""
    echo "Running without hooks may lead to inconsistent versioning!"
fi

echo ""
echo "You can now start working with the DDL export scripts."
echo "==============================================="
