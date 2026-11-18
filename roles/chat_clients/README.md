# pmuellerch.workstation.chat_clients

Installs workplace chat clients: Slack (via Flatpak) and Microsoft Teams (via
`teams-for-linux`, an unofficial Electron client, installed as a `.deb` from
GitHub releases). Both are bundled here because they're the same category of
tool — a workplace chat client — regardless of their different install
mechanisms.

The role bootstraps Flatpak and the Flathub remote itself (needed for Slack),
so it does not depend on any other role having done so first.

## What it does

- Installs Slack as the Flatpak `com.slack.Slack` (bootstraps Flatpak + the
  Flathub remote first if not already present).
- Downloads the `teams-for-linux` `.deb` from GitHub releases to `/tmp` and
  installs it via `apt`; the installed version is checked before downloading,
  for idempotency.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `chat_clients_slack_enabled` | `true` | Install Slack (also gates the Flatpak/Flathub bootstrap) |
| `chat_clients_teams_enabled` | `true` | Install teams-for-linux |
| `chat_clients_teams_version` | see `defaults/main.yml` | teams-for-linux version (github-releases: `IsmaelMartinez/teams-for-linux`) |
| `chat_clients_teams_download_base` | see `defaults/main.yml` | Base URL the teams-for-linux `.deb` is downloaded from |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.chat_clients
      vars:
        chat_clients_slack_enabled: true
        chat_clients_teams_enabled: true
```

## Tags

Every task carries its own tag(s) in addition to the umbrella `chat_clients`
tag, so a consuming playbook can filter to a single client:

| Tool | Tags |
| --- | --- |
| Slack (+ Flatpak/Flathub bootstrap) | `slack`, `chat_clients` |
| Microsoft Teams | `teams`, `chat_clients` |

**Do not** put an outer `tags:` on the role invocation in your play — that tag
cascades to every task in the role and defeats this per-tool filtering.

## Notes

- No mature Slack TUI supports all features, and there's no maintained apt
  repo, so Flatpak is the preferred install method.
- The teams-for-linux download is checksum-verified against the `sha512`
  published in upstream's own `latest-linux.yml` release metadata, fetched
  fresh on every run — this guards against corruption/tampering in transit,
  not against a compromised upstream release. No static checksum to keep in
  sync with version bumps.
- After install, launch Slack with `flatpak run com.slack.Slack` and log in.
