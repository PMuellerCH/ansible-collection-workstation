# swisstopo.workstation.code_quality_tools

Installs code-quality and security tooling used across repos: `trivy`
(container/IaC vulnerability scanner), `pre-commit` (git hook framework),
and the pipx-based tools `pre-commit` hooks commonly shell out to —
`detect-secrets`, `yamllint`, `checkov`, `ansible-lint` (with `ansible-core`
injected into its venv so `ansible-lint` can actually parse plays). Bundled
together because they're all "tools a repo's pre-commit config invokes" —
the same category of tool a developer reaches for regardless of language.

This role is **tools-only**. It does not wire up git hooks (`pre-commit
install`, `pre-commit install --hook-type commit-msg`) or generate a
`.secrets.baseline` — those are bound to a specific repo's `.git` directory
and `.pre-commit-config.yaml`, not something a generic reusable role should
do. Wire those up in the consuming repo's own playbook.

## What it does

- Installs `trivy` from a GitHub-released `.deb`.
- Installs the `pre-commit` apt package.
- Bootstraps an adequate `pipx` (see "pipx bootstrap" below) and, through it,
  installs `detect-secrets`, `yamllint`, `checkov`, and `ansible-lint` (with
  `ansible-core` injected into the same venv).

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `code_quality_tools_trivy_enabled` | `true` | Install trivy |
| `code_quality_tools_pre_commit_enabled` | `true` | Install the pre-commit apt package |
| `code_quality_tools_detect_secrets_enabled` | `true` | Install detect-secrets via pipx |
| `code_quality_tools_yamllint_enabled` | `true` | Install yamllint via pipx |
| `code_quality_tools_checkov_enabled` | `true` | Install checkov via pipx |
| `code_quality_tools_ansible_lint_enabled` | `true` | Install ansible-lint via pipx, with ansible-core injected |
| `code_quality_tools_trivy_version` | see `defaults/main.yml` | trivy version (github-releases: `aquasecurity/trivy`) |
| `code_quality_tools_trivy_download_base` | see `defaults/main.yml` | Base URL the trivy `.deb`/checksums file are downloaded from |
| `code_quality_tools_pre_commit_version` | see `defaults/main.yml` | Exact apt version of pre-commit |
| `code_quality_tools_detect_secrets_version` | see `defaults/main.yml` | detect-secrets version (pypi) |
| `code_quality_tools_yamllint_version` | see `defaults/main.yml` | yamllint version (pypi) |
| `code_quality_tools_checkov_version` | see `defaults/main.yml` | checkov version (pypi) |
| `code_quality_tools_ansible_lint_version` | see `defaults/main.yml` | ansible-lint version (pypi) |
| `code_quality_tools_ansible_core_version` | see `defaults/main.yml` | ansible-core version (pypi), injected into the ansible-lint pipx venv |
| `code_quality_tools_pipx_min_version` | see `defaults/main.yml` | pipx version (pypi) bootstrapped via `pip install --user`, see below |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.code_quality_tools
```

## Tags

Every task carries its own tag(s) in addition to the umbrella
`code_quality_tools` tag, so a consuming playbook can filter to a single
tool:

| Tool | Tags |
| --- | --- |
| trivy | `trivy`, `code_quality_tools` |
| pre-commit (apt package) | `pre_commit`, `code_quality_tools` |
| pipx bootstrap | `detect_secrets`, `yamllint`, `checkov`, `ansible_lint`, `code_quality_tools` (runs if any of those tools is enabled) |
| detect-secrets | `detect_secrets`, `code_quality_tools` |
| yamllint | `yamllint`, `code_quality_tools` |
| checkov | `checkov`, `code_quality_tools` |
| ansible-lint (+ injected ansible-core) | `ansible_lint`, `code_quality_tools` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

## Notes

- The trivy `.deb` is downloaded from GitHub releases and checksum-verified
  against upstream's own `trivy_<version>_checksums.txt` (a plain
  `sha256sum`-format file, fed directly to `get_url`'s `checksum:` param —
  no custom fetch/parse tasks needed). The installed version is checked
  before downloading, for idempotency.
- `pre-commit` is a plain pinned apt package (Ubuntu ships one), held after
  install like every other pinned apt package in this collection.

### pipx bootstrap

`community.general.pipx` hard-requires pipx **>= 1.7.0** (it runs `pipx
version` and fails the whole module if older). Ubuntu 24.04's apt-provided
`pipx` is only **1.4.3**. A role in this collection can't assume a consumer
has already upgraded pipx globally (see this collection's role-independence
convention), so this role bootstraps pipx itself, scoped to whichever
pipx-based tools (`detect_secrets`/`yamllint`/`checkov`/`ansible_lint`) are
actually enabled.

The bootstrap is: ensure `python3-pip` and `python3-venv` (apt — pipx needs
`venv` to build the isolated environments each tool lives in), then `pip3
install --user pipx=={{ code_quality_tools_pipx_min_version }}
--break-system-packages`.
No apt-provided `pipx` package is installed or touched — `pip install --user`
places the newer `pipx` in the user's Python **user site-packages**, ahead of
the system `dist-packages` on `sys.path`.

This works without any `PATH` manipulation because `community.general.pipx`
does not shell out to a `pipx` binary by default — per the module's own
documentation, "if [the `executable` parameter is] not specified, the module
uses `python -m pipx` to run the tool, using the same Python interpreter as
Ansible itself." Since `python3 -m pipx` resolves against `sys.path` (where
the freshly `pip install --user`'d package now shadows the older
`dist-packages` one), the bootstrap works reliably without needing the new
`pipx` on `$PATH` or the module's `executable:` param pointed anywhere
special. Verified for real in Molecule against a fresh `ubuntu:24.04`
container that starts with only the apt-provided 1.4.3 (or no pipx at all).

Because the bootstrap's `pip3 install --user` step reports `changed` under
`ansible-playbook --check` without actually installing anything (same class
of dry-run gap as any `get_url`-then-consume chain — see the collection's
check-mode conventions), every pipx-based tool-install task downstream of it
is gated with `when: not ansible_check_mode`, so a `--check` run degrades
gracefully on a box that has never had an adequate pipx instead of hard
failing when the tool-install tasks try to introspect pipx state that was
never actually created.
