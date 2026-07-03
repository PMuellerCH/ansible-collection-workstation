# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What this repo is

An Ansible Galaxy collection (`pmuellerch.workstation`) containing roles for provisioning
personal/home workstation tools. Targets Ubuntu 24.04 (Noble) with the COSMIC desktop
environment. Role code is generic and public; personal configuration lives in the private
`PMuellerCH/computer-setup` repo as variables.

## Common commands

```bash
# Install this collection locally for linting
ansible-galaxy collection install . --force

# Install collection dependencies
ansible-galaxy collection install -r requirements.yml

# Lint
yamllint --config-file .yamllint.yml .
ansible-lint

# Security scan
checkov --framework ansible --directory . --quiet

# Markdown lint (via pre-commit, uses markdownlint-cli2)
pre-commit run markdownlint-cli2 --all-files
```

The collection must be installed locally (`ansible-galaxy collection install . --force`)
before running `ansible-lint`.

## Architecture

```text
galaxy.yml                  # Collection metadata (namespace, name, version)
meta/runtime.yml            # Minimum ansible-core version requirement
roles/<name>/
  tasks/main.yml
  defaults/main.yml         # Version pins with Renovate comments
  files/                    # Static config files
  templates/                # Jinja2 templates
  meta/main.yml             # Role metadata (platforms, dependencies)
```

## Key conventions

### Version pinning

Every version string must be pinned to an exact version and covered by a Renovate manager:

- **apt packages**: version variable in `defaults/main.yml` with `# renovate: datasource=deb`
  comment; `dpkg_selections: hold` applied after install to prevent `apt upgrade` from overriding
- **GitHub releases / pipx / npm**: version variable in `defaults/main.yml` with appropriate Renovate datasource comment
- **Python CI tools** (`.github/requirements.txt`): exact pin, tracked by `pip_requirements` manager
- **Node CI tools** (`.github/package.json`): exact pin, tracked by npm manager
- **GitHub Actions**: tracked by `github-actions` manager
- **Pre-commit hooks**: tracked by `pre-commit` manager

### Package installation order

1. apt
2. GitHub releases (.deb / binary)
3. Flatpak (GUI apps without apt repos)
4. npm global
5. pipx
6. Shell script installer — last resort

### Idempotency

- Guard downloads with `ansible.builtin.stat` + `when: not <stat>.stat.exists`
- Use `creates:` on `command` tasks
- Use `when: not ansible_check_mode` on tasks that depend on prior steps that don't run in check mode

### Role naming

All role names use underscores (never hyphens): `emoji_picker`, `gui_customization`, etc.

### Theming

All tools use **Catppuccin Mocha** theme.

## Dev process

1. **GitHub issue first** — create with `gh issue create` before starting work
2. **Feature branch** — `feat/<issue>-<description>` or `fix/<issue>-<description>`
3. **Implement** — keep commits focused
4. **Pre-commit** — all hooks must pass before commit
5. **Push + PR** — `gh pr create` referencing the issue

## Commit message format

Conventional Commits: `<type>: <description>`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`
