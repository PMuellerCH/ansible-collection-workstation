# swisstopo.workstation.maintenance

System maintenance tasks for a workstation set up by this collection: apt
update + safe upgrade, `apt autoremove`/`autoclean`, systemd journal vacuum,
Docker prune, and Flatpak unused-runtime cleanup. Each step is independently
toggleable.

## Why this role exists, and why it's not part of `base`

Every version-pinned tool installed by this collection is `apt-mark hold`'d
after install (or, for GitHub-release/npm/pipx tools, installed once and
left alone) so that a routine provisioning run never silently drifts a
pinned tool to a newer version — only an explicit Renovate-driven version
bump does that, through the normal install task. A plain `apt-get upgrade`
already respects those holds and leaves pinned tools alone; this role
exists purely for the maintenance side that has nothing to do with any
single tool's pin: reclaiming disk space and clearing out packages/images
nothing depends on anymore. It's deliberately **not** invoked from `site.yml`
directly — this collection's consuming playbook is expected to run it from
its own separate maintenance playbook (faster than a full provisioning run,
since it skips every tool-install task and does actual system upkeep
instead).

## What it does

- `apt-get update` + `apt-get upgrade` (safe upgrade — respects holds).
- `apt-get autoremove` (no purge — configs of removed packages are kept).
- `apt-get autoclean`.
- `journalctl --vacuum-time` (default: `2weeks`).
- `docker system prune --all --force` when Docker is installed — images,
  stopped containers, unused networks, and build cache. **Not** volumes;
  see "Notes" below.
- `flatpak uninstall --unused` when Flatpak is installed.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule).

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `maintenance_apt_upgrade_enabled` | `true` | Run `apt-get update` + safe upgrade |
| `maintenance_apt_autoremove_enabled` | `true` | Run `apt-get autoremove` (no purge) |
| `maintenance_apt_autoclean_enabled` | `true` | Run `apt-get autoclean` |
| `maintenance_journal_vacuum_enabled` | `true` | Vacuum systemd journal logs |
| `maintenance_journal_vacuum_time` | `2weeks` | Retention window passed to `journalctl --vacuum-time` |
| `maintenance_docker_prune_enabled` | `true` | Run `docker system prune` when Docker is installed |
| `maintenance_flatpak_cleanup_enabled` | `true` | Run `flatpak uninstall --unused` when Flatpak is installed |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.maintenance
```

## Tags

| Task group | Tags |
| --- | --- |
| apt update + safe upgrade | `apt_upgrade`, `maintenance` |
| apt autoremove | `apt_autoremove`, `maintenance` |
| apt autoclean | `apt_autoclean`, `maintenance` |
| journal vacuum | `journal_vacuum`, `maintenance` |
| Docker prune | `docker_prune`, `maintenance` |
| Flatpak cleanup | `flatpak_cleanup`, `maintenance` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-step filtering.

## Notes

- **Docker prune deliberately excludes volumes.** Named volumes routinely
  hold data a workstation user did not consciously mark disposable
  (databases, persistent app state) — unlike images, stopped containers,
  networks, and build cache, which are cheap to recreate. Pruning volumes is
  left to the consumer to do explicitly and consciously, not as a default in
  an unattended maintenance run.
- **`changed_when` for the Docker/journal/Flatpak tasks is derived from
  actual CLI output**, not assumed: `docker system prune` reports `Total
  reclaimed space: 0B` when there's nothing to remove; `journalctl
  --vacuum-time` writes every status line (including "Vacuuming done...")
  to **stderr**, not stdout, and reports `freed 0B` per journal directory
  when nothing was deleted; `flatpak uninstall --unused` reports `Nothing
  unused to uninstall` (exit code 0, not an error) when there's nothing to
  remove. All three were confirmed against the real binaries, not inferred
  from documentation.
- Skips any host without Docker or Flatpak installed — both cleanup steps
  check for the binary's presence first.
