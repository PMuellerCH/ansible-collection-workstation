# pmuellerch.workstation.base

Foundational workstation setup: base system packages, hostname, locale, corporate
proxy, SSH, the Python toolchain, Node.js, and fonts. This role must run **first** —
every other role in the collection assumes locale, proxy, and hostname are already
configured.

Base packages, SSH, Python, Node.js, and fonts are one role because none of them carry
consumer-specific data and all are foundational enough that a real workstation
always wants all of them. The tasks are split into one file per component
(`system`, `proxy`, `ssh`, `python`, `nodejs`, `fonts`) behind a thin `tasks/main.yml`, and each
carries its own tag so `--tags <component>` runs only that slice — see [Tags](#tags). Git
configuration moved to the `git` role.

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
- Creates `~/.ssh/` and `~/.config/ssh/`, deploys a config that routes GitHub SSH
  over port 443 (works through restrictive firewalls), symlinks `~/.ssh/config`
  to it, fixes key permissions if present, and injects `base_ssh_extra_hosts`
  entries. Does **not** generate SSH keys — copy them from another machine first.
- Installs `python3-pip`, `python3-venv` via apt, and
  `uv`/`uvx` from the GitHub release tarball to `/usr/local/bin/`.
- Installs Node.js LTS (`base_nodejs_major_version`) and `build-essential` from the
  NodeSource apt repository. The `ai_cli` role (Claude Code) needs this and does not install Node.js itself;
  the `editor` role's mermaid-cli prefers it. Disable with `base_nodejs_enabled: false`.
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
| `base_proxy_ca_cert_content` | `""` | PEM content of the corporate proxy CA certificate; installed when `base_http_proxy` is set |
| `base_https_proxy` | `base_http_proxy` | Corporate HTTPS proxy URL; set explicitly only if HTTP and HTTPS use different proxies |
| `base_no_proxy` | `""` | Comma-separated list of hosts/CIDRs that bypass the proxy |
| `base_vault_addr` | `""` | HashiCorp Vault address, exported as `VAULT_ADDR`; leave empty without Vault access |
| `base_desktop_environment` | `gnome` | `gnome` or `cosmic`; controls which proxy integration path is applied |
| `base_nodejs_enabled` | `true` | Install Node.js (NodeSource) and `build-essential` |
| `base_nodejs_major_version` | `"24"` | Node.js LTS major version; selects the NodeSource apt repository |
| `base_nodejs_apt_key_fingerprint` | see `defaults/main.yml` | Pinned primary-key fingerprint of the NodeSource apt signing key |
| `base_ssh_extra_hosts` | `[]` | Extra SSH host blocks (`name`, `hostname`, `user`, optional `identity_file`) |
| `base_python_uv_version` | see `defaults/main.yml` | `uv` version (github-releases `astral-sh/uv`) |
| `base_fonts_nerd_font_version` | see `defaults/main.yml` | Nerd Fonts release version (github-releases `ryanoasis/nerd-fonts`) |

All other packages installed by this role (`curl`, `jq`, `yq`, `unzip`, `dnsutils`,
`cifs-utils`, `pwgen`, `openssl`, `direnv`, `open-vm-tools`, `locales`,
`hunspell-de-ch`, `hunspell-en-us`, `build-essential`, `python3-pip`,
`python3-venv`, `fontconfig`) are installed unpinned from the Ubuntu apt
archive — see [Notes](#notes) for why.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.base
      vars:
        base_hostname: my-machine
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
| Core packages, hostname, locale | `system`, `base` |
| Corporate proxy, CA certificate | `proxy`, `base` |
| SSH | `ssh`, `base` |
| Python toolchain (`uv`) | `python`, `base` |
| Node.js (NodeSource) | `nodejs`, `base` |
| Fonts | `fonts`, `base` |

**Do not** put an outer `tags:` on the role invocation in your play — that tag
cascades to every task in the role and defeats this per-tool filtering.

## Notes

- The corporate proxy CA certificate is not shipped with this collection. Pass
  its PEM content via `base_proxy_ca_cert_content` (e.g.
  `"{{ lookup('ansible.builtin.file', 'files/proxy-ca.crt') }}"`) and renew it
  there when corporate IT rotates to a new CA generation.
- `community.general.dconf` (locale, proxy) requires a running D-Bus session —
  run this role while logged into a graphical session, not over a headless SSH
  connection.
- `base_vault_addr` is exported via `~/.config/zsh/conf.d/base-vault.zsh` —
  deliberately not `vault.zsh`, which `cloud_cli` owns for its own (richer)
  Vault shell integration when terraform/vault are enabled. Set both
  `base_vault_addr` and `cloud_cli_vault_addr` to the same value if you use
  both roles together.
- On machines that ran an older version of this role (pre the `base-vault.zsh`
  rename), the role auto-removes a legacy `~/.config/zsh/conf.d/vault.zsh`
  left over from before — but only if its content is still the old
  single-line `export VAULT_ADDR=...` snippet, never a `cloud_cli`-managed
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

### NodeSource signing key (fingerprint-pinned)

The NodeSource apt key is downloaded over TLS from `deb.nodesource.com` into the private staging directory and installed
to `/etc/apt/keyrings/nodesource.asc` only if the file holds exactly one primary key whose fingerprint equals
`base_nodejs_apt_key_fingerprint`; otherwise the run fails before apt can trust it. The key is used as `signed_by` for the
NodeSource repository only, and apt then verifies every package against the signed repository metadata. If NodeSource rotates
its key the run fails with the fingerprint mismatch: verify the new fingerprint out of band and update the variable.
`gnupg` (installed by this component) provides the `gpg` check. The Docker and HashiCorp keys in `ansible_dev` and `cloud_cli`
work the same way.

## Download staging

Release downloads are staged in a private per-run directory (`ansible.builtin.tempfile`, mode 0700, created in the
role's `tasks/main.yml` and removed in an `always` section, also on failure) rather than fixed `/tmp` paths, so no other
local user can pre-create or swap a file between the download and the root-level install.
This covers the `uv` archive and the Nerd Font zip; the `nodejs` component stages the NodeSource key there for its fingerprint check.
A component file run on its own via `include_role ... tasks_from:` bypasses `tasks/main.yml`, so for `python` or `fonts`
it needs `base_dl_tmp` to be defined first.
