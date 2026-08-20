# swisstopo.workstation.terminal_env

Installs and configures the daily terminal environment: **zsh** (with
oh-my-zsh, powerlevel10k, and plugins), **tmux** (with TPM), and **kitty** —
all Catppuccin Mocha themed. Bundled together because they're the daily
terminal stack a developer reaches for as one unit, and zsh's XDG config
mechanism (`~/.config/zsh/conf.d/*.zsh`) is the integration point tmux's
auto-start snippet plugs into.

## What it does

- Installs zsh, bootstraps oh-my-zsh, and clones powerlevel10k plus the
  fzf-tab / zsh-autosuggestions / zsh-syntax-highlighting plugins at pinned
  versions.
- Deploys a Catppuccin-Mocha-themed `.zshrc` sourcing every
  `~/.config/zsh/conf.d/*.zsh` snippet, and sets zsh as the default login
  shell.
- Installs kitty with a Catppuccin Mocha `kitty.conf`.
- Installs tmux, TPM (Tmux Plugin Manager), and the Catppuccin Mocha tmux
  theme, and deploys a `tmux.conf` with vim-style pane navigation and a
  zsh snippet that auto-starts tmux on login.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

Requires `curl` and `git` on the target (oh-my-zsh's installer and every
plugin/theme clone in this role use them) — on a real workstation these are
provided by the `base` role, which every consuming playbook runs first. No
collection role is otherwise required to have run first.

## Execution order

Tasks run in a fixed order — **zsh, then kitty, then tmux** — because zsh
establishes `~/.config/zsh/conf.d/` and the `.zshrc` sourcing mechanism
(`for f in ~/.config/zsh/conf.d/*.zsh; do source "$f"; done`) that tmux's
shell-integration snippet (auto-start tmux on login) depends on. The tmux
section also creates `~/.config/zsh/conf.d/` itself as a defensive
no-op-if-exists safety net, in case the task order is ever changed.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `terminal_env_zsh_version` | see `defaults/main.yml` | zsh apt package version (deb datasource: Ubuntu Noble) |
| `terminal_env_zsh_omz_commit` | see `defaults/main.yml` | Pinned commit SHA of `ohmyzsh/ohmyzsh` used to fetch `install.sh` (no tags/releases published upstream; not Renovate-tracked, same posture as `modern_cli_bat_theme_ref`) |
| `terminal_env_zsh_powerlevel10k_version` | see `defaults/main.yml` | powerlevel10k theme version (github-tags: `romkatv/powerlevel10k`) |
| `terminal_env_zsh_fzf_tab_version` | see `defaults/main.yml` | fzf-tab plugin version (github-tags: `Aloxaf/fzf-tab`) |
| `terminal_env_zsh_autosuggestions_version` | see `defaults/main.yml` | zsh-autosuggestions plugin version (github-tags: `zsh-users/zsh-autosuggestions`) |
| `terminal_env_zsh_syntax_highlighting_version` | see `defaults/main.yml` | zsh-syntax-highlighting plugin version (github-tags: `zsh-users/zsh-syntax-highlighting`) |
| `terminal_env_tmux_version` | see `defaults/main.yml` | tmux apt package version (deb datasource: Ubuntu Noble) |
| `terminal_env_tmux_catppuccin_version` | see `defaults/main.yml` | Catppuccin tmux plugin version (github-releases: `catppuccin/tmux`) |
| `terminal_env_kitty_version` | see `defaults/main.yml` | kitty apt package version (deb datasource: Ubuntu Noble) |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.terminal_env
```

## Tags

Every task carries its own tag(s) in addition to the umbrella `terminal_env`
tag, so a consuming playbook can filter to a single tool:

| Tool | Tags |
| --- | --- |
| zsh (oh-my-zsh, powerlevel10k, plugins, default shell) | `zsh`, `terminal_env` |
| kitty | `kitty`, `terminal_env` |
| tmux (TPM, Catppuccin plugin, auto-start) | `tmux`, `terminal_env` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

## zsh

- Installed via apt, exact version pinned and held afterward
  (`allow_downgrade: true` so a machine with a newer stock zsh already
  installed doesn't hard-fail apt's default downgrade refusal).
- oh-my-zsh is installed via its shell script installer
  (`# noqa: command-instead-of-module` — no Ansible module alternative
  exists), fetched from a pinned commit SHA of `ohmyzsh/ohmyzsh` rather than
  the mutable `master` branch (the project publishes no tags/releases to pin
  a version to or verify a checksum against).
- powerlevel10k, fzf-tab, zsh-autosuggestions, and zsh-syntax-highlighting
  are cloned from GitHub at pinned version tags (checked via
  `git tag --points-at HEAD` for idempotency; on a version mismatch, the
  existing shallow clone is removed and re-cloned fresh at the new pinned
  tag rather than updated in place — a `depth: 1` clone doesn't have the new
  tag's objects available locally for `git checkout` to switch to).
- The Catppuccin Mocha theme for zsh-syntax-highlighting is cloned from
  `catppuccin/zsh-syntax-highlighting` (no version tags — pinned to initial
  clone; update manually by deleting the directory).
- `ZDOTDIR` is set to `~/.config/zsh/` in `/etc/zsh/zshenv` so zsh reads its
  config from the XDG directory.
- `.zshrc` is deployed from a Jinja2 template to `~/.config/zsh/.zshrc`
  (with a `~/.zshrc` symlink back to it); it sources every
  `~/.config/zsh/conf.d/*.zsh` snippet automatically — this is the mechanism
  every other role's shell integration (e.g. tmux's auto-start snippet)
  plugs into.
- Plugin load order in `.zshrc`: `git ansible terraform kubectl fzf-tab
  zsh-autosuggestions zsh-syntax-highlighting` — fzf-tab must load before
  zsh-autosuggestions.
- `.p10k.zsh` is deployed with `force: false` (not overwritten if already
  present).
- zsh is set as the default login shell.
- A direnv zsh hook is deployed to `~/.config/zsh/conf.d/direnv.zsh`; it
  assumes `direnv` itself is already installed (by the `base` role).
- `Ctrl+Z` is disabled (`stty susp undef`) to prevent accidentally
  backgrounding processes.

## kitty

- Installed via apt, exact version pinned and held afterward
  (`allow_downgrade: true`, same reasoning as zsh above).
- Configuration (Catppuccin Mocha, embedded in `kitty.conf`) is deployed to
  `~/.config/kitty/kitty.conf` with `force: false` so local edits survive
  re-runs.
- Font: JetBrains Mono Nerd Font — already installed by the `base` role, no
  action needed here beyond this dependency note.

## tmux

- Installed via apt, exact version pinned and held afterward
  (`allow_downgrade: true`, same reasoning as zsh above).
- TPM (Tmux Plugin Manager) is cloned to `~/.tmux/plugins/tpm`.
- The Catppuccin Mocha theme plugin is cloned to
  `~/.config/tmux/plugins/catppuccin/tmux` at the pinned version (manual
  install, recommended over TPM due to name conflicts); on a version
  mismatch it's removed and re-cloned fresh, same as the zsh plugins above.
- `tmux.conf` is deployed to `~/.config/tmux/tmux.conf`.
- Key bindings: `C-Space` prefix, vim-style pane navigation (`hjkl`),
  `Alt+1–9` for windows, `Ctrl+hjkl` for panes — smart: passes through to
  nvim splits when neovim is focused, detected via `#{pane_current_command}`.
  This pairs with the `christoomey/vim-tmux-navigator` plugin that lives in
  the `cli_dev_env` role's neovim config — a soft coupling via keybinding
  convention only (not a file-write dependency), so no task ordering or
  gating is needed between the two roles.
- A zsh snippet (`~/.config/zsh/conf.d/tmux.zsh`) auto-starts tmux on
  interactive login: the first terminal window gets a session named `main`;
  if `main` already exists (i.e. this isn't the first window), subsequent
  windows each get their own independent, unnamed session rather than
  attaching to the shared `main` session — deliberate, not a bug (see the
  inline comment on the task).
- **TPM plugins are NOT auto-installed by Ansible** — after first setup,
  press `prefix + I` inside tmux to install plugins
  (`tmux-sensible`, `tmux-resurrect`, `tmux-continuum`, `tmux-yank`,
  `tmux-open`).
- **tmux-resurrect** saves pane layout and running programs; restore with
  `prefix + Ctrl-r`.
- **tmux-continuum** auto-saves every 15 minutes and restores the last
  session on server start. Status is shown in the status bar
  (`Continuum: #{continuum_status}`).
- **tmux-yank** copies selections to the system clipboard in copy mode.
- **tmux-open** opens highlighted files/URLs with the default application
  from copy mode (`o`).
- `allow-passthrough on` is set to enable the Kitty graphics protocol to
  pass through tmux (required for `image.nvim` inline image rendering in
  Neovim).
