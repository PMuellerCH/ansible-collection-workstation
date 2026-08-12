# swisstopo.workstation.desktop_apps

Installs standard/mainstream desktop applications that don't share any
functional state with each other: OnlyOffice Desktop Editors (office suite,
installed from its own apt repository) and system-wide Firefox policies
(Bitwarden extension force-installed, de-CH dictionary force-installed,
native password manager disabled). Merges what used to be `computer-setup`'s
separate `onlyoffice` and `firefox` roles.

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

## Tagging (for backward-compatible selective runs)

Every task carries its own tag(s) in addition to the umbrella
`desktop_apps` tag, so a consuming playbook can still filter by the
application's original identity even though it's one role:

| App | Tags |
| --- | --- |
| OnlyOffice Desktop Editors | `onlyoffice`, `desktop_apps` |
| Firefox policies | `firefox`, `desktop_apps` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-app filtering.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_apps_onlyoffice_enabled` | `true` | Install OnlyOffice Desktop Editors |
| `desktop_apps_firefox_enabled` | `true` | Deploy system-wide Firefox policies |
| `desktop_apps_onlyoffice_version` | `9.4.0-129` | `onlyoffice-desktopeditors` apt package version (deb datasource: OnlyOffice's own apt repository) |

Firefox has no configurable variables beyond its enable toggle — the policy
content is fixed. `de-CH` is swisstopo's standard locale, not something
meant to be parameterized per machine (same posture as this org's
`betterbird` role, which hardcodes the same locale for its own defaults).

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
- Installed via apt, exact version pinned
  (`desktop_apps_onlyoffice_version`) and held afterward so unattended
  `apt upgrade` can't drift it.
- The full chain (GPG key download → apt repository → package install →
  version hold) depends on each previous step having actually happened for
  real. `get_url` and a first-run `python3-debian` install both report
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
- Firefox itself is **not installed** by this role — it's assumed
  pre-installed (ships with Pop!_OS / most Ubuntu desktop images).

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
