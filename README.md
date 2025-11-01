# jammer-cli

## GOAL of this project:
It is a lightweight CLI + Git pre-commit hook that prevents committing files with forbidden keywords (like TODO, FIXME, DEBUG).
It helps keep repositories clean by enforcing code hygiene automatically.

## Features
- [x] Regex-based scanning for keywords (default: #TODO).
- [x] CLI options: custom keyword, list matches, count matches.
- [x] Git pre-commit hook install/uninstall commands.
- [x] Local installation via RubyGem.
- [x] Manual keyword scanning via CLI.
- [x] Config file support (.jammer.yml) for multiple keywords and excludes.

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

## Usage

### Setting up the Git Pre-Commit Hook

Once the gem is installed, navigate to the root directory of any Git repository where you want to enable the check, and run:

```bash
jammer --install-hook
```

This will create or update the `.git/hooks/pre-commit` script for that specific repository.

Now, before you commit in that repository, Git will automatically run `jammer`. If it finds the configured keyword (default: `#TODO`), it will abort the commit.

### Checking for Keywords Manually

```bash
# Check using default keyword (#TODO)
jammer

# Check using a custom keyword
jammer --keyword FIXME

# List occurrences
jammer --list

# Count occurrences
jammer --count
```

## Uninstallation

```bash
# Uninstall the gem
gem uninstall jammer-cli

# Note: This does NOT remove the pre-commit hooks changed in individual repositories.
# You need to manually delete the .git/hooks/pre-commit file in those repos if desired.
```
