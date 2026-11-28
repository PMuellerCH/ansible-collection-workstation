# pmuellerch.workstation.desktop_apps

Installs standard desktop applications that share no functional state with each other: OnlyOffice Desktop Editors
(own apt repository), system-wide Firefox policies, Brave and LibreWolf as opt-in alternative browsers (default
**disabled** — Firefox stays the default), and the workplace chat clients Slack (Flatpak) and Microsoft Teams
(`teams-for-linux`). Merged from the former `desktop_apps` and `chat_clients` roles.

This is a deliberate **category-level bundle**: the applications share no files or state; they are bundled because
each is a standard desktop application a workstation wants. Each lives in its own task file behind its own switch.

## What it does

- Installs OnlyOffice Desktop Editors from its own apt repository.
- Deploys `/etc/firefox/policies/policies.json` (rendered from a template): disables the native Firefox password
  manager, force-installs the Bitwarden and uBlock Origin extensions (both pinned to the navigation bar) and the Swiss
  German (`de-CH`) dictionary, and sets it as the default spellcheck language.
- Installs Brave from its own apt repository (opt-in); disables Brave Wallet and Rewards via managed policy,
  force-installs the Bitwarden and uBlock Origin extensions and disables the native password manager.
- Installs LibreWolf via `extrepo` (opt-in) and deploys the same Firefox `policies.json`.
- Installs Slack as the Flatpak `com.slack.Slack` (bootstrapping Flatpak and Flathub first).
- Downloads the `teams-for-linux` `.deb` from GitHub releases and installs it via `apt`; the installed version is
  checked first, for idempotency.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency, but on a real workstation run `base` first. Firefox itself is **not installed** by this
role — it ships pre-installed with most Ubuntu desktop images.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_apps_onlyoffice_enabled` | `true` | Whether to install OnlyOffice Desktop Editors. |
| `desktop_apps_firefox_enabled` | `true` | Whether to deploy system-wide Firefox policies. |
| `desktop_apps_brave_enabled` | `false` | Whether to install Brave as an opt-in alternative browser, with crypto wallet/rewards features disabled via managed policy. Default false — Firefox stays the default for every consumer of this role unless explicitly toggled on. |
| `desktop_apps_librewolf_enabled` | `false` | Whether to install LibreWolf as an opt-in alternative browser (via extrepo). Default false — Firefox stays the default for every consumer of this role unless explicitly toggled on. |
| `desktop_apps_bitwarden_extension_enabled` | `true` | Whether to force-install the Bitwarden extension in the managed browsers (Firefox, LibreWolf, Brave). Set to `false` when Bitwarden is not used. |
| `desktop_apps_ublock_origin_enabled` | `true` | Whether to force-install the uBlock Origin extension in the managed browsers (Firefox, LibreWolf, Brave). |
| `desktop_apps_slack_enabled` | `true` | Whether to install Slack (also gates the Flatpak/Flathub bootstrap). |
| `desktop_apps_teams_enabled` | `true` | Whether to install teams-for-linux. |
| `desktop_apps_teams_version` | see `defaults/main.yml` | teams-for-linux version (github-releases IsmaelMartinez/teams-for-linux). |
| `desktop_apps_teams_download_base` | see `defaults/main.yml` | Base URL the teams-for-linux .deb is downloaded from, before the filename. |

Firefox has no configurable variables beyond its switch — the policy content is fixed (`de-CH` is the Swiss standard
locale, not something meant to be parameterized per machine).

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.desktop_apps
      vars:
        desktop_apps_brave_enabled: true
```

## Tags

| Component | Tags |
| --- | --- |
| onlyoffice | `onlyoffice`, `desktop_apps` |
| firefox | `firefox`, `desktop_apps` |
| brave | `brave`, `desktop_apps` |
| librewolf | `librewolf`, `desktop_apps` |
| slack | `slack`, `desktop_apps` |
| teams | `teams`, `desktop_apps` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

## OnlyOffice

- `python3-debian` is installed first — required by `deb822_repository`,
  which can normally auto-install this dependency itself on a real run but
  not under `--check` (matches this collection's `ansible_dev`/`cloud_cli` role
  pattern for their Docker/Terraform apt repositories).
- GPG key downloaded to `/usr/share/keyrings/onlyoffice.asc` (`force: false`
  — not re-downloaded if already present).
- Repository added as `/etc/apt/sources.list.d/onlyoffice.sources` (deb822
  format), suite `squeeze` — this is OnlyOffice's actual apt suite name
  regardless of Ubuntu version, not a stale or incorrect value.
- Installed via apt, unpinned — see the
  [root README](../../README.md#apt-package-versions-are-unpinned) for why.
- The full chain (GPG key download → apt repository → package install)
  depends on each previous step having actually happened for real. `get_url`
  and a first-run `python3-debian` install both report
  `changed` under `ansible-playbook --check` without doing anything for
  real, so every task downstream of them is skipped under check mode
  (`when: ... and not ansible_check_mode`) rather than tolerated via
  `ignore_errors` — the collection's `when: not ansible_check_mode`
  convention (see CLAUDE.md, "Idempotency").

## Firefox

- Deploys `/etc/firefox/policies/policies.json` (requires `become: true`).
- The native Firefox password manager is disabled
  (`PasswordManagerEnabled: false`).
- The Bitwarden extension (`{446900e4-71c2-419f-a6a7-df9c091e268b}`) is
  force-installed and pinned to the navigation bar, unless
  `desktop_apps_bitwarden_extension_enabled` is `false`.
- The uBlock Origin extension (`uBlock0@raymondhill.net`) is force-installed and
  pinned to the navigation bar, unless `desktop_apps_ublock_origin_enabled` is
  `false`.
- The Swiss German dictionary (`de-CH@dictionaries.addons.mozilla.org`) is
  force-installed.
- The default spellcheck language is set to `de-CH` via
  `Preferences.spellchecker.dictionary`.

## Brave

Opt-in alternative browser, disabled by default (`desktop_apps_brave_enabled:
false`) — installing this role does not change the default browser for any
existing consumer.

- Added via Brave's own signed apt repository, same
  GPG-key-download-then-`deb822_repository` pattern as OnlyOffice above
  (`/usr/share/keyrings/brave-browser-archive-keyring.gpg`,
  `/etc/apt/sources.list.d/brave-browser-release.sources`, suite `stable`).
- Installed via apt, unpinned — see the
  [root README](../../README.md#apt-package-versions-are-unpinned) for why.
- Managed policy deployed to `/etc/brave/policies/managed/policies.json`
  (Chromium enterprise policy format, distinct from Firefox's schema):
  - `BraveWalletDisabled` / `BraveRewardsDisabled`: disables Brave's
    crypto wallet and BAT rewards features.
  - `PasswordManagerEnabled: false`: same posture as Firefox above.
  - The Bitwarden extension (Chrome Web Store ID
    `nngceckbapebfimnlniiiahkandclblb`) is force-installed via
    `ExtensionSettings`, mirroring Firefox's Bitwarden force-install (skipped
    with `desktop_apps_bitwarden_extension_enabled: false`).
  - The uBlock Origin extension (Chrome Web Store ID
    `cjpalhdlnbpafiamejdnhcphjbkeiagm`) is force-installed the same way
    (skipped with `desktop_apps_ublock_origin_enabled: false`).
- Same check-mode chain-dependency reasoning as OnlyOffice: the GPG key
  download, apt repository, and package install are skipped under `--check`
  since each depends on the previous step having happened for real.

## LibreWolf

Opt-in alternative browser, disabled by default (`desktop_apps_librewolf_enabled:
false`) — same posture as Brave above.

- Installed via [extrepo](https://packages.debian.org/extrepo) rather than a
  hand-rolled GPG-key-plus-sources-file pair like OnlyOffice/Brave —
  LibreWolf's own current install documentation recommends `extrepo` over a
  manual repository setup. `extrepo enable librewolf` fetches the
  repository's signed policy (URL + GPG key) from extrepo's own curated
  index and writes `/etc/apt/sources.list.d/extrepo_librewolf.sources` in
  one step; no separate key-download or `deb822_repository` task needed.
- `extrepo` has no dedicated Ansible module, so `extrepo enable` runs via
  `ansible.builtin.command` — idempotency is handled by a `stat` check
  against the resulting `.sources` file rather than relying on the
  command's own output, so it only ever runs once per machine.
- Installed via apt, unpinned — see the
  [root README](../../README.md#apt-package-versions-are-unpinned) for why.
- Deploys the **same** `/etc/librewolf/policies/policies.json` file as
  Firefox above, unmodified — LibreWolf is a Firefox fork and reads the
  identical Mozilla policy schema from its own config path.

## Slack and Teams

- No mature Slack TUI supports all features and there is no maintained apt repository, so Flatpak is the install
  method. Launch with `flatpak run com.slack.Slack` and log in.
- The teams-for-linux download is checksum-verified against the `sha512` in upstream's own `latest-linux.yml` release
  metadata, fetched fresh on every run — this guards against corruption or tampering in transit, not against a
  compromised upstream release. There is no static checksum to keep in sync with version bumps.

### Download staging

Release downloads are staged in a private per-run directory (`ansible.builtin.tempfile`, mode 0700, created in the
role's `tasks/main.yml` and removed in an `always` section, also on failure) rather than fixed `/tmp` paths, so no other
local user can pre-create or swap a file between the checksum-verified download and the root-level install.

The OnlyOffice and Brave apt keys are fetched over TLS without a fingerprint pin (tracked in #171).
