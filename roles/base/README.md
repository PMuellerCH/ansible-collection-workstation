# swisstopo.workstation.base

Foundational workstation setup, applied first on every machine: base system packages,
hostname, locale, corporate proxy, git, SSH, the Python toolchain, and fonts.

Merges what were five separate roles in the previous private implementation
(`base`, `git`, `ssh`, `python`, `fonts`) into one role, since none of them carry
consumer-specific data and all are foundational enough to belong together. Original
per-tool granularity is preserved via task tags (`base`, `git`, `ssh`, `python`,
`fonts`) so `--tags <tool>` still runs only that slice.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `base_hostname` | *(required)* | Hostname to assign to the machine |
| `base_locale_format` | `de_CH.UTF-8` | Locale for date/time, number, currency, paper, and measurement formats |
| `base_locale_ui` | `en_US.UTF-8` | Locale for UI display language and error messages |
| `base_http_proxy` | `""` | Corporate HTTP proxy URL; leave empty on machines without a proxy |
| `base_https_proxy` | `""` | Corporate HTTPS proxy URL |
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
| `base_git_signing_key` | `{{ HOME }}/.ssh/id_ed25519.pub` | Path to the SSH public key used as git's `user.signingkey` |
| `base_ssh_extra_hosts` | `[]` | Extra SSH host blocks (`name`, `hostname`, `user`, optional `identity_file`) |
| `base_python_uv_version` | see `defaults/main.yml` | `uv` version (github-releases `astral-sh/uv`) |
| `base_python_uv_checksum` | see `defaults/main.yml` | sha256 checksum of the `uv` release tarball |
| `base_python_build_essential_version` | see `defaults/main.yml` | `build-essential` apt package version |
| `base_python_pip_version` | see `defaults/main.yml` | `python3-pip` apt package version |
| `base_python_venv_version` | see `defaults/main.yml` | `python3-venv` apt package version |
| `base_fonts_fontconfig_version` | see `defaults/main.yml` | `fontconfig` apt package version |
| `base_fonts_unzip_version` | see `defaults/main.yml` | `unzip` apt package version (pinned independently of `base_unzip_version` so `--tags fonts` is self-sufficient) |
| `base_fonts_nerd_font_version` | see `defaults/main.yml` | Nerd Fonts release version (github-releases `ryanoasis/nerd-fonts`) |
| `base_fonts_nerd_font_checksum` | see `defaults/main.yml` | sha256 checksum of the JetBrainsMono Nerd Font zip |

All other apt-pinned base packages (`curl`, `jq`, `yq`, `unzip`, `dnsutils`, `cifs-utils`,
`pwgen`, `openssl`, `direnv`, `open-vm-tools`, `locales`, `hunspell-de-ch`,
`hunspell-en-us`) have their own `base_<pkg>_version` variables — see `defaults/main.yml`.

## Notes

- **base**: installs core packages needed on every machine; sets the hostname
  (`ansible.builtin.hostname`, persists to `/etc/hostname`); generates and deploys
  `de_CH.UTF-8`/`en_US.UTF-8` locales to the shell, systemd user session, and GNOME
  dconf; on VMware, installs `open-vm-tools` and a clipboard-integration autostart
  entry; disables apt's periodic update popups.
  - **Corporate proxy** (only when `base_http_proxy` is set): deploys proxy env vars
    to the systemd user session (Electron apps like Slack), the Flatpak sandbox
    global override (Spotify), `/etc/environment`, `~/.npmrc`, and GNOME dconf
    (`base_desktop_environment == 'gnome'` only); installs the corporate (BIT) proxy CA
    certificate into the system trust store and syncs it to a Flatpak-accessible
    bundle. The CA cert bundled in `files/BITProxyCA06C.crt` is the currently active
    intermediate (valid until Sep 2026) — must be replaced when corporate IT rotates
    to a new CA generation.
  - Must run first — other roles assume locale/proxy/hostname are already set.
- **git**: installs git, configures global identity/editor/pull-push defaults, and
  optionally SSH-based commit/tag signing.
- **ssh**: creates `~/.ssh/` and `~/.config/ssh/`, deploys a config that routes
  GitHub SSH over port 443 (works through restrictive firewalls), symlinks
  `~/.ssh/config` to it, fixes key permissions if present, and injects
  `base_ssh_extra_hosts` entries. Does not generate SSH keys — copy them from another
  machine first.
- **python**: installs `build-essential`, `python3-pip`, `python3-venv` via apt, and
  `uv`/`uvx` from the GitHub release tarball to `/usr/local/bin/`.
- **fonts**: installs JetBrains Mono Nerd Font to `~/.local/share/fonts/` and
  refreshes the font cache; a version stamp file skips re-download when already current.

## Example

```yaml
- role: swisstopo.workstation.base
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
