# swisstopo.workstation.gh

Installs the GitHub CLI (`gh`) via apt.

## What it does

- Installs `gh` from Ubuntu's apt archive, exact version pinned.
- Holds the package afterward (`dpkg_selections: hold`) so unattended
  `apt upgrade` can't drift it. The hold task is gated with
  `when: not ansible_check_mode` — on a fresh machine under `--check` the
  install above is a no-op, so `gh` has no dpkg record yet and
  `dpkg_selections` would otherwise hard-fail.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `gh_version` | see `defaults/main.yml` | Exact apt package version of `gh` to install |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.gh
```
