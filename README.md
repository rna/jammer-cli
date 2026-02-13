# jammer-cli

[![Tests & Linting](https://github.com/rna/jammer-cli/actions/workflows/tests.yml/badge.svg)](https://github.com/rna/jammer-cli/actions/workflows/tests.yml)
[![Gem Version](https://img.shields.io/gem/v/jammer-cli.svg)](https://rubygems.org/gems/jammer-cli)
[![Gem Downloads](https://img.shields.io/gem/dt/jammer-cli.svg)](https://rubygems.org/gems/jammer-cli)
[![License](https://img.shields.io/github/license/rna/jammer-cli.svg)](https://github.com/rna/jammer-cli/blob/main/LICENSE)

## GOAL of this project:
It is a lightweight CLI + Git pre-commit hook that prevents committing files with forbidden keywords (like TODO, FIXME, DEBUG).
It helps keep repositories clean by enforcing code hygiene automatically.

## Features
- [x] Regex-based scanning for keywords (default: `#TODO`).
- [x] Scans staged files in Git repositories.
- [x] CLI options: custom keyword, list matches, count matches.
- [x] One-command setup and cleanup: `jammer --init` and `jammer --uninstall`
- [x] Local installation via RubyGem.
- [x] RubyGems installation support (`gem install jammer-cli`).
- [x] Config file support (`.jammer.yml`) with multiple keywords, exclude patterns, and optional commands.
- [x] GitHub/ESLint-style configuration format.

## Prerequisites
- Ruby `>= 3.0`
- Git
- A shell environment with `grep` available

## Installation

### Install from RubyGems

```bash
gem install jammer-cli
```

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

This removes `.jammer.yml` and removes the Git pre-commit hook only if it was installed by jammer.

## Usage

### Command Reference

- `jammer` - Check staged files using configured keywords
- `jammer --keyword KEYWORD` - Check with a one-off keyword
- `jammer --list` - List all matches
- `jammer --count` - Show match count
- `jammer --init` - Create config and install hook
- `jammer --init --force` - Force overwrite existing config/hook
- `jammer --uninstall` - Remove jammer config/hook from current project
- `jammer --help` - Show help
- `jammer --version` - Show version

### Exit Codes

- `0` - Success (no blocking issues)
- `1` - Blocking issue (keywords found, invalid config, hook/config setup issue, or configured command failure)
- `2` - Internal jammer runtime error (`Jammer::Error`)

## Configuration

### Config File Format

The `.jammer.yml` file follows the GitHub/ESLint config pattern. See [`.jammer.yml.example`](.jammer.yml.example) for a complete example.

**`keywords`** - List of patterns to search for (default: `["#TODO"]`)

**`exclude`** - List of path patterns to skip during scanning (default: `[]`)

**`commands`** - List of commands to run after keyword checks pass (default: `[]`)

Commands run directly (without implicit shell). For shell operators like `&&`, wrap explicitly:

```yaml
commands:
  - rubocop
  - sh -c "bundle exec rspec --fail-fast && echo done"
```

### Example `.jammer.yml`

```yaml
keywords:
  - TODO
  - FIXME
exclude:
  - vendor/
  - node_modules/
commands:
  - rubocop
```

Note: Exclude patterns are matched against file paths only.

## Hook Behavior

- `jammer --init` installs `.git/hooks/pre-commit` if no hook exists.
- If a jammer-installed hook already exists, init is idempotent.
- If a custom pre-commit hook exists, init fails (unless `--force` is used).
- `--force` overwrites existing config/hook.
- `jammer --uninstall` removes only the jammer-created hook and leaves custom hooks untouched.
- If `jammer` command is missing during commit, the hook blocks the commit.

## Troubleshooting

- `Error: 'jammer' command not found` in hook: install the gem (`gem install jammer-cli`) and ensure RubyGems bin path is in `PATH`.
- `Unknown setting(s) in .jammer.yml`: use only `keywords`, `exclude`, and `commands`.
- `'keywords'/'exclude'/'commands' must be an array of strings`: fix the value type in `.jammer.yml`.
- `A custom pre-commit hook already exists. Cannot auto-install.`: keep existing hook, or run `jammer --init --force` if overwriting is intended.
- `Nothing to uninstall. No .jammer.yml or git hook found.`: jammer is not installed in the current project.

## Security Note

Configured `commands` are executed from the repository's `.jammer.yml`.  
Run jammer only in repositories you trust.

## Release

- Tagging `vX.Y.Z` triggers the GitHub release workflow at [`.github/workflows/release.yml`](.github/workflows/release.yml).
- Publishing requires GitHub Actions secret: `RUBYGEMS_API_KEY`.

## Roadmap

- Preserve existing custom hook while appending jammer checks (non-destructive hook mode)
- Optional JSON output for CI tooling
- Richer exclude matching (glob-style patterns)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local setup, testing, and pull request guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

MIT - See [LICENSE](LICENSE)
