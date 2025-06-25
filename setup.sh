#!/bin/bash

# SC.DDLExportScripts Repository Setup Script
# Run this script after cloning the repository
# This script sets up the development environment for contributors

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
    echo "🔧 Setting up Git hooks..."
    echo ""
    
    if ! command -v pre-commit &> /dev/null; then
        echo "⚠️  pre-commit is not installed."
        echo "Please install it using one of these commands:"
        echo "  • pip install pre-commit"
        echo "  • brew install pre-commit"
        echo "  • conda install -c conda-forge pre-commit"
        echo ""
        read -p "Do you want to continue without pre-commit? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Please install pre-commit and run this script again."
            exit 1
        fi
    fi
    
    echo "Installing Git hooks..."
    ./.github/scripts/install-hooks.sh
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Setup completed successfully!"
    else
        echo ""
        echo "❌ Setup failed. Please check the error messages above."
        exit 1
    fi
fi

echo ""
echo "📚 Available DDL export tools for:"
echo "  • BigQuery"
echo "  • Databricks" 
echo "  • DB2"
echo "  • Hive"
echo "  • Netezza"
echo "  • Oracle"
echo "  • Redshift"
echo "  • SQL Server"
echo "  • Teradata"
echo "  • Vertica"
echo ""
echo "Check the README.md files in each folder for specific instructions."
echo "==============================================="
