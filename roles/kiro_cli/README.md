# swisstopo.workstation.kiro_cli

Installs the [Kiro CLI](https://kiro.dev/cli/) (`kiro-cli`) for the target user
and sets its default behaviour: the **v3 agent engine**, **tool auto-search**,
and **autonomous mode** (trust-all-tools) wired into a short `ki` shell alias.
Also deploys a zsh `conf.d` snippet with `ki` (autonomous chat) and `kil`
(login) aliases.

## What it does

- Installs `kiro-cli` into the user's `~/.local/bin` via the official install
  script (`https://cli.kiro.dev/install --force`), but only when the binary is
  not already present, then re-checks that the binary exists.
- When the binary is already present, optionally runs `kiro-cli update
  --non-interactive` to converge to the latest release
  (`kiro_cli_update`, default `true`).
- Persists three global settings via `kiro-cli settings`, each read as JSON
  first and written only when the current value differs (idempotent):
  - `chat.agentEngine = v3` — the v3 CLI agent engine.
  - `toolSearch.enabled = true` — tool auto-search.
  - `chat.disableTrustAllConfirmation = true` — so the autonomous `ki` alias
    starts without a per-launch confirmation prompt.
- Deploys `~/.config/zsh/conf.d/kiro_cli.zsh` with:
  - `ki`  → `kiro-cli chat --trust-all-tools` (autonomous mode)
  - `kil` → `kiro-cli login`

## Autonomous mode is an alias, not a setting

kiro-cli has no persistent "autonomous mode" setting. Autonomy is the
`--trust-all-tools` chat flag, which lets the agent run tools without asking
for confirmation. This role therefore makes autonomous mode the default by
baking the flag into the `ki` alias, and sets the global
`chat.disableTrustAllConfirmation` so the alias runs without an extra prompt.
Launch kiro-cli without the alias (`kiro-cli chat`) for an interactive,
confirm-each-tool session.

## kiro-cli is installed via the official script (unpinned)

`kiro-cli` is a self-updating single binary distributed only through the
official install script. Upstream publishes no versioned, individually
downloadable release asset, so there is nothing to exact-pin and
checksum-verify the way the binary installs in `clipboard_tools` or `base`
do. The install URL is therefore an **unpinned remote source** — a deliberate
departure from this collection's "pin everything, Renovate tracks it"
convention, documented here like the
[apt-unpinned deviation](../../README.md#apt-package-versions-are-unpinned):

- The role only runs the installer when the binary is absent, so the unpinned
  fetch happens once per machine rather than on every run.
- Keeping the binary current afterwards is delegated to `kiro-cli update`
  (the tool's own supported mechanism), exposed through `kiro_cli_update`.
- There is no Renovate manager for this version, by design: the binary tracks
  its own releases.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on a
real workstation, run `base` first, per the [root README](../../README.md).
Your `.zshrc` must source `~/.config/zsh/conf.d/*.zsh` for the deployed aliases
to take effect. Network access to `cli.kiro.dev` is required for the install
step. Authentication (`kiro-cli login`, aliased to `kil`) is interactive and
is left to the user; the role does not log in.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `kiro_cli_enabled` | `true` | Install and configure kiro-cli |
| `kiro_cli_bin` | `~/.local/bin/kiro-cli` | Absolute path to the binary (detection + full-path invocation) |
| `kiro_cli_install_url` | `https://cli.kiro.dev/install` | Official install script URL (unpinned — see above) |
| `kiro_cli_update` | `true` | Run `kiro-cli update` when the binary is already present |
| `kiro_cli_agent_engine` | `v3` | Value for the global `chat.agentEngine` setting |
| `kiro_cli_tool_search_enabled` | `true` | Value for the global `toolSearch.enabled` setting |
| `kiro_cli_disable_trust_all_confirmation` | `true` | Value for the global `chat.disableTrustAllConfirmation` setting |
| `kiro_cli_deploy_shell_aliases` | `true` | Deploy `~/.config/zsh/conf.d/kiro_cli.zsh` |
| `kiro_cli_alias_chat` | `ki` | Alias name for autonomous chat (`kiro-cli chat --trust-all-tools`) |
| `kiro_cli_alias_login` | `kil` | Alias name for `kiro-cli login` |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.kiro_cli
```

## Tags

Every task carries the umbrella `kiro_cli` tag, so a consuming playbook can
select this role with `--tags kiro_cli`.

| Area | Tags |
| --- | --- |
| install / update | `kiro_cli` |
| default-behaviour settings | `kiro_cli` |
| shell alias deployment | `kiro_cli` |

## Notes

- All tasks run as the target user (`become: false`): `kiro-cli` is a per-user
  binary in `~/.local/bin`, its settings live in the user's data directory, and
  the alias snippet is written under the user's home. The binary is always
  invoked by its full path (`kiro_cli_bin`), because `~/.local/bin` is not
  guaranteed to be on `$PATH` for a non-interactive Ansible run.
- Install is detected with `ansible.builtin.stat` on `kiro_cli_bin` (not
  `command -v`, which cannot work through the `command` module), and the binary
  is re-checked after the install step.
- The settings tasks read each value as JSON first and write only on a
  difference, so re-running the role reports no change once converged.
- Under `ansible-playbook --check` the install, update, and settings tasks are
  skipped (`not ansible_check_mode`), because they depend on the downloaded
  installer and a working binary; the alias-snippet deployment still runs.
