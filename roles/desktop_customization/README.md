# pmuellerch.workstation.desktop_customization

Configures desktop-environment-level settings (fixed workspaces, workspace
keybindings), installs Flameshot (screenshot tool: apt install, XDG
autostart, Print-key keybinding), and installs the `smile` emoji picker
(Flatpak) — for both GNOME and COSMIC.

Desktop/workspace settings and Flameshot are bundled together because
Flameshot's COSMIC keybinding is wired through the custom-shortcuts file
that the desktop-customization tasks create — a real ordering dependency,
not just topical overlap. The emoji picker is added here because it is GUI
desktop tooling of the same shape as Flameshot (a single small desktop
utility), not because it shares any file or state with the other two. The
CLI half of emoji picking (`emoji-fzf`) lives in the `cli_tools` role
instead.

## What it does

- **GNOME/COSMIC workspaces**: sets 9 fixed workspaces and workspace
  switch/move keybindings (`Super+1-9`, `Super+Shift+1-9`).
- **Flameshot**: installs via apt, deploys an XDG autostart entry, and binds
  the Print key to `flameshot gui`.
- **Emoji picker**: installs the `smile` Flatpak app (`it.mijorus.smile`).

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README. The role
bootstraps Flatpak + the Flathub remote itself for the emoji picker (apt install `flatpak` + `xdg-utils`,
then add the Flathub remote), the same self-contained pattern the
`chat_clients` role uses for Slack. `community.general.dconf` (GNOME
settings) requires a running D-Bus session — run this role while logged
into a graphical GNOME session, not over a headless SSH connection.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_customization_desktop_environment` | `gnome` | Desktop environment in use (`gnome` or `cosmic`). Controls which task set is applied. |
| `desktop_customization_smile_enabled` | `true` | Whether to install the `smile` emoji picker. Also gates the Flatpak/Flathub bootstrap (the only consumer of Flatpak in this role). |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.desktop_customization
      vars:
        desktop_customization_desktop_environment: cosmic
```

## Tags

Every task carries its own tag(s) in addition to the umbrella
`desktop_customization` tag, so a consuming playbook can filter to a single
tool:

| Tool | Tags |
| --- | --- |
| Desktop/workspace customization | `gui-customization`, `desktop_customization` |
| Flameshot | `flameshot`, `desktop_customization` |
| Emoji picker (smile) | `emoji-picker`, `desktop_customization` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

The two COSMIC prerequisite tasks (creating the shortcuts directory and
initialising the empty shortcuts file) carry **both** `gui-customization`
and `flameshot` tags, even though they conceptually belong to
gui-customization — a `--tags flameshot`-only run on COSMIC still depends
on them existing, so they must stay reachable under either tag on their
own to keep `--tags flameshot` self-sufficient.

## GNOME

- Sets 9 fixed workspaces (`dynamic-workspaces: false`, `num-workspaces: 9`).
- Disables Dash-to-Dock `hot-keys` and unbinds `Super+1-9` from GNOME dock
  app-switching (`switch-to-application-N`) — both would otherwise intercept
  the keys before workspace switching. The Dash-to-Dock task is allowed to
  fail (`failed_when: false`, unconditional): the extension schema may not
  exist on every machine, and that's not an error condition for this role.
  (`ignore_errors: true` would do the same thing but trips ansible-lint's
  production-profile `ignore-errors` rule, which only flags the literal
  `ignore_errors: true` form.)
- Binds `Super+1-9` to workspace switching (`switch-to-workspace-N`).
- Binds `Super+Shift+1-9` to move the active window to a workspace
  (`move-to-workspace-N`).
- Disables the default GNOME Shell Print screenshot keybinding
  (`org.gnome.shell.keybindings screenshot`).
- Binds Print to `flameshot gui` via a custom keybinding at
  `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/`,
  registered by reading the existing `custom-keybindings` list first and
  merging the Flameshot entry into it — any other custom shortcuts the user
  already has configured (via GNOME Settings or otherwise) are preserved,
  not overwritten.

## COSMIC

- Creates `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/`.
- Deploys an empty COSMIC custom shortcuts file (`custom`) with
  `force: false` — not overwritten if already present.
- Binds Print to `flameshot gui` in that file via `lineinfile`
  (`Spawn("env XDG_CURRENT_DESKTOP=sway flameshot gui")`), matched on the
  exact no-modifier Print binding (`regexp: '\(modifiers: \[\], key:
  "Print"\):'`) rather than a bare `"Print"` substring, so an unrelated
  existing binding (e.g. `Shift+Print` bound to something else) isn't
  silently replaced.
- The `lineinfile` task is skipped under `ansible-playbook --check`
  (`not ansible_check_mode`) rather than using `ignore_errors`: on a
  first-ever run against a fresh machine, the shortcuts file doesn't exist
  yet, and `copy` (like `get_url`) reports `changed` under check mode
  without actually writing the destination — so a later task that
  unconditionally depends on the file existing must be skipped, not just
  have its failure swallowed. See the "Check-mode guards for chained
  download→consume tasks" pattern in this collection's other roles for the
  general shape of this issue.

## Flameshot

- Installed via apt, unpinned — see the
  [root README](../../README.md#apt-package-versions-are-unpinned) for why.
- An XDG autostart entry is deployed to `~/.config/autostart/flameshot.desktop`
  so Flameshot starts at login.

## Emoji picker (smile)

- Installs `it.mijorus.smile` via Flatpak (system-wide, `method: system`).
- This is the only task in the role that needs Flatpak, so the role
  bootstraps Flatpak + the Flathub remote itself (apt install `flatpak` +
  `xdg-utils`, then add the Flathub remote) — self-contained, per this
  collection's role-independence convention, mirroring the `chat_clients`
  role's exact pattern rather than assuming another role already set up
  Flatpak. The bootstrap and the install task are both gated on
  `desktop_customization_smile_enabled`.
- Only the GUI half of emoji picking. The CLI half (`emoji-fzf`, pipx
  install + zsh `emoji` function) is out of scope here and lives in the
  `cli_tools` role instead.
