# pmuellerch.workstation.desktop_integration

Desktop integration tooling: fixed GNOME workspaces with Super+1-9 keybindings, Flameshot (screenshots) with its
keybinding, the `smile` emoji picker (Flatpak), and Wayland clipboard tooling (`wl-clipboard`, `cliphist`, `clipse`).
Merged from the former `desktop_customization` and `clipboard_tools` roles.

## What it does

1. **workspaces** — fixed workspaces and Super+1-9 / Super+Shift+1-9 bindings in GNOME (a no-op on COSMIC).
2. **flameshot** — installs Flameshot, autostarts it, and binds the Print key (GNOME via dconf, COSMIC via its custom
   shortcuts file, which this component creates first).
3. **smile** — installs the `smile` emoji picker via Flatpak (bootstrapping Flathub first).
4. **wl-clipboard** — installs `wl-copy`/`wl-paste`.
5. **cliphist** — installs the cliphist clipboard history binary (checksum from GitHub's per-asset digest) and deploys
   its autostart entry.
6. **clipse** — installs the clipse clipboard manager (checksum from the release's `checksums.txt`).
7. **shell** — deploys `~/.config/zsh/conf.d/desktop_integration.zsh` (`ch()` history picker, `clipboard` alias) and
   removes the pre-merge `clipboard_tools.zsh`.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

GNOME settings use `community.general.dconf`, which needs a running D-Bus session — run this role inside a graphical
session. The `ch()` function needs `fzf` (the `cli_tools` role) and `wl-copy` (this role); the `emoji()` function of
`cli_tools` needs `wl-copy` from here. These are soft couplings: neither role hard-depends on the other.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `desktop_integration_desktop_environment` | `gnome` | Desktop environment in use. Controls which task set is applied. |
| `desktop_integration_smile_enabled` | `true` | Whether to install the smile emoji picker (also gates the Flatpak/Flathub bootstrap). |
| `desktop_integration_wl_clipboard_enabled` | `true` | Whether to install wl-clipboard (provides wl-copy/wl-paste). cliphist's autostart entry and the deployed `ch` shell function both depend on wl-copy/wl-paste at runtime — see README "Soft cross-tool dependencies" if disabling this while cliphist stays enabled. |
| `desktop_integration_cliphist_enabled` | `true` | Whether to install cliphist and deploy its autostart entry (`wl-paste --watch cliphist store`). Requires wl-clipboard at runtime — not hard-gated, see README. |
| `desktop_integration_clipse_enabled` | `true` | Whether to install clipse (clipboard history TUI). |
| `desktop_integration_github_api_token` | see `defaults/main.yml` | Optional GitHub API token, only to raise the rate limit when resolving the cliphist release-asset digest. Defaults to `GH_TOKEN`/`GITHUB_TOKEN`. The metadata fetch is retried (3 retries, 15 s apart) to ride out transient GitHub API rate limiting or errors; it still fails loudly if every attempt fails. |
| `desktop_integration_cliphist_version` | see `defaults/main.yml` | cliphist version (github-releases sentriz/cliphist), installed from a checksum-verified binary. |
| `desktop_integration_cliphist_download_base` | see `defaults/main.yml` | Base URL the cliphist release binary is downloaded from. |
| `desktop_integration_clipse_version` | see `defaults/main.yml` | clipse version (github-releases savedra1/clipse), installed from a checksum-verified archive. |
| `desktop_integration_clipse_archive` | see `defaults/main.yml` | Filename of the clipse release archive to download. |
| `desktop_integration_clipse_download_base` | see `defaults/main.yml` | Base URL the clipse archive and its checksums.txt are downloaded from. |
| `desktop_integration_deploy_shell_aliases` | `true` | Whether to deploy a zsh conf.d snippet (~/.config/zsh/conf.d/desktop_integration.zsh) with the `ch` function (cliphist) and `clipboard` alias (clipse) for enabled tools. |
| `desktop_integration_workspaces_enabled` | `true` | Whether to configure fixed workspaces and the Super+1-9 keybindings (GNOME only; a no-op on COSMIC). |
| `desktop_integration_flameshot_enabled` | `true` | Whether to install Flameshot, autostart it and bind it to the Print key. |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.desktop_integration
      vars:
        desktop_integration_desktop_environment: cosmic
```

## Tags

| Component | Tags |
| --- | --- |
| workspaces | `gui-customization`, `desktop_integration` |
| flameshot | `flameshot`, `desktop_integration` |
| smile | `emoji-picker`, `desktop_integration` |
| wl-clipboard | `wl-clipboard`, `desktop_integration` |
| cliphist | `cliphist`, `desktop_integration` |
| clipse | `clipse`, `desktop_integration` |
| shell | `wl-clipboard`, `cliphist`, `clipse`, `desktop_integration` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

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
  have its failure swallowed. This is the collection's
  `when: not ansible_check_mode` convention (see CLAUDE.md, "Idempotency").

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
  collection's role-independence convention, mirroring the `desktop_apps`
  role's exact pattern rather than assuming another role already set up
  Flatpak. The bootstrap and the install task are both gated on
  `desktop_integration_smile_enabled`.
- Only the GUI half of emoji picking. The CLI half (`emoji-fzf`, pipx
  install + zsh `emoji` function) is out of scope here and lives in the
  `cli_tools` role instead.

## Checksum verification

- **clipse** (`savedra1/clipse`) publishes a plain `sha256sum`-format
  `checksums.txt` per release — `get_url`'s `checksum:` param fetches and
  matches it directly by the source URL's basename, so there's no static
  checksum to keep in sync by hand when the version is bumped (same pattern
  as the `git` role's lazygit).
- **cliphist** (`sentriz/cliphist`) publishes **only** raw per-platform
  binaries per release (e.g. `v0.7.0-linux-amd64`) — no `checksums.txt`,
  `.sha256`, or any other sidecar. Instead of a hand-pinned static checksum,
  the binary is verified against GitHub's own per-asset digest: the role
  fetches the release metadata from the GitHub API for the pinned
  `desktop_integration_cliphist_version`, reads the asset's `sha256` digest, and
  feeds it to `get_url`. The checksum is always derived from the pinned
  version, so a Renovate version bump needs no manual checksum update. If
  GitHub reports no digest for the asset, the role fails loudly rather than
  skipping verification.

## Soft cross-tool dependencies (documentation only, not hard-gated)

- **cliphist's autostart entry runs `wl-paste --watch cliphist store`** —
  a hard runtime dependency on `wl-clipboard`. If you disable
  `desktop_integration_wl_clipboard_enabled` while leaving
  `desktop_integration_cliphist_enabled: true`, the autostart entry is deployed
  anyway and fails at login (`wl-paste: command not found`). This is
  deliberately **not** hard-gated — disabling wl-clipboard while keeping
  cliphist enabled is an unusual, deliberate consumer choice, and adding a
  cross-variable `when:` here would only paper over a configuration a
  consumer should notice and fix themselves. Keep the two toggles in sync.

## Cross-role dependencies

- The deployed `ch` shell function (`cliphist list | fzf --with-nth 2 |
  cliphist decode | wl-copy`) requires **`fzf`**, which lives in the
  `cli_tools` role (`cli_tools_fzf_enabled`), not this one. Without it,
  `cliphist`/`clipse` still work via their own CLIs, but the `ch` function
  is not defined (it is wrapped in a `command -v` check).
- This is a **two-way** soft coupling: `cli_tools`' own README documents
  its `emoji-fzf`-driven `emoji` shell function depending on **this role's**
  `wl-copy` (`desktop_integration_wl_clipboard_enabled`) to copy the selected
  emoji to the clipboard. Neither role hard-depends on the other
  (`meta/main.yml` `dependencies: []` on both sides, per this collection's
  role-independence convention) — both couplings degrade gracefully to "the
  shell function silently does nothing useful" if the other role isn't
  installed, not a hard failure.

### Download staging

Release downloads are staged in a private per-run directory (`ansible.builtin.tempfile`, mode 0700, created in the
role's `tasks/main.yml` and removed in an `always` section, also on failure) rather than fixed `/tmp` paths, so no other
local user can pre-create or swap a file between the checksum-verified download and the root-level install.
