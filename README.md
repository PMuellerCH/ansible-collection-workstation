# pmuellerch.workstation

[![CI](https://github.com/PMuellerCH/ansible-collection-workstation/actions/workflows/ci.yml/badge.svg)](https://github.com/PMuellerCH/ansible-collection-workstation/actions/workflows/ci.yml)

An Ansible Collection (`pmuellerch.workstation`) for provisioning and maintaining
developer and personal workstations running Ubuntu 24.04 with the COSMIC or GNOME
desktop environment. It merges the former `swisstopo.workstation`
(`infra-ansible-collection-workstation`, now archived) with the personal roles.

## Roles

No role declares an Ansible role dependency on another (`meta/main.yml` is
empty everywhere), so every role can run standalone — this is what Molecule
tests. On a real workstation, run `base` first anyway: it sets up locale,
proxy, hostname, git, and fonts that other roles are written to assume are
already in place.

| Role | What it installs |
| --- | --- |
| [base](roles/base/README.md) | Base system packages, hostname, locale, corporate proxy, git, SSH, Python toolchain, fonts — run first |
| [cli_dev_env](roles/cli_dev_env/README.md) | lazygit, neovim (LazyVim), Claude Code CLI, Kiro CLI, OpenCode |
| [chat_clients](roles/chat_clients/README.md) | Slack, Microsoft Teams |
| [clipboard_tools](roles/clipboard_tools/README.md) | Wayland clipboard tooling: wl-clipboard, cliphist, clipse |
| [code_quality_tools](roles/code_quality_tools/README.md) | trivy, pre-commit, detect-secrets, yamllint, checkov, ansible-lint |
| [desktop_apps](roles/desktop_apps/README.md) | OnlyOffice Desktop Editors, Firefox policies |
| [desktop_customization](roles/desktop_customization/README.md) | GNOME/COSMIC workspace settings, Flameshot, emoji picker (GUI) |
| [gh](roles/gh/README.md) | GitHub CLI |
| [ansible_dev](roles/ansible_dev/README.md) | ansible-core (pipx) + molecule, Docker CE, act |
| [cloud_cli](roles/cloud_cli/README.md) | AWS CLI + session-manager-plugin, Terraform/Vault, tfswitch, tflint, terraform-docs, floci |
| [k8s_tools](roles/k8s_tools/README.md) | kubectl, k9s, helm, kubectx/kubens, stern, krew, kubeconform, kube-linter |
| [maintenance](roles/maintenance/README.md) | apt update/safe-upgrade, autoremove/autoclean, journal vacuum, Docker prune, Flatpak cleanup — for a separate maintenance playbook, not `site.yml` |
| [modern_cli](roles/modern_cli/README.md) | bat, btop, eza, fd, fzf, htop, presenterm, ripgrep, zoxide, emoji-fzf |
| [terminal_env](roles/terminal_env/README.md) | zsh, tmux, kitty |
| [bitwarden](roles/bitwarden/README.md) | Bitwarden password manager desktop app |
| [synology](roles/synology/README.md) | Synology Drive and Chat clients |
| [betterbird](roles/betterbird/README.md) | Betterbird (Thunderbird fork) email client |
| [multimedia](roles/multimedia/README.md) | beets, Spotify + ncspot, Plex Desktop and Plexamp — each independently toggleable |
| [graphics](roles/graphics/README.md) | Graphics tools (Inkscape, GIMP, Pinta) |

Every role uses per-tool Ansible tags (in addition to an umbrella
`<role_name>` tag) so a consuming playbook can select a single tool with
`--tags <tool>` — see each role's own README for its tag table.

## Example: provisioning a developer workstation

Copy-paste starting point for bringing up a fresh Ubuntu 24.04
IaC developer workstation. Install the collection, then run a playbook that
applies the roles in the recommended order (`base` first; `cli_dev_env`
before `modern_cli` so the NodeSource Node.js is in place before
`modern_cli`'s mermaid-cli check — see the `cli_dev_env` README).

Install the collection from this repository (it is distributed via git tags,
not published to Ansible Galaxy). Pin the tag in a `requirements.yml` — use the
2.0.0 or newer (earlier tags do not contain the developer roles used
below):

```yaml
# requirements.yml
collections:
  - name: pmuellerch.workstation
    type: git
    source: https://github.com/PMuellerCH/ansible-collection-workstation.git
    version: "2.0.0"
```

```bash
ansible-galaxy collection install -r requirements.yml
```

`site.yml` — fill in the placeholders for your own machine (hostname, git
identity, the corporate proxy, the Vault address, and a GitHub PAT for the
Claude Code `github` MCP server). Pull secrets from your own store (Ansible
Vault, env, Vault) — never commit real tokens. The play-level `environment:`
block makes the proxy available to this provisioning run itself — `base` writes
the proxy into system files, but that does not affect the already-running
Ansible process, so without this block the first run's downloads fail on a
fresh proxied machine:

```yaml
---
- name: Provision an IaC developer workstation
  hosts: localhost
  connection: local
  become: false
  environment:
    http_proxy: "{{ base_http_proxy }}"
    https_proxy: "{{ base_http_proxy }}"
    HTTP_PROXY: "{{ base_http_proxy }}"
    HTTPS_PROXY: "{{ base_http_proxy }}"
  vars:
    # --- required (base has no defaults for these) ---
    base_hostname: my-workstation
    base_git_user_name: "Jane Doe"
    base_git_user_email: jane.doe@example.com
    # --- corporate network (leave "" off-network) ---
    base_http_proxy: "http://proxy.example.com:8080"
    ansible_dev_http_proxy: "{{ base_http_proxy }}"
    cloud_cli_http_proxy: "{{ base_http_proxy }}"
    # --- Vault (enables the vault-login shell helper) ---
    base_vault_addr: "https://vault.example.com"
    cloud_cli_vault_addr: "{{ base_vault_addr }}"
    # vault-login also needs a GitHub token written to ~/.config/vault/github_token:
    cloud_cli_terraform_vault_github_token: "{{ lookup('ansible.builtin.env', 'VAULT_GITHUB_PAT') }}"
    # --- Claude Code github MCP server token (from your own secret store) ---
    cli_dev_env_claude_code_github_token: "{{ lookup('ansible.builtin.env', 'GITHUB_PAT') }}"
  roles:
    # 1. base first: locale, corporate proxy, hostname, git, SSH, Python, fonts.
    - role: pmuellerch.workstation.base
    # 2. terminal shell + multiplexer + terminal emulator.
    - role: pmuellerch.workstation.terminal_env
    # 3. CLI dev environment: lazygit, neovim/LazyVim, Claude Code, Kiro CLI,
    #    OpenCode. Runs before modern_cli so its NodeSource Node.js wins on PATH.
    - role: pmuellerch.workstation.cli_dev_env
    # 4. modern CLI replacements (bat, eza, fd, fzf, ripgrep, zoxide, ...).
    - role: pmuellerch.workstation.modern_cli
    # 5. clipboard tooling (Wayland), GitHub CLI, then the infra toolchain.
    #    ansible_dev must come before cloud_cli and k8s_tools: it creates the
    #    ansible-core pipx venv they inject boto3 / the Python Kubernetes
    #    libraries into (they skip the inject if it doesn't exist yet).
    - role: pmuellerch.workstation.clipboard_tools
    - role: pmuellerch.workstation.gh
    - role: pmuellerch.workstation.ansible_dev
    - role: pmuellerch.workstation.cloud_cli
    - role: pmuellerch.workstation.k8s_tools
    # 6. code-quality / security scanners.
    - role: pmuellerch.workstation.code_quality_tools
    # 7. desktop apps and customization (GUI — skip on a headless box).
    - role: pmuellerch.workstation.desktop_apps
    - role: pmuellerch.workstation.desktop_customization
    - role: pmuellerch.workstation.chat_clients
```

Run it against the local machine:

```bash
ansible-playbook site.yml --ask-become-pass
```

Notes:

- `maintenance` is deliberately **not** in this list — it is destructive
  housekeeping (apt upgrade, Docker/Flatpak prune, journal vacuum) meant for a
  separate, scheduled maintenance playbook, not first provisioning.
- Every role is independently toggleable and standalone. Drop any role you do
  not want, or narrow a role to one tool with `--tags <tool>` (e.g.
  `--tags neovim`).
- After the run, open a new shell (so `~/.config/zsh/conf.d/*.zsh` is sourced),
  then authenticate the interactive tools yourself: `claude login` (Claude
  Code), `kil` / `kiro-cli login` (Kiro CLI), and the `opencode` login plus a
  `MISTRAL_API_KEY` in your environment (OpenCode).

## Migrating from `iac_tools`

The `iac_tools` role was split into `ansible_dev`, `cloud_cli` and `k8s_tools` (a breaking change; variables were
renamed with no aliases). Replace the role in your play with the three new ones, in this order — `ansible_dev` creates
the `ansible-core` pipx venv that `cloud_cli` (boto3) and `k8s_tools` (Python Kubernetes libraries, non-Ubuntu) inject
into, and they skip that inject if the venv isn't there yet.

| Old | New |
| --- | --- |
| `iac_tools_ansible_enabled`, `_docker_enabled`, `_act_enabled` | `ansible_dev_ansible_enabled`, `_docker_enabled`, `_act_enabled` |
| `iac_tools_aws_enabled`, `_terraform_enabled`, `_floci_enabled` | `cloud_cli_aws_enabled`, `_terraform_enabled`, `_floci_enabled` |
| `iac_tools_kubernetes_tools_enabled` | removed — include `k8s_tools` or don't |
| `iac_tools_http_proxy`, `_https_proxy`, `_no_proxy` | `ansible_dev_*` (Docker daemon/client) and `cloud_cli_http_proxy` (AWS/Terraform snippets) |
| `iac_tools_vault_addr`, `iac_tools_terraform_*`, `iac_tools_aws_*`, `_tflint_*`, `_tfswitch_*`, `_floci_*` | same name with the `cloud_cli_` prefix |
| `iac_tools_pipx_min_version`, `_ansible_core_version`, `_hvac_version`, `_act_*` | same name with the `ansible_dev_` prefix |
| `iac_tools_ansible_molecule_version`, `_ansible_molecule_plugins_version` | `ansible_dev_molecule_version`, `ansible_dev_molecule_plugins_version` |
| `iac_tools_kubernetes_clusters`, `_kubernetes_current_context` | `k8s_tools_clusters`, `k8s_tools_current_context` |
| `iac_tools_kubernetes_pip_*` | `k8s_tools_pip_*` |
| `iac_tools_kubectl_*`, `_k9s_*`, `_helm_*`, `_kubectx_*`, `_kubens_*`, `_stern_*`, `_krew_*`, `_kubeconform_*`, `_kube_linter_*` | same name with the `k8s_tools_` prefix |

Tags: `kubernetes_tools` is replaced by `kubectl`, `k9s`, `helm`, `kube_utils`, `python_libs`, `config`, and the umbrella
tags are `ansible_dev`, `cloud_cli` and `k8s_tools` instead of `iac_tools`. The AWS CLI and session-manager-plugin are now
GPG-verified (see the `cloud_cli` README).

## Shell aliases

Several roles deploy zsh snippets to `~/.config/zsh/conf.d/*.zsh`. They take
effect only in an interactive zsh that sources that directory —
`terminal_env`'s `.zshrc` does this. Most `modern_cli` and `clipboard_tools`
entries, and the `cli_dev_env` Kiro (`ki`/`kil`) and OpenCode (`oc`/`ocr`)
aliases, are additionally
guarded by a `command -v` check so they are defined only when the tool is
actually installed; the `cli_dev_env` `vi`/`vim` and the `cloud_cli` entries
are plain aliases gated only by the role variable in the last column.
Items written as `name()` are shell functions rather than plain aliases.

| Alias / function | Runs | Role | Enabled by |
| --- | --- | --- | --- |
| `cat` | `batcat --paging=never` | modern_cli | `modern_cli_bat_enabled` |
| `top` | `btop` | modern_cli | `modern_cli_btop_enabled` |
| `grep` | `rg` | modern_cli | `modern_cli_ripgrep_enabled` |
| `find` | `fd` | modern_cli | `modern_cli_fd_enabled` |
| `sed` | `sd` | modern_cli | `modern_cli_sd_enabled` |
| `ps` | `procs` | modern_cli | `modern_cli_procs_enabled` |
| `du` | `dust` | modern_cli | `modern_cli_dust_enabled` |
| `df` | `duf` | modern_cli | `modern_cli_duf_enabled` |
| `diff` | `delta` | modern_cli | `modern_cli_delta_enabled` |
| `ping` | `gping` | modern_cli | `modern_cli_gping_enabled` |
| `watch` | `viddy` | modern_cli | `modern_cli_viddy_enabled` |
| `less` | `moor` | modern_cli | `modern_cli_moor_enabled` |
| `cp` | `xcp` | modern_cli | `modern_cli_xcp_enabled` |
| `dig` | `doggo` | modern_cli | `modern_cli_doggo_enabled` |
| `jq` | `jaq` | modern_cli | `modern_cli_jaq_enabled` |
| `hexdump` | `hexyl` | modern_cli | `modern_cli_hexyl_enabled` |
| `ls`, `l` | `eza --icons` | modern_cli | `modern_cli_eza_enabled` |
| `ll` | `eza -l --icons` | modern_cli | `modern_cli_eza_enabled` |
| `la` | `eza -lah --icons` | modern_cli | `modern_cli_eza_enabled` |
| `lt` | `eza --tree --icons` | modern_cli | `modern_cli_eza_enabled` |
| `cd` | `z` (zoxide) | modern_cli | `modern_cli_zoxide_enabled` |
| `emoji()` | fzf emoji picker → `wl-copy` | modern_cli | `modern_cli_emoji_fzf_enabled` (needs fzf + wl-copy) |
| `mmdc()` | mermaid-cli via system Chrome | modern_cli | `modern_cli_presenterm_enabled` |
| `y()` | yazi, then `cd` to its exit directory | modern_cli | `modern_cli_yazi_enabled` |
| `ch()` | `cliphist` history → fzf → `wl-copy` | clipboard_tools | `clipboard_tools_cliphist_enabled` (needs fzf + wl-copy) |
| `clipboard` | `clipse` | clipboard_tools | `clipboard_tools_clipse_enabled` |
| `vi`, `vim` | `nvim` | cli_dev_env | `cli_dev_env_neovim_enabled` |
| `ki` | `kiro-cli chat --trust-all-tools` (autonomous) | cli_dev_env | `cli_dev_env_kiro_enabled` + `cli_dev_env_kiro_deploy_shell_aliases` |
| `kil` | `kiro-cli login` | cli_dev_env | `cli_dev_env_kiro_enabled` + `cli_dev_env_kiro_deploy_shell_aliases` |
| `oc` | `opencode` (interactive TUI) | cli_dev_env | `cli_dev_env_opencode_enabled` + `cli_dev_env_opencode_deploy_shell_aliases` |
| `ocr` | `opencode run` (headless prompt) | cli_dev_env | `cli_dev_env_opencode_enabled` + `cli_dev_env_opencode_deploy_shell_aliases` |
| `asl` | `aws sso login` | cloud_cli | `cloud_cli_aws_enabled` |
| `tfaa` | `terraform apply -auto-approve` | cloud_cli | `cloud_cli_terraform_enabled` |
| `tfsl` | `terraform state list` | cloud_cli | `cloud_cli_terraform_enabled` |
| `tfss` | `terraform state show` | cloud_cli | `cloud_cli_terraform_enabled` |
| `vault-login()` | `vault login --method=github` (token from `~/.config/vault/github_token`) | cloud_cli | `cloud_cli_terraform_enabled` + `cloud_cli_vault_addr` set |

The `cli_dev_env` role also sets `EDITOR=nvim`/`VISUAL=nvim`, `base` and
`cloud_cli` set Vault/AWS/Terraform environment variables, and `modern_cli`
sets an `FZF_DEFAULT_OPTS` theme; the `ki`/`kil` alias names are configurable
(`cli_dev_env_kiro_alias_chat` / `cli_dev_env_kiro_alias_login`) as are the
`oc`/`ocr` alias names (`cli_dev_env_opencode_alias_tui` /
`cli_dev_env_opencode_alias_run`). See each
role's README for the authoritative list.

## apt package versions are unpinned

Packages installed via `ansible.builtin.apt` from a real, enabled repository
(Ubuntu archive, or a vendor's own apt repo — Docker, HashiCorp, GitHub CLI,
Brave, OnlyOffice, LibreWolf-via-extrepo) are installed unpinned
(`state: present`), not exact-version-pinned and dpkg-held. This is a
deliberate departure from this collection's usual "pin everything, Renovate
tracks it" convention, for apt packages specifically:

- **Holding breaks every future version bump.** apt refuses to change a
  dpkg-held package's version without `--allow-change-held-packages`. Any
  Renovate bump (or manual fix) of a pinned+held package's version failed
  to apply on any machine that had already run the playbook once, with
  `Held packages were changed and -y was used without
  --allow-change-held-packages` — confirmed in both `--check` and real
  runs. The three packages that stay pinned (`trivy`, `dust`, `yazi` — see
  below) now pass `allow_change_held_packages: true` on their own install
  task specifically to survive a stale hold left by an older version of
  this collection; every other apt-installed package here is unpinned
  instead, so no version is ever requested that could conflict with a
  hold in the first place.
- **Pins rot out of the archive independently.** A subset of these pins also
  tracked a Renovate `registryUrl` pointed at the base release pocket
  (`suite=noble`), which never receives point-release/security patches —
  those only live in `noble-updates`/`noble-security`. A pin set from a real
  machine's installed version could silently go stale and become
  uninstallable once the archive rotated past it, with no automated way for
  Renovate to notice or propose a fix.

Ongoing security patching for these packages is left to whatever update
mechanism the host actually runs — this collection's job is ensuring the
tooling exists, not being the system's ongoing patch mechanism. Note that
the `base` role itself disables apt's periodic/unattended-upgrade timers
(`/etc/apt/apt.conf.d/99disable-periodic`), so on a machine provisioned by
this collection nothing patches these packages automatically unless the
host owner re-enables that or runs `apt upgrade` by hand. Tools downloaded
as release artifacts (GitHub releases, vendor-published binaries/tarballs/
`.deb` files fetched directly by URL) are unaffected and stay exact-pinned
and checksum-verified as usual; only real apt-repo-installed packages
changed.

**Migrating an already-provisioned machine:** a machine that already ran an
older version of this collection has these packages `dpkg`-held from
before this change — nothing in the new tasks ever unholds them, since a
plain `state: present` install with no version never touches an
already-held package's state. Run `sudo apt-mark unhold $(apt-mark showhold)`
once (or list the specific packages) after upgrading to unblock both this
collection's own installs and any future manual `apt upgrade`. The three
packages that stay pinned (`trivy`, `dust`, `yazi` — see their roles) don't
need this: their install tasks now pass `allow_change_held_packages: true`
so a stale hold from an older role version can't block their own version
bumps.

## Continuous Integration

`lint-full` (in `ci.yml`) and Molecule (`molecule.yml`) call reusable workflows in
[PMuellerCH/shared-actions](https://github.com/PMuellerCH/shared-actions), pinned to
`@v1` (`ansible_lint.yml` and `ansible_molecule.yml`), both with
`python-version: 3.14` and `install-self-collection: true`. `lint-changed` runs
pre-commit directly, after setting up the environment via the shared `ansible-setup`
action. Release
(`release-please.yml`) runs
[googleapis/release-please-action](https://github.com/googleapis/release-please-action)
directly — no shared workflow and no GitHub App secrets — with `contents: write` and
`pull-requests: write` permissions.

CI only tests what a PR changed; the full suite runs on the release PR (or manual dispatch):

| Event | Lint (`ci.yml`) | Molecule (`molecule.yml`) |
| --- | --- | --- |
| Any PR to `main` (feature, fix, Renovate) | `lint-changed`: pre-commit on files changed vs. `origin/main` | Only roles whose own files changed |
| release-please PR | `lint-full`: complete shared lint suite | Full matrix of every role with a scenario |
| `workflow_dispatch` | `lint-full` | Full matrix |

Details and limits:

- `lint-changed` runs `pre-commit run --from-ref origin/<base> --to-ref HEAD`, or
  `--all-files` when the PR changes lint config (`.pre-commit-config.yaml`, `.yamllint.yml`,
  `.ansible-lint`, `.markdownlint-*.yml`, `.github/requirements.txt`). Checkov
  cannot take a file list, so it still scans the whole repo on every run. Ansible-lint
  only sees changed files under `roles/`, `meta/` and the root `galaxy.yml` /
  `requirements*.yml`, so a cross-role problem is only caught by `lint-full` on the
  release PR.
- `lint-changed` also runs the generic and secret-scanning pre-commit hooks
  (detect-secrets, whitespace, end-of-file, check-yaml, private-key, large-file), which
  `lint-full` does not; `lint-full` is the four shared linters (yamllint, ansible-lint,
  markdownlint, checkov).
- Molecule auto-discovers every role with a `roles/<name>/molecule/default/` scenario.
  README.md and `meta/` changes inside a role do not count as a role change. A change to
  a shared file (`requirements.yml`, `requirements-molecule.yml`, `galaxy.yml`, the
  molecule-relevant pins in `.github/requirements.txt` or `molecule.yml` itself) runs the
  full matrix.
- A PR that changes no role skips the Molecule job (a skipped check counts as passing).
- Troubleshooting: if `lint-changed` fails but a local run passes, run
  `pre-commit run --from-ref origin/main --to-ref HEAD` after `git fetch origin main`
  to reproduce exactly what CI sees.

Renovate is self-contained in this repo's `renovate.json` — it no longer extends a shared
preset. It extends `config:recommended` and `:enablePreCommit`, defines its own
`pip_requirements` manager (covering root and `.github/` requirements files), pins
`ansible-core` to the 2.21.x line (2.22+ needs Python 3.13, but the target Ubuntu 24.04
ships Python 3.12) while still skipping the broken 2.21.0, and carries three custom regex
managers for
version strings the recommended config does not see: role `defaults/main.yml`, the root
`requirements.yml` / `requirements-molecule.yml`, and per-role `files/requirements.yml`.

Automerge is driven entirely by `renovate.json`, not by a shared approval workflow. The
config sets `platformAutomerge: false` and a package rule that marks minor, patch, pin and
digest updates `automerge: true` with `automergeStrategy: squash`, so Renovate merges them
itself (squashed) once CI passes; major and breaking updates always stay on manual review.
If a Renovate PR stops merging, check that lint and Molecule are green on the PR head.

## License

[MIT](LICENSE)
