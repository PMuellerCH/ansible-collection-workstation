# swisstopo.workstation.modern_cli

Installs a set of modern CLI tool replacements: `bat` (cat), `btop` (top),
`eza` (ls), `fd`/`fd-find` (find), `htop` (top), `ripgrep` (grep), `zoxide`
(cd). Each tool is independently toggleable. This role merges what used to
be several separate/duplicated implementations (`bat`, `btop`, and tools
bundled ad hoc inside a `cli-tools` role) into one parameterized role.

`bat` and `btop` are additionally Catppuccin-Mocha-themed — the fixed
collection-wide theme convention, not a variable. The other tools (`eza`,
`fd`, `htop`, `ripgrep`, `zoxide`) are installed only; they have no
themeable config file of their own.

## Tagging (for backward-compatible selective runs)

Every task carries its own tag(s) in addition to the umbrella `modern_cli`
tag, so a consuming playbook can still filter by the tool's original identity
even though it's one role:

| Tool(s) | Tags |
| --- | --- |
| bat | `bat`, `modern_cli` |
| btop | `btop`, `modern_cli` |
| eza, fd, ripgrep, zoxide | `cli-tools`, `modern_cli` |
| htop | `htop`, `modern_cli` |
| shell alias deployment | `bat`, `btop`, `cli-tools`, `modern_cli` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.
Rely on the tasks' own tags; Ansible filters `--tags` across the whole play,
not per role.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `modern_cli_bat_enabled` | `true` | Install bat |
| `modern_cli_btop_enabled` | `true` | Install btop |
| `modern_cli_eza_enabled` | `true` | Install eza |
| `modern_cli_fd_enabled` | `true` | Install fd-find (symlinked to `fd`) |
| `modern_cli_htop_enabled` | `true` | Install htop |
| `modern_cli_ripgrep_enabled` | `true` | Install ripgrep |
| `modern_cli_zoxide_enabled` | `true` | Install zoxide |
| `modern_cli_bat_version` | `0.24.0-1build1` | Exact apt version of bat |
| `modern_cli_btop_version` | `1.3.0-1` | Exact apt version of btop |
| `modern_cli_btop_catppuccin_version` | `1.0.0` | `catppuccin/btop` release tag for the theme archive |
| `modern_cli_eza_version` | `0.18.2-1` | Exact apt version of eza |
| `modern_cli_fd_version` | `9.0.0-1` | Exact apt version of fd-find |
| `modern_cli_htop_version` | `3.3.0-4build1` | Exact apt version of htop |
| `modern_cli_ripgrep_version` | `14.1.0-1` | Exact apt version of ripgrep |
| `modern_cli_zoxide_version` | `0.9.3-1` | Exact apt version of zoxide |
| `modern_cli_deploy_shell_aliases` | `true` | Deploy `~/.config/zsh/conf.d/modern_cli.zsh` with aliases for enabled tools |
| `modern_cli_bat_theme_ref` | `6810349b28055dce54076712fc05fc68da4b8ec0` | Pinned commit of `catppuccin/bat` the theme file is downloaded from |
| `modern_cli_bat_theme_checksum` | `sha256:395566f0...` | Checksum of the bat theme file, verified by `get_url` |
| `modern_cli_btop_catppuccin_checksum` | `sha256:5331e055...` | Checksum of the btop themes archive, verified by `get_url` |

**Note:** this role only drops the `modern_cli.zsh` snippet into `~/.config/zsh/conf.d/` —
it does not enable the aliases itself. Your `.zshrc` must actually source
`~/.config/zsh/conf.d/*.zsh` for them to take effect.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
