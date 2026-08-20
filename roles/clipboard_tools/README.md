# swisstopo.workstation.clipboard_tools

Installs Wayland clipboard tooling: `wl-clipboard` (apt, provides `wl-copy`/
`wl-paste`), `cliphist` (GitHub release binary, clipboard history daemon +
autostart entry), and `clipse` (GitHub release binary, clipboard history
TUI). Each tool is independently toggleable.

## Why this is its own role, not part of `desktop_customization`

There's a shape parallel with `desktop_customization`'s Flameshot (an
XDG-autostart-daemon pattern), but `clipboard_tools` is deliberately **not**
folded into that role: `clipse` is a console/TUI tool, not GUI desktop
customization, so it doesn't fit `desktop_customization`'s actual identity
(desktop-environment settings + GUI apps). The three tools here stay
together instead because they're a genuinely coupled functional unit, not
just topically similar:

- cliphist's autostart entry shells out to `wl-paste` (from `wl-clipboard`).
- The deployed `ch` shell function pipes `cliphist list | fzf | cliphist
  decode | wl-copy` across `cliphist`, `fzf` (external — see "Cross-role
  dependencies" below), and `wl-clipboard`.

## What it does

- Installs `wl-clipboard` via apt.
- Installs `cliphist` from GitHub releases and deploys an XDG autostart entry
  that runs `wl-paste --watch cliphist store`.
- Installs `clipse` from GitHub releases.
- Deploys `~/.config/zsh/conf.d/clipboard_tools.zsh` with a `ch` shell
  function (`cliphist list | fzf | cliphist decode | wl-copy`) and a
  `clipboard` alias for whichever tools are enabled.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README. Your `.zshrc`
must source `~/.config/zsh/conf.d/*.zsh` for the deployed shell aliases to
take effect.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `clipboard_tools_wl_clipboard_enabled` | `true` | Install wl-clipboard |
| `clipboard_tools_cliphist_enabled` | `true` | Install cliphist and deploy its autostart entry |
| `clipboard_tools_clipse_enabled` | `true` | Install clipse |
| `clipboard_tools_wl_clipboard_version` | see `defaults/main.yml` | Exact apt version of wl-clipboard (held after install) |
| `clipboard_tools_cliphist_version` | see `defaults/main.yml` | cliphist binary version (github-releases: `sentriz/cliphist`) |
| `clipboard_tools_cliphist_checksum` | see `defaults/main.yml` | Static sha256 checksum for the pinned cliphist binary (see "Checksum verification" below) |
| `clipboard_tools_clipse_version` | see `defaults/main.yml` | clipse archive version (github-releases: `savedra1/clipse`) |
| `clipboard_tools_clipse_archive` | see `defaults/main.yml` | Filename of the clipse release archive |
| `clipboard_tools_clipse_download_base` | see `defaults/main.yml` | Base URL the clipse archive and its `checksums.txt` are downloaded from |
| `clipboard_tools_deploy_shell_aliases` | `true` | Deploy `~/.config/zsh/conf.d/clipboard_tools.zsh` with the `ch` function and `clipboard` alias for enabled tools |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.clipboard_tools
```

## Tags

Every task carries its own tag(s) in addition to the umbrella
`clipboard_tools` tag, so a consuming playbook can filter to a single tool:

| Tool | Tags |
| --- | --- |
| wl-clipboard | `wl-clipboard`, `clipboard_tools` |
| cliphist (+ autostart entry) | `cliphist`, `clipboard_tools` |
| clipse | `clipse`, `clipboard_tools` |
| shell alias deployment | `wl-clipboard`, `cliphist`, `clipse`, `clipboard_tools` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

## Checksum verification

- **clipse** (`savedra1/clipse`) publishes a plain `sha256sum`-format
  `checksums.txt` per release — `get_url`'s `checksum:` param fetches and
  matches it directly by the source URL's basename, so there's no static
  checksum to keep in sync by hand when the version is bumped (same pattern
  as `cli_dev_env`'s lazygit).
- **cliphist** (`sentriz/cliphist`) publishes **only** raw per-platform
  binaries per release (e.g. `v0.7.0-linux-amd64`) — no `checksums.txt`,
  `.sha256`, or any other sidecar. This is the collection's documented
  "fall back to a static pinned checksum" exception, same posture as
  `cli_dev_env`'s neovim: `clipboard_tools_cliphist_checksum` is hand-pinned
  against the exact binary for `clipboard_tools_cliphist_version` and will
  go stale the next time the version is bumped. That staleness is
  deliberate friction (it forces a human to look at the new release and
  update the checksum before the bump can land), not a bug to work around.

## Soft cross-tool dependencies (documentation only, not hard-gated)

- **cliphist's autostart entry runs `wl-paste --watch cliphist store`** —
  a hard runtime dependency on `wl-clipboard`. If you disable
  `clipboard_tools_wl_clipboard_enabled` while leaving
  `clipboard_tools_cliphist_enabled: true`, the autostart entry is deployed
  anyway and fails at login (`wl-paste: command not found`). This is
  deliberately **not** hard-gated — disabling wl-clipboard while keeping
  cliphist enabled is an unusual, deliberate consumer choice, and adding a
  cross-variable `when:` here would only paper over a configuration a
  consumer should notice and fix themselves. Keep the two toggles in sync.

## Cross-role dependencies

- The deployed `ch` shell function (`cliphist list | fzf --with-nth 2 |
  cliphist decode | wl-copy`) requires **`fzf`**, which lives in the
  `modern_cli` role (`modern_cli_fzf_enabled`), not this one. Without it,
  `cliphist`/`clipse` still work via their own CLIs, but the `ch` alias
  itself won't run.
- This is a **two-way** soft coupling: `modern_cli`'s own README documents
  its `emoji-fzf`-driven `emoji` shell function depending on **this role's**
  `wl-copy` (`clipboard_tools_wl_clipboard_enabled`) to copy the selected
  emoji to the clipboard. Neither role hard-depends on the other
  (`meta/main.yml` `dependencies: []` on both sides, per this collection's
  role-independence convention) — both couplings degrade gracefully to "the
  shell function silently does nothing useful" if the other role isn't
  installed, not a hard failure.
