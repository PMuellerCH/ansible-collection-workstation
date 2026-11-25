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
proxy, hostname, and fonts that other roles are written to assume are
already in place.

| Role | What it installs |
| --- | --- |
| [base](roles/base/README.md) | Base system packages, hostname, locale, corporate proxy, SSH, Python toolchain, Node.js, fonts — run first |
| [git](roles/git/README.md) | git config (identity, SSH signing), GitHub CLI, lazygit, delta |
| [editor](roles/editor/README.md) | neovim (LazyVim), presenterm + mermaid-cli |
| [ai_cli](roles/ai_cli/README.md) | Claude Code CLI, Kiro CLI, OpenCode |
| [cli_tools](roles/cli_tools/README.md) | bat, btop, eza, fd, fzf, htop, ripgrep, zoxide, emoji-fzf, sd, duf, gping, hexyl, procs, dust, viddy, xcp, doggo, jaq, moor, yazi |
| [code_quality_tools](roles/code_quality_tools/README.md) | trivy, pre-commit, detect-secrets, yamllint, checkov, ansible-lint |
| [desktop_apps](roles/desktop_apps/README.md) | OnlyOffice, Firefox policies, Brave, LibreWolf, Slack, Microsoft Teams |
| [desktop_integration](roles/desktop_integration/README.md) | GNOME workspaces and keybindings, Flameshot, emoji picker (smile), Wayland clipboard tooling (wl-clipboard, cliphist, clipse) |
| [ansible_dev](roles/ansible_dev/README.md) | ansible-core (pipx) + molecule, Docker CE, act |
| [cloud_cli](roles/cloud_cli/README.md) | AWS CLI + session-manager-plugin, Terraform/Vault, tfswitch, tflint, terraform-docs, floci |
| [k8s_tools](roles/k8s_tools/README.md) | kubectl, k9s, helm, kubectx/kubens, stern, krew, kubeconform, kube-linter |
| [maintenance](roles/maintenance/README.md) | apt update/safe-upgrade, autoremove/autoclean, journal vacuum, Docker prune, Flatpak cleanup — for a separate maintenance playbook, not `site.yml` |
| [terminal_env](roles/terminal_env/README.md) | zsh, tmux, kitty |
| [bitwarden](roles/bitwarden/README.md) | Bitwarden password manager desktop app |
| [synology](roles/synology/README.md) | Synology Drive and Chat clients |
| [betterbird](roles/betterbird/README.md) | Betterbird (Thunderbird fork) email client |
| [media](roles/media/README.md) | Inkscape, GIMP, Pinta, beets, Spotify + ncspot, Plex Desktop and Plexamp — each independently toggleable |

Every role uses per-tool Ansible tags (in addition to an umbrella
`<role_name>` tag) so a consuming playbook can select a single tool with
`--tags <tool>` — see each role's own README for its tag table.

## Example: provisioning a developer workstation

Copy-paste starting point for bringing up a fresh Ubuntu 24.04
IaC developer workstation. Install the collection, then run a playbook that
applies the roles in the recommended order (`base` first: it installs the
NodeSource Node.js that `ai_cli` (Claude Code) needs and `editor`'s mermaid-cli
prefers).

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
    # --- required (these roles have no defaults for them) ---
    base_hostname: my-workstation
    git_user_name: "Jane Doe"
    git_user_email: jane.doe@example.com
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
    ai_cli_claude_code_github_token: "{{ lookup('ansible.builtin.env', 'GITHUB_PAT') }}"
  roles:
    # 1. base first: locale, corporate proxy, hostname, SSH, Python, Node.js, fonts.
    - role: pmuellerch.workstation.base
    # 2. git config, GitHub CLI, lazygit, delta.
    - role: pmuellerch.workstation.git
    # 3. terminal shell + multiplexer + terminal emulator.
    - role: pmuellerch.workstation.terminal_env
    # 4. editor (neovim/LazyVim, presenterm), AI coding agents (needs base's Node.js
    #    for Claude Code) and the modern CLI replacements.
    - role: pmuellerch.workstation.editor
    - role: pmuellerch.workstation.ai_cli
    - role: pmuellerch.workstation.cli_tools
    # 5. the infra toolchain.
    #    ansible_dev must come before cloud_cli and k8s_tools: it creates the
    #    ansible-core pipx venv they inject boto3 / the Python Kubernetes
    #    libraries into (they skip the inject if it doesn't exist yet).
    - role: pmuellerch.workstation.ansible_dev
    - role: pmuellerch.workstation.cloud_cli
    - role: pmuellerch.workstation.k8s_tools
    # 6. code-quality / security scanners.
    - role: pmuellerch.workstation.code_quality_tools
    # 7. desktop apps (browsers, office, chat) and desktop integration (workspaces,
    #    Flameshot, clipboard tooling) — GUI, skip on a headless box.
    - role: pmuellerch.workstation.desktop_apps
    - role: pmuellerch.workstation.desktop_integration
    # 8. media and graphics tools (home machines): add pmuellerch.workstation.media.
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

## Migrating from `cli_dev_env`, `modern_cli` and `gh`

`cli_dev_env`, `modern_cli` and `gh` were split into `git`, `editor`, `ai_cli` and `cli_tools`, and `base` lost its git
part and gained Node.js (a breaking change; variables were renamed with no aliases).

| Old | New |
| --- | --- |
| `base_git_*` | `git_*` (`git_user_name`, `git_user_email`, `git_default_branch`, `git_pull_rebase`, `git_push_default`, `git_editor`, `git_signing_enabled`, `git_signing_key`) |
| `cli_dev_env_lazygit_*` | `git_lazygit_*` |
| `modern_cli_delta_*` | `git_delta_*` |
| the `gh` role | `git` (`git_gh_enabled`) |
| `cli_dev_env_neovim_*`, `cli_dev_env_github_api_token` | `editor_neovim_*`, `editor_github_api_token` |
| `cli_dev_env_neovim_presenterm_plugin_enabled` | `editor_presenterm_plugin_enabled` |
| `modern_cli_presenterm_*` | `editor_presenterm_*` |
| `cli_dev_env_claude_code_*`, `_kiro_*`, `_opencode_*` | `ai_cli_claude_code_*`, `ai_cli_kiro_*`, `ai_cli_opencode_*` |
| `cli_dev_env_claude_code_nodejs_major_version` | `base_nodejs_major_version` (plus `base_nodejs_enabled`) |
| `modern_cli_<tool>_*` (all other tools) | `cli_tools_<tool>_*` |

Run `base` before `ai_cli`: Node.js moved into `base`, and Claude Code now fails with a clear message instead of
installing Node.js itself when npm is missing. Tags: the umbrella tags are `git`, `editor`, `ai_cli` and `cli_tools`;
`claude-code`, `kiro`, `opencode`, `neovim`, `presenterm`, `lazygit` and `delta` are unchanged, the `cli-tools` tag is
gone (each tool has its own), and `base` has new component tags (`system`, `proxy`, `nodejs`, plus the existing `ssh`,
`python`, `fonts`). The zsh snippet `modern_cli.zsh` is replaced by `cli_tools.zsh`, `git.zsh` (delta alias) and
`presenterm.zsh` (mmdc wrapper); the old file is removed.

## Migrating the desktop and media roles

`chat_clients`, `clipboard_tools`, `desktop_customization`, `graphics` and `multimedia` were merged into
`desktop_apps`, `desktop_integration` and `media` (a breaking change; variables were renamed with no aliases).

| Old | New |
| --- | --- |
| `chat_clients_*` | `desktop_apps_*` (`desktop_apps_slack_enabled`, `desktop_apps_teams_*`) |
| `desktop_customization_*`, `clipboard_tools_*` | `desktop_integration_*` (new switches: `_workspaces_enabled`, `_flameshot_enabled`; new `_cliphist_download_base`) |
| `multimedia_*` | `media_*` (new switches: `_graphics_enabled`, `_beets_enabled`, `_spotify_enabled`, `_plex_enabled`; new `_ncspot_download_base`) |
| the `graphics` role (no variables) | `media` (`media_graphics_enabled`) |

Tags are unchanged (`slack`, `teams`, `gui-customization`, `flameshot`, `emoji-picker`, `wl-clipboard`, `cliphist`,
`clipse`, `beets`, `spotify`, `plex`); the umbrella tags are `desktop_apps`, `desktop_integration` and `media`, and
`graphics` now selects Inkscape, GIMP and Pinta. The zsh snippet `clipboard_tools.zsh` is replaced by
`desktop_integration.zsh`; the old file is removed. The ncspot download is now checksum-verified.

## Shell aliases

Several roles deploy zsh snippets to `~/.config/zsh/conf.d/*.zsh`. They take
effect only in an interactive zsh that sources that directory —
`terminal_env`'s `.zshrc` does this. Most `cli_tools` and `desktop_integration`
entries, and the `ai_cli` Kiro (`ki`/`kil`) and OpenCode (`oc`/`ocr`)
aliases, are additionally
guarded by a `command -v` check so they are defined only when the tool is
actually installed; the `editor` `vi`/`vim` and the `cloud_cli` entries
are plain aliases gated only by the role variable in the last column.
Items written as `name()` are shell functions rather than plain aliases.

| Alias / function | Runs | Role | Enabled by |
| --- | --- | --- | --- |
| `cat` | `batcat --paging=never` | cli_tools | `cli_tools_bat_enabled` |
| `top` | `btop` | cli_tools | `cli_tools_btop_enabled` |
| `grep` | `rg` | cli_tools | `cli_tools_ripgrep_enabled` |
| `find` | `fd` | cli_tools | `cli_tools_fd_enabled` |
| `sed` | `sd` | cli_tools | `cli_tools_sd_enabled` |
| `ps` | `procs` | cli_tools | `cli_tools_procs_enabled` |
| `du` | `dust` | cli_tools | `cli_tools_dust_enabled` |
| `df` | `duf` | cli_tools | `cli_tools_duf_enabled` |
| `diff` | `delta` | git | `git_delta_enabled` + `git_deploy_shell_aliases` |
| `ping` | `gping` | cli_tools | `cli_tools_gping_enabled` |
| `watch` | `viddy` | cli_tools | `cli_tools_viddy_enabled` |
| `less` | `moor` | cli_tools | `cli_tools_moor_enabled` |
| `cp` | `xcp` | cli_tools | `cli_tools_xcp_enabled` |
| `dig` | `doggo` | cli_tools | `cli_tools_doggo_enabled` |
| `jq` | `jaq` | cli_tools | `cli_tools_jaq_enabled` |
| `hexdump` | `hexyl` | cli_tools | `cli_tools_hexyl_enabled` |
| `ls`, `l` | `eza --icons` | cli_tools | `cli_tools_eza_enabled` |
| `ll` | `eza -l --icons` | cli_tools | `cli_tools_eza_enabled` |
| `la` | `eza -lah --icons` | cli_tools | `cli_tools_eza_enabled` |
| `lt` | `eza --tree --icons` | cli_tools | `cli_tools_eza_enabled` |
| `cd` | `z` (zoxide) | cli_tools | `cli_tools_zoxide_enabled` |
| `emoji()` | fzf emoji picker → `wl-copy` | cli_tools | `cli_tools_emoji_fzf_enabled` (needs fzf + wl-copy) |
| `mmdc()` | mermaid-cli via system Chrome | editor | `editor_presenterm_enabled` |
| `y()` | yazi, then `cd` to its exit directory | cli_tools | `cli_tools_yazi_enabled` |
| `ch()` | `cliphist` history → fzf → `wl-copy` | desktop_integration | `desktop_integration_cliphist_enabled` + `desktop_integration_deploy_shell_aliases` (needs fzf + wl-copy) |
| `clipboard` | `clipse` | desktop_integration | `desktop_integration_clipse_enabled` + `desktop_integration_deploy_shell_aliases` |
| `vi`, `vim` | `nvim` | editor | `editor_neovim_enabled` |
| `ki` | `kiro-cli chat --trust-all-tools` (autonomous) | ai_cli | `ai_cli_kiro_enabled` + `ai_cli_kiro_deploy_shell_aliases` |
| `kil` | `kiro-cli login` | ai_cli | `ai_cli_kiro_enabled` + `ai_cli_kiro_deploy_shell_aliases` |
| `oc` | `opencode` (interactive TUI) | ai_cli | `ai_cli_opencode_enabled` + `ai_cli_opencode_deploy_shell_aliases` |
| `ocr` | `opencode run` (headless prompt) | ai_cli | `ai_cli_opencode_enabled` + `ai_cli_opencode_deploy_shell_aliases` |
| `asl` | `aws sso login` | cloud_cli | `cloud_cli_aws_enabled` |
| `tfaa` | `terraform apply -auto-approve` | cloud_cli | `cloud_cli_terraform_enabled` |
| `tfsl` | `terraform state list` | cloud_cli | `cloud_cli_terraform_enabled` |
| `tfss` | `terraform state show` | cloud_cli | `cloud_cli_terraform_enabled` |
| `vault-login()` | `vault login --method=github` (token from `~/.config/vault/github_token`) | cloud_cli | `cloud_cli_terraform_enabled` + `cloud_cli_vault_addr` set |

The `editor` role also sets `EDITOR=nvim`/`VISUAL=nvim`, `base` and
`cloud_cli` set Vault/AWS/Terraform environment variables, and `cli_tools`
sets an `FZF_DEFAULT_OPTS` theme; the `ki`/`kil` alias names are configurable
(`ai_cli_kiro_alias_chat` / `ai_cli_kiro_alias_login`) as are the
`oc`/`ocr` alias names (`ai_cli_opencode_alias_tui` /
`ai_cli_opencode_alias_run`). See each
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
| Any PR to `main` (feature, fix, Renovate) | `lint-changed`: pre-commit on files changed vs. `origin/main` | Only roles whose own files changed (plus declared dependent paths) |
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
- A role whose molecule scenario uses another role's files lists those paths (one `dorny/paths-filter` glob per line;
  `#` comments and blank lines allowed) in `roles/<role>/molecule/dependent_paths.txt`; a change to them also re-runs
  that role's scenario. Examples: `ai_cli` depends on `base`'s nodejs component, `cloud_cli` on `ansible_dev`. Keep
  the file in sync with `prepare.yml`/`converge.yml`.
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

Supply-chain hardening: third-party GitHub Actions are pinned to full commit SHAs with the
version in a trailing comment (`uses: owner/action@<sha> # v7`); Renovate keeps both in sync
(`helpers:pinGitHubActionDigests`). `PMuellerCH/shared-actions` is deliberately excluded and
stays on the floating `@v1` tag. `minimumReleaseAge: "3 days"` with `internalChecksFilter: "strict"`
holds every update PR (and therefore automerge) back until the release is 3 days old, so a
freshly published, possibly compromised release is not merged immediately.

## License

[MIT](LICENSE)
