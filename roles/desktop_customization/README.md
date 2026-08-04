# swisstopo.workstation.desktop_customization

Configures desktop-environment-level settings (fixed workspaces, workspace
keybindings) and installs Flameshot (screenshot tool: apt install, XDG
autostart, Print-key keybinding) — for both GNOME and COSMIC. Merges what
used to be two separate `gui-customization` and `flameshot` roles: they are
bundled here because flameshot's COSMIC keybinding is wired through the
custom-shortcuts file that the desktop-customization tasks create — a real
ordering dependency, not just topical overlap.

## Tagging (for backward-compatible selective runs)

Every task carries its own tag(s) in addition to the umbrella
`desktop_customization` tag, so a consuming playbook can still filter by the
tool's original identity even though it's one role:

| Tool | Tags |
| --- | --- |
| Desktop/workspace customization | `gui-customization`, `desktop_customization` |
| Flameshot | `flameshot`, `desktop_customization` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

The two COSMIC prerequisite tasks (creating the shortcuts directory and
initialising the empty shortcuts file) carry **both** `gui-customization`
and `flameshot` tags, even though they conceptually belong to
gui-customization — a `--tags flameshot`-only run on COSMIC still depends
on them existing, so they must stay reachable under either tag on their
own to keep `--tags flameshot` self-sufficient.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_customization_desktop_environment` | `gnome` | Desktop environment in use (`gnome` or `cosmic`). Controls which task set is applied. |
| `desktop_customization_flameshot_version` | see `defaults/main.yml` | flameshot apt package version (deb datasource: Ubuntu Noble), held after install. |

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
- `community.general.dconf` requires a running D-Bus session — run this role
  while logged into a graphical GNOME session, not over a headless SSH
  connection.

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

- Installed via apt, exact version pinned (`desktop_customization_flameshot_version`)
  and held afterward so unattended `apt upgrade` can't drift it.
- An XDG autostart entry is deployed to `~/.config/autostart/flameshot.desktop`
  so Flameshot starts at login.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
