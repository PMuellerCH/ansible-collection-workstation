# infra-ansible-collection-workstation

[![CI](https://github.com/PMuellerCH/infra-ansible-collection-workstation/actions/workflows/ci.yml/badge.svg)](https://github.com/PMuellerCH/infra-ansible-collection-workstation/actions/workflows/ci.yml)

An Ansible Collection (`swisstopo.workstation`) for provisioning and maintaining
IaC developer workstations running Ubuntu 24.04 with the COSMIC or GNOME desktop
environment.

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
| [iac_tools](roles/iac_tools/README.md) | ansible-core, Docker CE, AWS CLI, Terraform/Vault, Kubernetes toolchain |
| [maintenance](roles/maintenance/README.md) | apt update/safe-upgrade, autoremove/autoclean, journal vacuum, Docker prune, Flatpak cleanup — for a separate maintenance playbook, not `site.yml` |
| [modern_cli](roles/modern_cli/README.md) | bat, btop, eza, fd, fzf, htop, presenterm, ripgrep, zoxide, emoji-fzf |
| [terminal_env](roles/terminal_env/README.md) | zsh, tmux, kitty |

Every role uses per-tool Ansible tags (in addition to an umbrella
`<role_name>` tag) so a consuming playbook can select a single tool with
`--tags <tool>` — see each role's own README for its tag table.

## Example: provisioning a standard swisstopo dev workstation

Copy-paste starting point for a colleague bringing up a fresh Ubuntu 24.04
IaC developer workstation. Install the collection, then run a playbook that
applies the roles in the recommended order (`base` first; `cli_dev_env`
before `modern_cli` so the NodeSource Node.js is in place before
`modern_cli`'s mermaid-cli check — see the `cli_dev_env` README).

Install the collection from this repository (it is distributed via git tags,
not published to Ansible Galaxy). Pin the tag in a `requirements.yml` — use the
first release that contains the Kiro-into-`cli_dev_env` merge or newer (the
`1.3.0` tag still ships the old standalone `kiro_cli` role, so the example
below does not match it):

```yaml
# requirements.yml
collections:
  - name: https://github.com/PMuellerCH/infra-ansible-collection-workstation.git
    type: git
    version: "2.0.0"  # pin to a released tag >= the Kiro merge
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
- name: Provision a swisstopo IaC developer workstation
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
    base_git_user_email: jane.doe@swisstopo.ch
    # --- corporate network (leave "" off-network) ---
    base_http_proxy: "http://proxy.example.swisstopo.ch:8080"
    iac_tools_http_proxy: "{{ base_http_proxy }}"
    # --- Vault (enables the vault-login shell helper) ---
    base_vault_addr: "https://vault.example.swisstopo.ch"
    iac_tools_vault_addr: "{{ base_vault_addr }}"
    # vault-login also needs a GitHub token written to ~/.config/vault/github_token:
    iac_tools_terraform_vault_github_token: "{{ lookup('ansible.builtin.env', 'VAULT_GITHUB_PAT') }}"
    # --- Claude Code github MCP server token (from your own secret store) ---
    cli_dev_env_claude_code_github_token: "{{ lookup('ansible.builtin.env', 'GITHUB_PAT') }}"
  roles:
    # 1. base first: locale, corporate proxy, hostname, git, SSH, Python, fonts.
    - role: swisstopo.workstation.base
    # 2. terminal shell + multiplexer + terminal emulator.
    - role: swisstopo.workstation.terminal_env
    # 3. CLI dev environment: lazygit, neovim/LazyVim, Claude Code, Kiro CLI,
    #    OpenCode. Runs before modern_cli so its NodeSource Node.js wins on PATH.
    - role: swisstopo.workstation.cli_dev_env
    # 4. modern CLI replacements (bat, eza, fd, fzf, ripgrep, zoxide, ...).
    - role: swisstopo.workstation.modern_cli
    # 5. clipboard tooling (Wayland), GitHub CLI, IaC toolchain.
    - role: swisstopo.workstation.clipboard_tools
    - role: swisstopo.workstation.gh
    - role: swisstopo.workstation.iac_tools
    # 6. code-quality / security scanners.
    - role: swisstopo.workstation.code_quality_tools
    # 7. desktop apps and customization (GUI — skip on a headless box).
    - role: swisstopo.workstation.desktop_apps
    - role: swisstopo.workstation.desktop_customization
    - role: swisstopo.workstation.chat_clients
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

## Shell aliases

Several roles deploy zsh snippets to `~/.config/zsh/conf.d/*.zsh`. They take
effect only in an interactive zsh that sources that directory —
`terminal_env`'s `.zshrc` does this. Most `modern_cli` and `clipboard_tools`
entries, and the `cli_dev_env` Kiro (`ki`/`kil`) and OpenCode (`oc`/`ocr`)
aliases, are additionally
guarded by a `command -v` check so they are defined only when the tool is
actually installed; the `cli_dev_env` `vi`/`vim` and the `iac_tools` entries
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
| `asl` | `aws sso login` | iac_tools | `iac_tools_aws_enabled` |
| `tfaa` | `terraform apply -auto-approve` | iac_tools | `iac_tools_terraform_enabled` |
| `tfsl` | `terraform state list` | iac_tools | `iac_tools_terraform_enabled` |
| `tfss` | `terraform state show` | iac_tools | `iac_tools_terraform_enabled` |
| `vault-login()` | `vault login --method=github` (token from `~/.config/vault/github_token`) | iac_tools | `iac_tools_terraform_enabled` + `iac_tools_vault_addr` set |

The `cli_dev_env` role also sets `EDITOR=nvim`/`VISUAL=nvim`, `base` and
`iac_tools` set Vault/AWS/Terraform environment variables, and `modern_cli`
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

Lint (`ci.yml`) and Molecule (`molecule.yml`) run as thin wrappers around reusable
workflows in
[PMuellerCH/shared-actions](https://github.com/PMuellerCH/shared-actions), pinned to
`@v1` (`ansible_lint.yml` and `ansible_molecule.yml`), both called with
`python-version: 3.14` and `install-self-collection: true`. Release
(`release-please.yml`) runs
[googleapis/release-please-action](https://github.com/googleapis/release-please-action)
directly — no shared workflow and no GitHub App secrets — with `contents: write` and
`pull-requests: write` permissions.

`ci.yml` runs the lint job on every `pull_request` to `main` (it no longer runs on push)
with read-only `contents` permission.

Molecule auto-discovers every role with a `roles/<name>/molecule/default/` scenario and
runs it as a matrix job, but only on the release-please PR, a Renovate PR, or manual
`workflow_dispatch` — not on every ordinary feature PR, since a full matrix run is too
slow to gate routine iteration (those get fast lint-only feedback from `ci.yml` instead).
A Renovate PR tests only the role(s) whose own files changed; a change to a shared file
(`requirements-molecule.yml`, `galaxy.yml`) runs the full matrix.

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
