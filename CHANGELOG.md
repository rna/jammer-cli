# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Enforced strict `.jammer.yml` schema validation with friendly CLI errors.
- Added source-checkout fallback path resolution for `jammer --init`.
- Matched `exclude` patterns against file paths only.
- Executed configured commands without an implicit shell.
- Improved init/uninstall output behavior and messaging.
- Tightened gem packaging to include runtime files and core docs only.

### Added
- CLI and hook manager integration specs.
- RubyGems install instructions in README.

## [0.1.0] - 2025-11-02

### Added
- Initial release of `jammer-cli`.
- Keyword scanning via CLI and git pre-commit hook.
- `.jammer.yml` configuration support (`keywords`, `exclude`, `commands`).
- `--init`, `--uninstall`, `--list`, `--count`, and `--keyword` command options.
