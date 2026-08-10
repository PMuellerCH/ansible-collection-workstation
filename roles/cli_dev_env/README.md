# swisstopo.workstation.cli_dev_env

Installs core CLI developer-environment tools: `lazygit` (git TUI, GitHub
release binary) and `neovim` (GitHub release binary, bootstrapped into a
[LazyVim](https://www.lazyvim.org/) configuration). Also deploys the
[presenterm.nvim](https://github.com/Piotr1215/presenterm.nvim) LazyVim
plugin config — the neovim-plugin half of what used to be a separate
`presenterm` role; the presenterm *binary* itself, plus its mermaid-cli
dependency and zsh snippet, live in the `modern_cli` role instead (see
"presenterm.nvim toggle" below for why this split needs a toggle).

`lazygit` and `neovim` are bundled here because both are CLI-first tools a
developer reaches for directly in the terminal for the same core workflow
(editing code, managing git), unlike e.g. Slack/Teams (chat) or trivy/checkov
(scanning) which got their own merged roles for their own category.

## Tagging (for backward-compatible selective runs)

Every task carries its own tag(s) in addition to the umbrella `cli_dev_env`
tag, so a consuming playbook can still filter by the tool's original
identity even though it's one role:

| Tool | Tags |
| --- | --- |
| lazygit | `lazygit`, `cli_dev_env` |
| neovim (+ LazyVim bootstrap) | `neovim`, `cli_dev_env` |
| presenterm.nvim plugin config | `presenterm`, `cli_dev_env` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

The presenterm.nvim tasks carry their **own** distinct `presenterm` tag
(matching computer-setup's original role name) rather than riding along on
`neovim`'s tag, and deliberately duplicate the "ensure the nvim plugins
directory exists" task instead of relying on neovim's copy of it — the same
redundancy the source computer-setup roles already had. This keeps
`--tags presenterm` fully self-sufficient: it does not implicitly depend on
the `neovim` tag having also run in the same invocation.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `cli_dev_env_lazygit_enabled` | `true` | Install lazygit |
| `cli_dev_env_neovim_enabled` | `true` | Install neovim and bootstrap LazyVim. Also gates the presenterm.nvim plugin config below |
| `cli_dev_env_neovim_presenterm_plugin_enabled` | `true` | Deploy the presenterm.nvim plugin config (see below) |
| `cli_dev_env_lazygit_version` | `0.64.0` | lazygit version (github-releases: `jesseduffield/lazygit`) |
| `cli_dev_env_lazygit_download_base` | see `defaults/main.yml` | Base URL the lazygit archive and its `checksums.txt` are downloaded from |
| `cli_dev_env_neovim_version` | `0.12.4` | Neovim version (github-releases: `neovim/neovim`) |
| `cli_dev_env_neovim_checksum` | see `defaults/main.yml` | Static sha256 checksum for the pinned neovim archive (see below) |

## Notes

### lazygit

- Binary installed from GitHub releases to `/usr/local/bin/lazygit`; the
  installed version is checked via `lazygit --version` before downloading,
  for idempotency.
- The download is checksum-verified against upstream's aggregate
  `checksums.txt` (a plain `sha256sum`-format file, fed directly to
  `get_url`'s `checksum:` param — no custom fetch/parse tasks needed, and no
  static checksum to keep in sync by hand across Renovate version bumps).
- Configuration deployed to `~/.config/lazygit/config.yml` with the
  Catppuccin Mocha (blue) colour theme, `force: false` so a user's own edits
  to the file are never overwritten.

### neovim

- The `nvim-linux-x86_64.tar.gz` archive is extracted to `/opt/`; a symlink
  `/usr/local/bin/nvim → /opt/nvim-linux-x86_64/bin/nvim` is created.
- **Checksum**: unlike lazygit (or `base`'s `uv`/nerd-fonts downloads),
  `neovim/neovim` publishes **no** per-release checksum file of any kind —
  this is the collection's documented "fall back to a static pinned
  checksum" case. `cli_dev_env_neovim_checksum` is hand-pinned against the
  exact archive for `cli_dev_env_neovim_version` and will go stale the next
  time Renovate bumps the version — that staleness is deliberate friction
  (it forces a human to look at the new release and update the checksum
  before the bump can land), not a bug to work around.
- The LazyVim starter (`https://github.com/LazyVim/starter.git`) is cloned
  to `~/.config/nvim/` on first run only (guarded by a stat check on
  `init.lua`); `.git` is removed afterwards so the config is not a
  submodule. This clones the default branch rather than an immutable ref,
  a deliberate exception to this collection's "never fetch from a mutable
  ref" convention: `LazyVim/starter` publishes no release tags at all — it
  is a template meant to be cloned once and then customized/committed by
  the user, not a versioned artifact this role tracks for updates. Re-runs
  never re-clone or overwrite an existing config.
- LazyVim extras are configured in `~/.config/nvim/lazyvim.json`:
  `ai.claudecode`, `lang.markdown`, `lang.terraform`, `lang.ansible`,
  `lang.yaml`, `lang.python`, `lang.json`. See "lang.terraform /
  lang.ansible coupling" below for why these aren't gated behind a toggle
  the way the presenterm.nvim plugin is.
- Colour scheme: Catppuccin Mocha (`lua/plugins/colorscheme.lua`).
- Keymaps: `jk` → `<Esc>` in insert mode; `Tab`/`Shift-Tab` cycle buffers;
  Space is the default LazyVim leader key.
- Split/pane navigation: `Ctrl+h/j/k/l` navigates between nvim splits and
  tmux panes seamlessly via `christoomey/vim-tmux-navigator`
  (`lua/plugins/tmux-navigator.lua`). This pairs with the `terminal_env`
  role's tmux pane bindings — a soft keybinding-convention coupling only, no
  file-write dependency and no gating needed (a user without the matching
  tmux config simply doesn't get cross-pane navigation; nvim-internal window
  navigation still works standalone).
- A zsh snippet is deployed to `~/.config/zsh/conf.d/neovim.zsh` setting
  `EDITOR=nvim`, `VISUAL=nvim`, and aliases `vi`/`vim` → `nvim`.
- On first `nvim` launch, LazyVim bootstraps all plugins automatically
  (requires an internet connection).

### presenterm.nvim plugin toggle

Before this migration, `computer-setup`'s `presenterm` role deployed the
`presenterm.nvim` plugin config *unconditionally*, in the same role that
installed the `presenterm` binary — so the plugin's runtime dependency was
always satisfied by construction. After this split, the plugin config lives
here (`cli_dev_env`) and the binary lives in `modern_cli`
(`modern_cli_presenterm_enabled`) — two independent, independently
installable roles. Without a toggle, a consumer installing `cli_dev_env`
without `modern_cli` (or with `modern_cli_presenterm_enabled: false`) would
get a LazyVim plugin spec that lazy.nvim happily installs but that can never
actually render or execute anything, since `presenterm.nvim` shells out to
the real `presenterm` binary — this is a hard runtime dependency, not just
an editor-integration nicety.

`cli_dev_env_neovim_presenterm_plugin_enabled` (default `true`, matching the
pre-split behaviour) gates the plugin config deployment. **If you install
both roles, keep this in sync with `modern_cli_presenterm_enabled` in
whatever playbook wires them together** — that wiring is out of scope for
this role (it's `computer-setup`'s job, not the collection's).

### `lang.terraform` / `lang.ansible` coupling — not gated

`lazyvim.json`'s `lang.terraform` and `lang.ansible` extras have a
similar-shaped coupling with the `iac_tools` role (which installs the actual
`terraform`/`ansible` CLIs), but it is a **much softer** coupling than
`presenterm.nvim`'s, and is deliberately left ungated:

- LazyVim's `lang.*` extras are editor-only LSP/syntax/formatter
  integrations. They install and manage their own tooling via
  [Mason](https://github.com/mason-org/mason.nvim) inside Neovim's own data
  directory, independent of whatever is (or isn't) on `$PATH` system-wide.
- Unlike `presenterm.nvim` — which shells out to the *system* `presenterm`
  binary to actually render a presentation, and does nothing useful at all
  without it — the `lang.terraform`/`lang.ansible` extras degrade
  gracefully on their own: worst case without `iac_tools` installed, you get
  LSP/syntax highlighting for `.tf`/`.yml` files with no working editor
  integration to lose, not a broken plugin spec.
- There's also no real analogue to `modern_cli_presenterm_enabled` to sync
  against: `iac_tools` doesn't have (and has no reason to have) a Neovim
  plugin-config toggle for `cli_dev_env` to coordinate with.

If Mason's own toolchain ever turns out to meaningfully conflict with a
system-installed `terraform`/`ansible` from `iac_tools` (e.g. version
skew causing confusing LSP behaviour), revisit this — but as shipped, no
toggle is added.

## Dependencies

`git` must already be present on the system — the LazyVim starter clone uses
`ansible.builtin.git`, which shells out to the real `git` binary. On a real
workstation this is provided by the `base` role, which every consuming
playbook runs first; Molecule's `prepare.yml` installs it explicitly to keep
this role's own scenario runnable in isolation (per this collection's role
independence convention — no other *collection* role is required to have
run first, but an OS-level `git` binary is assumed present, same as e.g.
`curl` or `tar`).

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
