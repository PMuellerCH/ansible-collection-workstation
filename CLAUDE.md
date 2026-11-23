# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What this repo is

An Ansible Galaxy collection (`pmuellerch.workstation`) containing roles for provisioning
developer and personal/home workstation tools. It is the merge of the former
`swisstopo.workstation` (`infra-ansible-collection-workstation`, archived) and the personal roles. Targets Ubuntu 24.04 (Noble) with the COSMIC desktop
environment. Role code is generic and public; personal configuration lives in the private
`PMuellerCH/computer-setup` repo as variables.

## Common commands

```bash
# Install this collection locally for linting — also pulls in runtime deps
# declared in galaxy.yml's `dependencies:` (e.g. community.general)
ansible-galaxy collection install . --force

# Install collection dependencies and molecule's own driver dependency
ansible-galaxy collection install -r requirements.yml
# (molecule driver dependency: community.docker)
ansible-galaxy collection install -r requirements-molecule.yml

# Lint
yamllint --config-file .yamllint.yml .
ansible-lint

# Security scan
checkov --framework ansible --directory . --quiet

# Markdown lint
pre-commit run markdownlint-cli2 --all-files

# Molecule test a single role (needs Docker)
cd roles/<name> && molecule test
```

The collection must be installed locally (`ansible-galaxy collection install . --force`)
before running `ansible-lint`.

## Architecture

```text
galaxy.yml                  # Collection metadata (namespace, name, version, dependencies)
meta/runtime.yml            # Minimum ansible-core version requirement
roles/ROLE_README_TEMPLATE.md  # Copy this for every new role's README.md (build_ignore'd)
roles/<name>/
  tasks/main.yml
  defaults/main.yml         # Version pins with Renovate comments
  files/                    # Static config files
  templates/                # Jinja2 templates
  meta/main.yml             # Role metadata (platforms, dependencies)
  README.md                 # Follows roles/ROLE_README_TEMPLATE.md
  molecule/default/         # Optional: molecule scenario (see Testing below)
```

## Testing

Molecule and the full lint run as thin wrappers around `PMuellerCH/shared-actions` reusable workflows;
the changed-files lint runs pre-commit inline.

- **Lint** (`ci.yml`): on ordinary PRs `lint-changed` runs pre-commit only on files changed
  vs. `origin/main` (checkov still scans everything); on the release-please PR and
  `workflow_dispatch` `lint-full` runs the complete yamllint, ansible-lint, markdownlint,
  checkov suite.
- **Molecule** (`molecule.yml`) auto-discovers any role with a `roles/<name>/molecule/default/`
  scenario and runs `molecule test` as a matrix job. On every PR it tests only the roles whose
  files changed (shared files like `requirements*.yml`, `galaxy.yml` or the workflow itself
  trigger the full matrix); on the release-please PR and `workflow_dispatch` it runs the full
  matrix. This means **a release is never cut without molecule passing** on the release-please
  PR — merge it only once that check is green.
- A role only gets tested once it has a `molecule/default/` scenario; adding one is
  opt-in per role, not mandatory. Not every workstation role is a good fit for Docker
  (e.g. anything depending on the COSMIC desktop, X11, or a systemd user session) —
  add a scenario where it adds real signal (idempotency, package installs, file
  templating), skip it where a container can't meaningfully exercise the role.

## Key conventions

### Version pinning

Every version string must be pinned to an exact version and covered by a Renovate manager:

- **apt packages**: installed unpinned from real apt repos (see README "apt package versions are unpinned"); only
  packages that need a fixed version (e.g. `trivy`, `dust`, `yazi`) are pinned in `defaults/main.yml` with a Renovate comment
- **GitHub releases / pipx / npm**: version variable in `defaults/main.yml` with appropriate Renovate datasource comment
- **Python CI tools** (`.github/requirements.txt`): exact pin, tracked by `pip_requirements` manager
- **Node CI tools** (`.github/package.json`): exact pin, tracked by npm manager
- **GitHub Actions**: tracked by `github-actions` manager
- **Pre-commit hooks**: tracked by `pre-commit` manager

### Collection dependencies

If a role's tasks use a module from outside `ansible.builtin` (e.g. `community.general.flatpak`),
declare that collection in `galaxy.yml`'s `dependencies:` field — this is the only mechanism that
makes `ansible-galaxy collection install .` (what CI, `ansible-lint`, and every consumer's
`requirements.yml` entry actually run) pull it in automatically. A collection used only by one
role but not declared here will pass locally if it happens to already be installed on your
machine, then fail in CI with `couldn't resolve module/action`.

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

All role names use underscores (never hyphens) — matches this collection's existing roles
(`bitwarden`, `synology`, `betterbird`, `multimedia`, `graphics`) and the roles merged from `swisstopo.workstation`
(`code_quality_tools`, `terminal_env`, etc.), the roles split from `iac_tools` (`ansible_dev`, `cloud_cli`,
`k8s_tools`) and the roles split from `cli_dev_env`/`modern_cli`/`gh` (`git`, `editor`, `ai_cli`, `cli_tools`).

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
