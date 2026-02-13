# Contributing

Thanks for contributing to `jammer-cli`.

## Prerequisites

- Ruby `>= 3.0`
- Bundler
- Git

## Setup

```bash
git clone https://github.com/rna/jammer-cli.git
cd jammer-cli
bundle install
```

## Run Checks

```bash
bundle exec rspec
bundle exec rubocop --display-cop-names
```

## Development Notes

- Keep changes focused and small.
- Add or update tests for behavior changes.
- Update `README.md` and `CHANGELOG.md` when user-facing behavior changes.

## Pull Request Checklist

- [ ] Tests added/updated for changed behavior
- [ ] Lint passes (`bundle exec rubocop`)
- [ ] `README.md` updated if required
- [ ] `CHANGELOG.md` updated under `Unreleased`
