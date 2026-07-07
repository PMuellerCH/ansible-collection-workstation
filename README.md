# infra-ansible-collection-workstation

[![CI](https://github.com/swisstopo/infra-ansible-collection-workstation/actions/workflows/ci.yml/badge.svg)](https://github.com/swisstopo/infra-ansible-collection-workstation/actions/workflows/ci.yml)

An Ansible Collection for provisioning and maintaining IaC developer workstations.

## Continuous Integration

Lint (`ci.yml`) and release (`release-please.yml`) both run as thin wrappers around
reusable workflows in [infra-github-shared-actions](https://github.com/swisstopo/infra-github-shared-actions),
so tooling versions and behavior stay in sync with the other Ansible collections
(e.g. `infra-ansible-collection-postgres`). Release-please authenticates as a GitHub
App (org secrets `RELEASE_BOT_APP_ID` / `RELEASE_BOT_PRIVATE_KEY`) so release PRs are
not blocked by the org policy on `github-actions[bot]`.
