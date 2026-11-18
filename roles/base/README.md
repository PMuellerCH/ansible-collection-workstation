# pmuellerch.workstation.base

Foundational workstation setup: base system packages, hostname, locale, corporate
proxy, git, SSH, the Python toolchain, and fonts. This role must run **first** —
every other role in the collection assumes locale, proxy, and hostname are already
configured.

Base packages, git, SSH, Python, and fonts are one role because none of them carry
consumer-specific data and all are foundational enough that a real workstation
always wants all of them. Per-tool granularity is preserved via task tags
(`base`, `git`, `ssh`, `python`, `fonts`) so `--tags <tool>` still runs only that
slice — see [Tags](#tags).

## What it does

- Installs core system packages (`curl`, `jq`, `yq`, `unzip`, `dnsutils`,
  `cifs-utils`, `pwgen`, `openssl`, `direnv`, `open-vm-tools`, `locales`,
  `hunspell-de-ch`, `hunspell-en-us`).
- Sets the hostname (`ansible.builtin.hostname`, persisted to `/etc/hostname`).
- Generates and deploys `de_CH.UTF-8`/`en_US.UTF-8` locales to the shell, the
  systemd user session, and GNOME dconf.
- On VMware, installs `open-vm-tools` and a clipboard-integration autostart entry.
- Disables apt's periodic update popups.
- **Corporate proxy** (only when `base_http_proxy` is set): deploys proxy
  environment variables to the systemd user session (Electron apps like Slack),
  the Flatpak sandbox global override (Spotify), `/etc/environment`, `~/.npmrc`,
  and GNOME dconf (`base_desktop_environment == 'gnome'` only); installs the
  corporate proxy CA certificate into the system trust store and syncs it to a
  Flatpak-accessible bundle; sets `NODE_EXTRA_CA_CERTS` and `UV_SYSTEM_CERTS`
  in `/etc/environment` so Node.js and `uv`/`uvx` (neither of which reads the
  OS trust store by default) trust the corporate CA too.
- Installs git and configures global identity/editor/pull-push defaults, plus
  optional SSH-based commit/tag signing.
- Creates `~/.ssh/` and `~/.config/ssh/`, deploys a config that routes GitHub SSH
  over port 443 (works through restrictive firewalls), symlinks `~/.ssh/config`
  to it, fixes key permissions if present, and injects `base_ssh_extra_hosts`
  entries. Does **not** generate SSH keys — copy them from another machine first.
- Installs `build-essential`, `python3-pip`, `python3-venv` via apt, and
  `uv`/`uvx` from the GitHub release tarball to `/usr/local/bin/`.
- Installs JetBrains Mono Nerd Font to `~/.local/share/fonts/` and refreshes the
  font cache; a version stamp file skips re-download when already current.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No dependency on any other role — `base` is meant to be the first role a
consuming playbook runs.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `base_hostname` | *(required)* | Hostname to assign to the machine |
| `base_locale_format` | `de_CH.UTF-8` | Locale for date/time, number, currency, paper, and measurement formats |
| `base_locale_ui` | `en_US.UTF-8` | Locale for UI display language and error messages |
| `base_http_proxy` | `""` | Corporate HTTP proxy URL; leave empty on machines without a proxy |
| `base_https_proxy` | `base_http_proxy` | Corporate HTTPS proxy URL; set explicitly only if HTTP and HTTPS use different proxies |
| `base_no_proxy` | `""` | Comma-separated list of hosts/CIDRs that bypass the proxy |
| `base_vault_addr` | `""` | HashiCorp Vault address, exported as `VAULT_ADDR`; leave empty without Vault access |
| `base_desktop_environment` | `gnome` | `gnome` or `cosmic`; controls which proxy integration path is applied |
| `base_git_user_name` | *(required)* | Value for git's global `user.name` |
| `base_git_user_email` | *(required)* | Value for git's global `user.email` |
| `base_git_default_branch` | `main` | Value for git's global `init.defaultBranch` |
| `base_git_pull_rebase` | `true` | Whether `git pull` rebases instead of merges |
| `base_git_push_default` | `simple` | Value for git's global `push.default` |
| `base_git_editor` | `vim` | Value for git's global `core.editor` |
| `base_git_signing_enabled` | `true` | Configure SSH-based commit/tag signing |
| `base_git_signing_key` | `{{ ansible_facts['env']['HOME'] }}/.ssh/id_ed25519.pub` | Path to the SSH public key used as git's `user.signingkey` |
| `base_ssh_extra_hosts` | `[]` | Extra SSH host blocks (`name`, `hostname`, `user`, optional `identity_file`) |
| `base_python_uv_version` | see `defaults/main.yml` | `uv` version (github-releases `astral-sh/uv`) |
| `base_fonts_nerd_font_version` | see `defaults/main.yml` | Nerd Fonts release version (github-releases `ryanoasis/nerd-fonts`) |

All other packages installed by this role (`curl`, `jq`, `yq`, `unzip`, `dnsutils`,
`cifs-utils`, `pwgen`, `openssl`, `direnv`, `open-vm-tools`, `locales`,
`hunspell-de-ch`, `hunspell-en-us`, `git`, `build-essential`, `python3-pip`,
`python3-venv`, `fontconfig`) are installed unpinned from the Ubuntu apt
archive — see [Notes](#notes) for why.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.base
      vars:
        base_hostname: my-machine
        base_git_user_name: Jane Doe
        base_git_user_email: jane@example.com
        base_git_editor: nvim
        base_http_proxy: "http://proxy.example.com:8080"
        base_https_proxy: "http://proxy.example.com:8080"
        base_no_proxy: "localhost,127.0.0.1,example.com"
        base_vault_addr: "https://vault.example.com:8200"
        base_ssh_extra_hosts:
          - name: my-server
            hostname: 10.0.0.5
            user: admin
            identity_file: "~/.ssh/admin_key"
```

## Tags

Every task carries its own tag(s) in addition to the umbrella `base` tag, so a
consuming playbook can filter to a single tool slice:

| Slice | Tags |
| --- | --- |
| Core packages, hostname, locale, proxy | `base` |
| git | `git`, `base` |
| SSH | `ssh`, `base` |
| Python toolchain (`uv`) | `python`, `base` |
| Fonts | `fonts`, `base` |

**Do not** put an outer `tags:` on the role invocation in your play — that tag
cascades to every task in the role and defeats this per-tool filtering.

## Notes

- The corporate proxy CA cert bundled in `files/BITProxyCA06C.crt` is the
  currently active intermediate (valid until Sep 2026) — must be replaced when
  corporate IT rotates to a new CA generation.
- `community.general.dconf` (locale, proxy) requires a running D-Bus session —
  run this role while logged into a graphical session, not over a headless SSH
  connection.
- `base_vault_addr` is exported via `~/.config/zsh/conf.d/base-vault.zsh` —
  deliberately not `vault.zsh`, which `iac_tools` owns for its own (richer)
  Vault shell integration when terraform/vault are enabled. Set both
  `base_vault_addr` and `iac_tools_vault_addr` to the same value if you use
  both roles together.
- On machines that ran an older version of this role (pre the `base-vault.zsh`
  rename), the role auto-removes a legacy `~/.config/zsh/conf.d/vault.zsh`
  left over from before — but only if its content is still the old
  single-line `export VAULT_ADDR=...` snippet, never an `iac_tools`-managed
  `vault.zsh`.
- All apt-installed packages (see the note under Role Variables above) are
  installed unpinned via `state: present`, not exact-version-pinned and
  dpkg-held. Pinning+holding an apt package breaks the next version bump on
  any machine that already ran the playbook once — apt refuses to change a
  held package's version without `--allow-change-held-packages` — and a
  subset of pins also rotted out of the Ubuntu archive entirely (point-release
  patches only live in the `-updates`/`-security` pockets, not the base
  release pocket). Ongoing security patching for these packages is the host's
  own `apt upgrade`/unattended-upgrades responsibility, outside this role's
  remit; `uv`/`uvx` and Nerd Fonts stay pinned+checksummed since those are
  downloaded release artifacts, not apt-repo packages, and don't have this
  failure mode.
