# Version Control Hooks

This directory contains Git hooks to ensure proper version management in the repository.

## What These Hooks Do

The pre-commit hook checks if you've modified any `.sh` or `.sql` files outside of the `.github/` directory. If you have, it verifies that the `VERSION` file has also been modified. If not, it warns you to update the version and run the `VERSION-UPDATE.sh` script.

**Important**: This step is mandatory for all developers to ensure consistent versioning across the codebase.

## Installation

To install the hooks, run:

```bash
./.github/scripts/install-hooks.sh
```

This requires `pre-commit` to be installed on your system. If you don't have it, you can install it with:

```bash
pip install pre-commit
# or
brew install pre-commit  # On macOS with Homebrew
```

## Usage

After installation, the hooks will run automatically when you commit changes. If you've modified `.sh` or `.sql` files without updating the VERSION file, you'll see a warning.

To update the version properly:

1. Modify the `VERSION` file with the new version number
2. Run `./VERSION-UPDATE.sh` to propagate the version to all README.md files
3. Commit your changes

If you need to bypass the check (not recommended), you can use:

```bash
git commit --no-verify
```



