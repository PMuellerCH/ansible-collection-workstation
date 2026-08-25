# swisstopo.workstation.cli_dev_env

Installs core CLI developer-environment tools: `lazygit` (git TUI, GitHub
release binary), `neovim` (GitHub release binary, bootstrapped into a
[LazyVim](https://www.lazyvim.org/) configuration), and the
[Claude Code](https://docs.claude.com/en/docs/claude-code) CLI (npm, with
Node.js sourced from NodeSource). Also deploys the
[presenterm.nvim](https://github.com/Piotr1215/presenterm.nvim) LazyVim
plugin config — the neovim-plugin half of presenterm support; the presenterm
*binary* itself, plus its mermaid-cli dependency and zsh snippet, live in the
`modern_cli` role instead (see "presenterm.nvim plugin toggle" below for why
this split needs a toggle).

`lazygit`, `neovim`, and Claude Code are bundled here because all three are
CLI-first tools a developer reaches for directly in the terminal for the same
core workflow (editing code, managing git, working with an AI coding agent) —
unlike e.g. Slack/Teams (chat) or trivy/checkov (scanning), which got their
own roles for their own category.

## What it does

- Installs `lazygit` from GitHub releases with Catppuccin Mocha config.
- Installs `neovim` from GitHub releases and bootstraps a LazyVim
  configuration with Catppuccin Mocha, tmux-aware pane navigation, and a set
  of language extras.
- Deploys the `presenterm.nvim` plugin config (toggleable independently).
- Installs the Claude Code CLI via npm, plus its NodeSource Node.js
  dependency, and wires up a default set of MCP servers.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

An OS-level `git` binary must already be present (the LazyVim starter clone
uses `ansible.builtin.git`, which shells out to it) — on a real workstation
this is provided by the `base` role, which every consuming playbook runs
first. No collection role is otherwise required to have run first.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `cli_dev_env_lazygit_enabled` | `true` | Install lazygit |
| `cli_dev_env_neovim_enabled` | `true` | Install neovim and bootstrap LazyVim. Also gates the presenterm.nvim plugin config below |
| `cli_dev_env_neovim_presenterm_plugin_enabled` | `true` | Deploy the presenterm.nvim plugin config (see below) |
| `cli_dev_env_neovim_lazy_sync_enabled` | `true` | Run a headless `lazy.nvim` sync on every apply (see "Headless plugin sync" below) |
| `cli_dev_env_claude_code_enabled` | `true` | Install the Claude Code CLI, its NodeSource Node.js dependency, and configure its MCP servers |
| `cli_dev_env_lazygit_version` | see `defaults/main.yml` | lazygit version (github-releases: `jesseduffield/lazygit`) |
| `cli_dev_env_lazygit_download_base` | see `defaults/main.yml` | Base URL the lazygit archive and its `checksums.txt` are downloaded from |
| `cli_dev_env_neovim_version` | see `defaults/main.yml` | Neovim version (github-releases: `neovim/neovim`) |
| `cli_dev_env_neovim_checksum` | see `defaults/main.yml` | Static sha256 checksum for the pinned neovim archive (see below) |
| `cli_dev_env_claude_code_nodejs_major_version` | `"24"` | Node.js LTS major version — selects which NodeSource apt repo to add. `nodejs`/`build-essential` themselves install unpinned, see [root README](../../README.md#apt-package-versions-are-unpinned) |
| `cli_dev_env_claude_code_version` | see `defaults/main.yml` | `@anthropic-ai/claude-code` npm package version (npm datasource) |
| `cli_dev_env_claude_code_aws_profile` | `default` | `AWS_PROFILE` passed to the `awslabs.core` MCP server |
| `cli_dev_env_claude_code_aws_region` | `eu-central-1` | `AWS_REGION` passed to the `awslabs.core` MCP server |
| `cli_dev_env_claude_code_github_token` | `""` | GitHub PAT passed as `GITHUB_PERSONAL_ACCESS_TOKEN` to the `github` MCP server (from the consumer's own secret store) |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: swisstopo.workstation.cli_dev_env
      vars:
        cli_dev_env_claude_code_aws_profile: default
        cli_dev_env_claude_code_aws_region: eu-central-1
        cli_dev_env_claude_code_github_token: "{{ vault_github_pat }}"
```

## Tags

Every task carries its own tag(s) in addition to the umbrella `cli_dev_env`
tag, so a consuming playbook can filter to a single tool:

| Tool | Tags |
| --- | --- |
| lazygit | `lazygit`, `cli_dev_env` |
| neovim (+ LazyVim bootstrap) | `neovim`, `cli_dev_env` |
| presenterm.nvim plugin config | `presenterm`, `cli_dev_env` |
| Claude Code CLI (+ NodeSource Node.js) | `claude-code`, `cli_dev_env` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

The presenterm.nvim tasks carry their **own** distinct `presenterm` tag
rather than riding along on `neovim`'s tag, and deliberately duplicate the
"ensure the nvim plugins directory exists" task instead of relying on
neovim's copy of it. This keeps `--tags presenterm` fully self-sufficient: it
does not implicitly depend on the `neovim` tag having also run in the same
invocation.

## lazygit

- Binary installed from GitHub releases to `/usr/local/bin/lazygit`; the
  installed version is checked via `lazygit --version` before downloading,
  for idempotency.
- The download is checksum-verified against upstream's aggregate
  `checksums.txt` (a plain `sha256sum`-format file, fed directly to
  `get_url`'s `checksum:` param — no custom fetch/parse tasks needed, and no
  static checksum to keep in sync by hand across version bumps).
- Configuration deployed to `~/.config/lazygit/config.yml` with the
  Catppuccin Mocha (blue) colour theme, `force: false` so a user's own edits
  to the file are never overwritten.

## neovim

- The `nvim-linux-x86_64.tar.gz` archive is extracted to `/opt/`; a symlink
  `/usr/local/bin/nvim → /opt/nvim-linux-x86_64/bin/nvim` is created.
- **Checksum**: unlike lazygit, `neovim/neovim` publishes **no** per-release
  checksum file of any kind — this is the collection's documented "fall back
  to a static pinned checksum" case. `cli_dev_env_neovim_checksum` is
  hand-pinned against the exact archive for `cli_dev_env_neovim_version` and
  will go stale the next time the version is bumped — that staleness is
  deliberate friction (it forces a human to look at the new release and
  update the checksum before the bump can land), not a bug to work around.
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

Gated by `cli_dev_env_neovim_lazy_sync_enabled` (default `true`). Reports
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

The `presenterm.nvim` plugin config lives here (`cli_dev_env`) while the
`presenterm` binary it depends on lives in `modern_cli`
(`modern_cli_presenterm_enabled`) — two independent, independently
installable roles. Without a toggle, a consumer installing `cli_dev_env`
without `modern_cli` (or with `modern_cli_presenterm_enabled: false`) would
get a LazyVim plugin spec that lazy.nvim happily installs but that can never
actually render or execute anything, since `presenterm.nvim` shells out to
the real `presenterm` binary — this is a hard runtime dependency, not just
an editor-integration nicety.

`cli_dev_env_neovim_presenterm_plugin_enabled` (default `true`) gates the
plugin config deployment. **If you install both roles, keep this in sync
with `modern_cli_presenterm_enabled`** in whatever playbook wires them
together — that wiring is out of scope for this role.

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

## Claude Code

Installs the [Claude Code](https://docs.claude.com/en/docs/claude-code) CLI
globally via npm, plus the Node.js runtime it needs.

**Requires a [Claude Pro (or higher) subscription](https://claude.com/pricing)
and running `claude login` interactively after install** — this role only
installs and configures the CLI; it does not (and cannot) authenticate it.

### User-context install

The npm install itself (`community.general.npm`, `global: true`) runs
**without `become`**. npm's default global prefix is root-owned on a
NodeSource install (e.g. `/usr/lib/node_modules`), so a plain `global: true`
install would need root — instead, `NPM_CONFIG_PREFIX` is pointed at
`~/.local`, both as a task-level `environment:` override on the install
task itself, and persistently via
`~/.config/environment.d/npm-prefix.conf` (systemd user session env) for
the user's own future interactive `npm install -g`/Claude Code self-update
calls. **Not** a `prefix=` line in `~/.npmrc`: `base`'s own npm proxy-config
task fully overwrites that file on every run (when `base_http_proxy` is
set), so anything else writing into the same file fights it forever — found
live as a perpetual non-idempotency loop, same class of bug as `base`
colliding with `iac_tools` over `vault.zsh`. The `claude` binary ends up in
`~/.local/bin`, which `terminal_env`'s `.zshrc` already puts ahead of
`/usr/bin` on `PATH`. This means Claude Code can self-update (`claude
update` / auto-update) without root, and a re-run of this role doesn't need
root for the CLI itself either (Node.js/npm's own apt install still does).

If a machine already has the old root-owned global install from a previous
version of this role, it's detected (`stat
/usr/lib/node_modules/@anthropic-ai/claude-code`) and removed with a
one-time `become: true` cleanup task, so there isn't a second, never-updated
copy left on disk.

### Node.js management

Node.js is sourced from [NodeSource](https://github.com/nodesource/distributions)
rather than Ubuntu's apt repository, to track a current LTS major version:

- Prerequisites (`ca-certificates`, `curl`, `gnupg`) are installed, the
  NodeSource GPG key is fetched to `/etc/apt/keyrings/nodesource.asc`, and the
  repository is registered via `ansible.builtin.deb822_repository` for
  `cli_dev_env_claude_code_nodejs_major_version` (LTS major, e.g. `"24"`).
  Any legacy `/etc/apt/sources.list.d/nodesource.list` (the pre-`deb822`
  NodeSource setup format) is removed first.
- The installed `node --version` is checked; if a different major version is
  already installed, `nodejs` is removed before reinstalling unpinned from
  the newly-added NodeSource repo — this guards against a stale major
  version surviving a `cli_dev_env_claude_code_nodejs_major_version` bump.
  `build-essential` is installed alongside it (native npm dependency
  builds), also unpinned — see the
  [root README](../../README.md#apt-package-versions-are-unpinned) for why
  neither is exact-version-pinned or dpkg-held.
- **Out of scope for this role**: the `modern_cli` role also installs
  `nodejs`/`npm` from Ubuntu's apt repository (for `mermaid-cli`, guarded by
  its own "skip if npm already works" check). This role's NodeSource install
  and `modern_cli`'s apt install are independent and not coordinated here —
  a consuming playbook that runs both roles must order `cli_dev_env` before
  `modern_cli` so `modern_cli`'s guard sees a working NodeSource `npm` and
  skips its own (older) apt install, rather than downgrading Node.js. That
  ordering is the consuming playbook's responsibility, not this role's.

### MCP servers

The Claude Code CLI's global config (`~/.claude.json`) has the following
servers merged onto its `mcpServers` key on every run — both other top-level
keys in the file *and* any pre-existing `mcpServers` entries not listed below
are left untouched (`ansible.builtin.combine` twice: once over the whole
parsed JSON so unrelated top-level keys survive, and once inside `mcpServers`
itself so a server registered outside this role — e.g. via `claude mcp add`,
or `aws configure agent-toolkit`'s `aws-mcp` — survives a re-run instead of
being silently wiped). The servers below still win on conflict, so this role
remains authoritative for its own servers' config:

| Server | Command | Purpose |
| --- | --- | --- |
| `ansible` | `npx -y @ansible/ansible-mcp-server --stdio` | Ansible module/collection lookup |
| `awslabs.aws-documentation` | `uvx awslabs.aws-documentation-mcp-server@latest` | AWS documentation search |
| `awslabs.core` | `uvx awslabs.core-mcp-server@latest` | AWS MCP server discovery/routing (uses `cli_dev_env_claude_code_aws_profile`/`_aws_region`) |
| `terraform` | `npx -y terraform-mcp-server` | Terraform registry/provider lookup |
| `github` | `npx -y @modelcontextprotocol/server-github` | GitHub API access (uses `cli_dev_env_claude_code_github_token`) |
| `renovate` | `npx -y renovate-mcp` | Renovate config lookup |

The two `uvx`-launched servers (`awslabs.*`) set `UV_SYSTEM_CERTS: "true"` in
their own `env` block, on top of (belt-and-suspenders with) the `base` role's
global `UV_SYSTEM_CERTS` in `/etc/environment` — see that role's README for
why `uv`/`uvx` need this at all behind a TLS-inspecting corporate proxy.

A stray `mcpServers` key in `~/.claude/settings.json` (the *project/user
settings* file, distinct from `~/.claude.json`) is removed if present — MCP
servers belong exclusively in `~/.claude.json`, and an older Claude Code
version or manual edit may have left one there.

Both JSON-writing tasks run **without `become`** (as the invoking user, not
root) since they write into `$HOME` — same posture as the neovim/LazyVim
config tasks above.
