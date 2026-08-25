# swisstopo.workstation.gh

Installs the GitHub CLI (`gh`) via apt.

## What it does

- Installs `gh` from Ubuntu's apt archive, unpinned (`state: present`) — see
  the [root README](../../README.md#apt-package-versions-are-unpinned) for why.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README.

## Role Variables

None.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.gh
```
