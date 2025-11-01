# jammer-cli

## GOAL of this project:
It is a lightweight CLI + Git pre-commit hook that prevents committing files with forbidden keywords (like TODO, FIXME, DEBUG).
It helps keep repositories clean by enforcing code hygiene automatically.

## Features
- [x] Regex-based scanning for keywords (default: #TODO).
- [x] CLI options: custom keyword, list matches, count matches.
- [x] One-command setup and cleanup: `jammer --init` and `jammer --uninstall`
- [x] Local installation via RubyGem.
- [x] Config file support (.jammer.yml) with multiple keywords and exclude patterns.
- [x] GitHub/ESLint-style configuration format.

## Installation

### Local Installation (for Development/Testing)

1.  Clone the repository:
    ```bash
    git clone https://github.com/rna/jammer-cli.git
    cd jammer-cli
    ```
2.  Build the gem locally:
    ```bash
    gem build jammer-cli.gemspec
    ```
3.  Install the built `.gem` file (replace version if needed):
    ```bash
    gem install ./jammer-cli-0.1.0.gem
    ```

## Quick Start

Initialize jammer in your project (creates config + installs Git hook):

```bash
jammer --init
```

This will:
1. Create `.jammer.yml` based on [`.jammer.yml.example`](.jammer.yml.example)
2. Install the Git pre-commit hook automatically (if in a Git repository)

Edit `.jammer.yml` to customize keywords and exclude patterns for your project.

### Removing Jammer

To completely remove jammer from your project:

```bash
jammer --uninstall
```

This will remove both `.jammer.yml` and the Git pre-commit hook.

## Configuration

### Config File Format

The `.jammer.yml` file follows the GitHub/ESLint config pattern. See [`.jammer.yml.example`](.jammer.yml.example) for a complete example.

**`keywords`** - List of patterns to search for (default: `#TODO`)

**`exclude`** - List of path patterns to skip during scanning

## Usage

### Check for Keywords Manually

```bash
# Check using configured keywords from .jammer.yml
jammer

# Check using a custom keyword
jammer --keyword FIXME

# List all occurrences with file paths
jammer --list

# Count total occurrences
jammer --count
```

### Force Overwrite

Use `--force` flag with `--init` to overwrite existing config:

```bash
jammer --init --force
```

## Uninstalling the Gem

```bash
gem uninstall jammer-cli
```

Note: This does NOT remove the configuration and hooks from all individual repositories. Use `jammer --uninstall` in each project to clean up.