# pmuellerch.workstation.editor

Installs the editor and presentation tooling: `neovim` bootstrapped into a [LazyVim](https://www.lazyvim.org/)
configuration (Catppuccin Mocha, tmux-aware navigation, language extras), and `presenterm` (terminal presentations) with
its `mermaid-cli` rendering dependency. Split out of the former `cli_dev_env` (neovim) and `modern_cli` (presenterm)
roles.

## What it does

1. **neovim** — installs neovim from a checksum-verified GitHub release, clones the LazyVim starter on first run,
   deploys the LazyVim extras, Catppuccin colour scheme, tmux-navigator and keymaps config, the `presenterm.nvim`
   plugin config, a zsh snippet (`EDITOR`/`VISUAL`, `vi`/`vim` aliases) and runs a headless `lazy.nvim` sync.
2. **presenterm** — installs the `presenterm` binary (sha512-verified release archive), `mermaid-cli` (npm) with a
   puppeteer config, and a zsh `mmdc` wrapper.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

- `git` must be present: the LazyVim starter clone uses `ansible.builtin.git`. On a real workstation the `git` role
  provides it.
- `presenterm`'s mermaid-cli needs *some* working Node.js/npm. If none is on `PATH` the role installs `nodejs`/`npm`
  from the Ubuntu archive; the `base` role's NodeSource Node.js (`--tags nodejs`) is preferred, so run `base` first to
  avoid a second, older copy.
- `mmdc` expects `/usr/bin/google-chrome` per the deployed puppeteer config. Chrome is not installed by this role.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `editor_neovim_enabled` | `true` | Whether to install neovim and bootstrap the LazyVim configuration. Also gates the presenterm.nvim plugin config below. |
| `editor_presenterm_plugin_enabled` | `true` | Whether to deploy the presenterm.nvim plugin config (~/.config/nvim/lua/plugins/presenterm.lua). The presenterm binary this plugin needs is installed by editor_presenterm_enabled — keep the two in sync. Only applies when editor_neovim_enabled is true. |
| `editor_neovim_lazy_sync_enabled` | `true` | Whether to run a headless `lazy.nvim` sync (install + update + clean) on every apply, instead of relying on a human running :Lazy sync manually. Only applies when editor_neovim_enabled is true. |
| `editor_neovim_version` | `""` | Neovim version (github-releases neovim/neovim), installed from a checksum-verified archive. |
| `editor_github_api_token` | see `defaults/main.yml` | Optional GitHub API token used only to raise the rate limit when resolving the neovim and opencode release-asset digests. Defaults to GH_TOKEN/GITHUB_TOKEN from the environment; unauthenticated (empty) still works but is subject to GitHub's 60 requests/hour per-IP limit. |
| `editor_presenterm_enabled` | `true` | Whether to install presenterm (binary + mermaid-cli; the presenterm.nvim plugin config is controlled by editor_presenterm_plugin_enabled). |
| `editor_presenterm_version` | `""` | presenterm version (github-releases mfontanini/presenterm), installed from a checksum-verified binary tarball. |
| `editor_presenterm_download_base` | see `defaults/main.yml` | Base URL the presenterm archive and its .sha512 checksum file are downloaded from, before the filename. |
| `editor_presenterm_archive` | see `defaults/main.yml` | Filename of the presenterm release archive to download. |
| `editor_presenterm_mermaid_cli_version` | `""` | @mermaid-js/mermaid-cli npm version, installed globally for presenterm's mermaid diagram rendering. |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.editor
      vars:
        editor_presenterm_enabled: true
```

## Tags

| Component | Tags |
| --- | --- |
| neovim | `neovim`, `editor` |
| presenterm | `presenterm`, `editor` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

The `presenterm.nvim` plugin tasks carry the `presenterm` tag, so `--tags presenterm` also deploys the plugin config.

## neovim

- The `nvim-linux-x86_64.tar.gz` archive is extracted to `/opt/`; a symlink
  `/usr/local/bin/nvim → /opt/nvim-linux-x86_64/bin/nvim` is created.
- **Checksum**: unlike lazygit, `neovim/neovim` publishes **no** per-release
  checksum file of any kind. The archive is instead verified against GitHub's
  own per-asset digest: the role fetches the release metadata from the GitHub
  API for the pinned `editor_neovim_version`, reads the `sha256` digest of
  `nvim-linux-x86_64.tar.gz`, and feeds it to `get_url`. The checksum is always
  derived from the pinned version, so a Renovate version bump needs no manual
  checksum update. If GitHub ever reports no digest for the asset, the role
  fails loudly rather than skipping verification.
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
  `lang.yaml`, `lang.python`, `lang.json`. See
  the "`lang.terraform` / `lang.ansible` coupling" section below for why
  these aren't gated behind a toggle the way the presenterm.nvim plugin is.
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
- A headless `lazy.nvim` sync runs on every apply (see "Headless plugin
  sync" below) — plugins are installed and kept up to date without ever
  launching `nvim` interactively.

### Headless plugin sync

`nvim --headless "+Lazy! sync" +qa` runs after every plugin config file
above is deployed, so a single apply both configures and installs
everything on a fresh machine, and keeps plugins current on every
subsequent one — no manual `:Lazy sync` inside `nvim`, and no reliance on
LazyVim's own on-first-launch bootstrap. `Lazy! sync` (bang =
non-interactive) installs missing plugins, updates existing ones, and
removes ones no longer declared; the bang variant blocks until the sync
fully completes before `+qa` quits nvim, unlike the non-bang command.

Gated by `editor_neovim_lazy_sync_enabled` (default `true`). Reports
`changed` only when `~/.config/nvim/lazy-lock.json`'s *content* differs
before/after the sync — not a full guarantee that every plugin directory
is actually correct (e.g. `Lazy! sync` silently reinstalling a
missing/corrupted plugin directory without touching a version already
recorded in the lock file wouldn't flip this to `changed`), but a
practical, cheap signal that's accurate for the common case (a plugin was
actually added, updated, or removed) and — critically — required for
Molecule idempotence, since this task (unlike most in this role) must run
on every apply rather than being gated behind a one-time "already
installed" check.

**Individual plugin versions are not Renovate-tracked.** Every sync
resolves each plugin to whatever its declared branch/tag currently points
to (recorded in `lazy-lock.json`), not a pinned commit this collection
controls — unlike every other exact-version-pinned tool here. Achieving
per-plugin Renovate tracking would mean checking a `lazy-lock.json` into
this role as a static file and wiring a custom regex manager per plugin
entry, which doesn't scale with LazyVim's plugin count and would need
updating every time the plugin set changes. This is a deliberate,
documented deviation from the collection's version-pinning convention, not
an oversight — accept some potential plugin churn between applies in
exchange for automation over manual updates.

### presenterm.nvim plugin toggle

The `presenterm.nvim` plugin shells out to the real `presenterm` binary, so the plugin config is useless without it.
Both live in this role, behind two switches: `editor_presenterm_plugin_enabled` (plugin config, default `true`) and
`editor_presenterm_enabled` (binary + mermaid-cli, default `true`). Disabling only the binary leaves a plugin spec
that installs but cannot render anything; keep the two in sync. The plugin config is deployed by `neovim.yml` (it must
exist before the headless sync runs) and needs `editor_neovim_enabled`.

### `lang.terraform` / `lang.ansible` coupling — not gated

`lazyvim.json`'s `lang.terraform` and `lang.ansible` extras have a
similar-shaped coupling with the `cloud_cli` and `ansible_dev` roles (which install the
actual `terraform`/`ansible` CLIs), but it is a **much softer** coupling than
`presenterm.nvim`'s, and is deliberately left ungated:

- LazyVim's `lang.*` extras are editor-only LSP/syntax/formatter
  integrations. They install and manage their own tooling via
  [Mason](https://github.com/mason-org/mason.nvim) inside Neovim's own data
  directory, independent of whatever is (or isn't) on `$PATH` system-wide.
- Unlike `presenterm.nvim` — which shells out to the *system* `presenterm`
  binary to actually render a presentation, and does nothing useful at all
  without it — the `lang.terraform`/`lang.ansible` extras degrade
  gracefully on their own: worst case without `cloud_cli`/`ansible_dev` installed, you get
  LSP/syntax highlighting for `.tf`/`.yml` files with no working editor
  integration to lose, not a broken plugin spec.
- There is also no real analogue to `editor_presenterm_enabled` to sync
  against: `cloud_cli`/`ansible_dev` have no reason to have a Neovim
  plugin-config toggle for the `editor` role to coordinate with.

If Mason's own toolchain ever turns out to meaningfully conflict with a
system-installed `terraform`/`ansible` from `cloud_cli`/`ansible_dev` (e.g. version
skew causing confusing LSP behaviour), revisit this — but as shipped, no
toggle is added.
