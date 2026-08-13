# pmuellerch.workstation

An Ansible Galaxy collection for provisioning personal/home workstation tools on Ubuntu 24.04 with the COSMIC desktop environment.

## Roles

| Role | Description |
| --- | --- |
| `bitwarden` | Bitwarden password manager desktop app |
| `synology` | Synology Drive client |
| `thunderbird` | Thunderbird email client |
| `beets` | Music library manager |
| `spotify` | Spotify desktop app |
| `plex` | Plex Desktop and Plexamp |
| `graphics` | Graphics tools (Inkscape, GIMP) |
| `emoji_picker` | Emoji picker (emoji-fzf + smile) |

## Installation

```yaml
# requirements.yml
collections:
  - name: pmuellerch.workstation
    type: git
    source: https://github.com/PMuellerCH/ansible-collection-workstation.git
    version: "0.1.1"
```

```bash
ansible-galaxy collection install -r requirements.yml
```

## Usage

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.thunderbird
    - pmuellerch.workstation.bitwarden
```

## Development

```bash
# Lint
yamllint --config-file .yamllint.yml .
ansible-lint

# Molecule test a role (requires Docker)
cd roles/<name> && molecule test
```

CI lints every push/PR to `main`. Molecule only runs on the release-please PR (or via
manual `workflow_dispatch`), so a release is never cut without molecule passing.

New roles should include a `README.md` following
[`roles/ROLE_README_TEMPLATE.md`](roles/ROLE_README_TEMPLATE.md).

## License

Apache-2.0
