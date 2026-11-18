# pmuellerch.workstation.desktop_apps

Installs standard/mainstream desktop applications that don't share any
functional state with each other: OnlyOffice Desktop Editors (office suite,
installed from its own apt repository), system-wide Firefox policies
(Bitwarden extension force-installed, de-CH dictionary force-installed,
native password manager disabled), and Brave/LibreWolf as opt-in
alternative browsers (default **disabled** — Firefox stays the default for
every consumer of this role unless explicitly toggled on).

This is a deliberate **category-level bundle** — the same precedent as this
collection's `code_quality_tools` role (trivy, pre-commit, yamllint, checkov,
ansible-lint bundled purely because they're "tools a repo's pre-commit
config invokes", not because they share files or state). OnlyOffice and
Firefox share **zero** functional coupling: they don't touch the same files,
depend on each other's state, or need to run in any particular order
relative to one another. They're bundled here purely because both are
"a standard desktop application most workstations want", the same category
of thing a developer expects pre-installed on a fresh machine — not a
functional coupling like `desktop_customization`'s `gui-customization`+
`flameshot` (where flameshot's COSMIC keybinding is wired through a file
`gui-customization`'s tasks create — a real ordering dependency).

## What it does

- Installs OnlyOffice Desktop Editors from its own apt repository.
- Deploys `/etc/firefox/policies/policies.json`: disables the native
  Firefox password manager, force-installs the Bitwarden extension pinned
  to the navigation bar, force-installs the Swiss German (`de-CH`)
  dictionary, and sets it as the default spellcheck language.
- Installs Brave from its own apt repository (opt-in, disabled by default);
  disables Brave Wallet and Brave Rewards via managed policy, force-installs
  the Bitwarden extension, and disables the native password manager.
- Installs LibreWolf via `extrepo` (opt-in, disabled by default); deploys
  the same Firefox `policies.json` (LibreWolf reads the identical Mozilla
  policy schema).

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README. Firefox itself
is **not installed** by this role — it's assumed pre-installed (ships with
Pop!_OS / most Ubuntu desktop images).

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_apps_onlyoffice_enabled` | `true` | Install OnlyOffice Desktop Editors |
| `desktop_apps_firefox_enabled` | `true` | Deploy system-wide Firefox policies |
| `desktop_apps_brave_enabled` | `false` | Install Brave (opt-in alternative browser) |
| `desktop_apps_librewolf_enabled` | `false` | Install LibreWolf (opt-in alternative browser) |

Firefox has no configurable variables beyond its enable toggle — the policy
content is fixed. `de-CH` is the Swiss standard locale, not something
meant to be parameterized per machine.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.desktop_apps
```

## Tags

Every task carries its own tag(s) in addition to the umbrella
`desktop_apps` tag, so a consuming playbook can filter to a single app:

| App | Tags |
| --- | --- |
| OnlyOffice Desktop Editors | `onlyoffice`, `desktop_apps` |
| Firefox policies | `firefox`, `desktop_apps` |
| Brave | `brave`, `desktop_apps` |
| LibreWolf | `librewolf`, `desktop_apps` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-app filtering.

## OnlyOffice

- `python3-debian` is installed first — required by `deb822_repository`,
  which can normally auto-install this dependency itself on a real run but
  not under `--check` (matches this collection's `iac_tools` role pattern
  for its Docker/Terraform apt repositories).
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
  `ignore_errors` — see "Check-mode guards for chained download→consume
  tasks" in this collection's conventions.

## Firefox

- Deploys `/etc/firefox/policies/policies.json` (requires `become: true`).
- The native Firefox password manager is disabled
  (`PasswordManagerEnabled: false`).
- The Bitwarden extension (`{446900e4-71c2-419f-a6a7-df9c091e268b}`) is
  force-installed and pinned to the navigation bar.
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
    `ExtensionSettings`, mirroring Firefox's Bitwarden force-install.
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
