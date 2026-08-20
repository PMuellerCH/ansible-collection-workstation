# swisstopo.workstation.modern_cli

Installs a set of modern CLI tool replacements: `bat` (cat), `btop` (top),
`emoji-fzf` (emoji picker), `eza` (ls), `fd`/`fd-find` (find), `fzf` (fuzzy
finder), `htop` (top), `presenterm` (terminal presentations), `ripgrep`
(grep), `zoxide` (cd). Each tool is independently toggleable and installed
regardless of the others — this role is a single parameterized entry point
for "modern CLI tool replacements" as a category.

`bat`, `btop`, and `fzf` are additionally Catppuccin-Mocha-themed — the fixed
collection-wide theme convention, not a variable. The other tools (`eza`,
`fd`, `htop`, `ripgrep`, `zoxide`) are installed only; they have no
themeable config file of their own.

`presenterm` here covers only the binary and its mermaid-diagram rendering
dependency (`nodejs` + `@mermaid-js/mermaid-cli`) — it deliberately does
**not** deploy the `presenterm.nvim` neovim plugin config; that belongs to
the `cli_dev_env` role's own neovim plugin management. Likewise `emoji-fzf`
covers only the CLI/TUI emoji picker — the GUI picker (`smile`, via Flatpak)
belongs to the `desktop_customization` role.

The `nodejs`/`npm` apt install (pinned via `modern_cli_presenterm_nodejs_version`
/ `_npm_version`, held afterward) only runs when no working `npm` is already
on `$PATH` (checked via `npm --version`). mermaid-cli only needs *some*
working Node/npm, not this exact version — if another role already provided
one (e.g. a newer NodeSource install), pinning and holding our own older apt
version would force an unwanted downgrade of a shared system runtime other
tools may depend on at a specific major version. This is different from
every other exact-pin-and-hold task in this role: those (bat, btop, eza,
etc.) each own their package outright, so a downgrade there only affects
that one tool.

## What it does

- Installs `bat`, `btop`, `eza`, `fd-find`, `fzf`, `htop`, `ripgrep`,
  `zoxide` via apt/GitHub releases.
- Installs `emoji-fzf` via pipx.
- Installs `presenterm` (binary + mermaid-cli rendering dependency).
- Deploys Catppuccin Mocha theming for `bat`, `btop`, and `fzf`.
- Deploys `~/.config/zsh/conf.d/modern_cli.zsh` with aliases for enabled
  tools.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

No Ansible role dependency (this role runs standalone in Molecule) — but on
a real workstation, run `base` first, per the root README. Your `.zshrc`
must source `~/.config/zsh/conf.d/*.zsh` for the deployed shell aliases to
take effect.

## External runtime dependencies not provided by this role

- `emoji-fzf`'s deployed `emoji` shell function pipes through `wl-copy`
  (from this collection's `clipboard_tools` role — specifically
  `clipboard_tools_wl_clipboard_enabled`) to copy the selected emoji to the
  clipboard. This is a two-way soft coupling: `clipboard_tools`' own README
  documents its `ch` shell function's dependency on this role's `fzf` in the
  other direction. Without wl-copy, `emoji-fzf`/`fzf` still work
  interactively but the result won't be copied automatically.
- `presenterm`'s mermaid diagram rendering (`mmdc`) expects
  `/usr/bin/google-chrome` per the deployed puppeteer config — install
  Google Chrome separately (not installed by this role) if you need mermaid
  diagrams rendered inside presentations.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `modern_cli_bat_enabled` | `true` | Install bat |
| `modern_cli_btop_enabled` | `true` | Install btop |
| `modern_cli_emoji_fzf_enabled` | `true` | Install emoji-fzf via pipx (also gates the pipx bootstrap) |
| `modern_cli_eza_enabled` | `true` | Install eza |
| `modern_cli_fd_enabled` | `true` | Install fd-find (symlinked to `fd`) |
| `modern_cli_fzf_enabled` | `true` | Install fzf |
| `modern_cli_htop_enabled` | `true` | Install htop |
| `modern_cli_presenterm_enabled` | `true` | Install presenterm (binary + mermaid-cli only) |
| `modern_cli_ripgrep_enabled` | `true` | Install ripgrep |
| `modern_cli_zoxide_enabled` | `true` | Install zoxide |
| `modern_cli_bat_version` | see `defaults/main.yml` | Exact apt version of bat |
| `modern_cli_btop_version` | see `defaults/main.yml` | Exact apt version of btop |
| `modern_cli_btop_catppuccin_version` | see `defaults/main.yml` | `catppuccin/btop` release tag for the theme archive |
| `modern_cli_emoji_fzf_version` | see `defaults/main.yml` | emoji-fzf PyPI package version, installed via pipx |
| `modern_cli_eza_version` | see `defaults/main.yml` | Exact apt version of eza |
| `modern_cli_fd_version` | see `defaults/main.yml` | Exact apt version of fd-find |
| `modern_cli_fzf_version` | see `defaults/main.yml` | fzf binary version (github-releases: `junegunn/fzf`) |
| `modern_cli_htop_version` | see `defaults/main.yml` | Exact apt version of htop |
| `modern_cli_presenterm_version` | see `defaults/main.yml` | presenterm binary version (github-releases: `mfontanini/presenterm`) |
| `modern_cli_presenterm_download_base` | see `defaults/main.yml` | Base URL the presenterm archive and its `.sha512` checksum are downloaded from |
| `modern_cli_presenterm_archive` | see `defaults/main.yml` | Filename of the presenterm release archive |
| `modern_cli_presenterm_mermaid_cli_version` | see `defaults/main.yml` | `@mermaid-js/mermaid-cli` npm version for mermaid rendering |
| `modern_cli_presenterm_nodejs_version` | see `defaults/main.yml` | Exact apt version of nodejs, required for mermaid-cli |
| `modern_cli_presenterm_npm_version` | see `defaults/main.yml` | Exact apt version of npm (not pulled in automatically by nodejs — only a Suggests, not a Depends) |
| `modern_cli_ripgrep_version` | see `defaults/main.yml` | Exact apt version of ripgrep |
| `modern_cli_zoxide_version` | see `defaults/main.yml` | Exact apt version of zoxide |
| `modern_cli_pipx_min_version` | see `defaults/main.yml` | pipx version bootstrapped via `pip --user` so `community.general.pipx` (needs >=1.7.0) works on Ubuntu 24.04's apt-provided pipx 1.4.3. Only used when `modern_cli_emoji_fzf_enabled` |
| `modern_cli_deploy_shell_aliases` | `true` | Deploy `~/.config/zsh/conf.d/modern_cli.zsh` with aliases for enabled tools |
| `modern_cli_bat_theme_ref` | see `defaults/main.yml` | Pinned commit of `catppuccin/bat` the theme file is downloaded from |
| `modern_cli_bat_theme_checksum` | see `defaults/main.yml` | Checksum of the bat theme file, verified by `get_url` |
| `modern_cli_btop_catppuccin_checksum` | see `defaults/main.yml` | Checksum of the btop themes archive, verified by `get_url` |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.modern_cli
```

## Tags

Every task carries its own tag(s) in addition to the umbrella `modern_cli`
tag, so a consuming playbook can filter to a single tool:

| Tool(s) | Tags |
| --- | --- |
| bat | `bat`, `modern_cli` |
| btop | `btop`, `modern_cli` |
| emoji-fzf | `emoji_fzf`, `modern_cli` |
| eza, fd, ripgrep, zoxide | `cli-tools`, `modern_cli` |
| fzf | `fzf`, `modern_cli` |
| htop | `htop`, `modern_cli` |
| presenterm | `presenterm`, `modern_cli` |
| shell alias deployment | `bat`, `btop`, `cli-tools`, `emoji_fzf`, `fzf`, `presenterm`, `modern_cli` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.
Rely on the tasks' own tags; Ansible filters `--tags` across the whole play,
not per role.

## pipx bootstrap

`emoji-fzf` is the only pipx-installed tool in this role. Since roles must
be independently runnable, `modern_cli` bootstraps its own adequate pipx
(`pip install --user pipx=={{ modern_cli_pipx_min_version }}`) rather than
assuming a consumer already upgraded the system pipx — identical to the
pattern used by the `code_quality_tools` role.
