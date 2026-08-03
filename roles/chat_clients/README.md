# swisstopo.workstation.chat_clients

Installs workplace chat clients: Slack (via Flatpak) and Microsoft Teams
(via `teams-for-linux`, an unofficial Electron client, installed as a `.deb`
from GitHub releases). Merges what used to be two separate `slack` and
`teams` roles — both are workplace chat clients, the same category of tool a
user reaches for in the same context, despite different install mechanisms.

The role bootstraps Flatpak and the Flathub remote itself (needed for Slack),
so it does not depend on any other role having done so first.

## Tagging (for backward-compatible selective runs)

Every task carries its own tag(s) in addition to the umbrella `chat_clients`
tag, so a consuming playbook can still filter by the tool's original identity
even though it's one role:

| Tool | Tags |
| --- | --- |
| Slack (+ Flatpak/Flathub bootstrap) | `slack`, `chat_clients` |
| Microsoft Teams | `teams`, `chat_clients` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `chat_clients_slack_enabled` | `true` | Install Slack (also gates the Flatpak/Flathub bootstrap) |
| `chat_clients_teams_enabled` | `true` | Install teams-for-linux |
| `chat_clients_teams_version` | `2.13.0` | teams-for-linux version (github-releases: `IsmaelMartinez/teams-for-linux`) |
| `chat_clients_teams_download_base` | see `defaults/main.yml` | Base URL the teams-for-linux `.deb` is downloaded from |

## Notes

- Slack is installed as `com.slack.Slack`. No mature Slack TUI exists that
  supports all features; Flatpak is the preferred install method (no
  maintained apt repo).
- The teams-for-linux `.deb` is downloaded to `/tmp` and installed via `apt`;
  the installed version is checked before downloading for idempotency.
- The download is checksum-verified against the `sha512` published in
  upstream's own `latest-linux.yml` release metadata, fetched fresh on every
  run — this guards against corruption/tampering in transit, not against a
  compromised upstream release. No static checksum to keep in sync with
  Renovate version bumps.
- After install, launch Slack with `flatpak run com.slack.Slack` and log in.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
