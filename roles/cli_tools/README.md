# pmuellerch.workstation.cli_tools

Installs modern replacements for the classic CLI tools: `bat` (cat), `btop`/`htop` (top), `eza` (ls), `fd` (find),
`ripgrep` (grep), `zoxide` (cd), `fzf` (fuzzy finder), `emoji-fzf` (emoji picker), `sd` (sed), `duf` (df), `gping`
(ping), `hexyl` (hexdump), `procs` (ps), `dust` (du), `viddy` (watch), `xcp` (cp), `doggo` (dig), `jaq` (jq), `moor`
(less) and `yazi` (file manager). Each tool is independently toggleable. Split out of the former `modern_cli` role;
`delta` moved to `git`, `presenterm` to `editor`.

`bat`, `btop`, `fzf` and `yazi` are Catppuccin-Mocha themed (the collection-wide theme; the other tools have no official
port or no themeable config). `emoji-fzf` covers only the CLI picker — the GUI picker (`smile`) belongs to
`desktop_customization`.

> **Size:** with 21 components this role is above the "~8 components per role" budget from #130. They are small,
> independent task files behind per-tool switches (about 700 task lines in total), and the tools share nothing but the
> shell snippet, so a finer split would only add roles without isolating any Renovate churn.

## What it does

- Installs the tools via apt, checksum-verified GitHub release downloads, or pipx (`emoji-fzf`).
- Deploys the Catppuccin Mocha themes for `bat`, `btop`, `fzf` and `yazi`.
- Deploys `~/.config/zsh/conf.d/cli_tools.zsh` with an alias per enabled tool, an `fzf` theme/integration, `zoxide` init
  and a `y` wrapper for yazi. The pre-split `modern_cli.zsh` is removed.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

Standalone; on a real workstation run `base` first. Your `.zshrc` must source `~/.config/zsh/conf.d/*.zsh` for the
aliases to take effect. `emoji-fzf`'s `emoji` function pipes through `wl-copy` (`clipboard_tools`).

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `cli_tools_github_api_token` | see `defaults/main.yml` | Optional GitHub API token, only to raise the rate limit when resolving release-asset digests (dust, jaq, moor, procs, xcp, yazi). Defaults to `GH_TOKEN`/`GITHUB_TOKEN` |
| `cli_tools_bat_enabled` | `true` | Whether to install bat. |
| `cli_tools_btop_enabled` | `true` | Whether to install btop. |
| `cli_tools_emoji_fzf_enabled` | `true` | Whether to install emoji-fzf via pipx (also gates the pipx bootstrap). Requires fzf and wl-copy (this collection's clipboard_tools role, clipboard_tools_wl_clipboard_enabled) at runtime for the deployed `emoji` shell function. |
| `cli_tools_eza_enabled` | `true` | Whether to install eza. |
| `cli_tools_fd_enabled` | `true` | Whether to install fd-find (and symlink it to fd). |
| `cli_tools_fzf_enabled` | `true` | Whether to install fzf. |
| `cli_tools_htop_enabled` | `true` | Whether to install htop. |
| `cli_tools_ripgrep_enabled` | `true` | Whether to install ripgrep. |
| `cli_tools_zoxide_enabled` | `true` | Whether to install zoxide. |
| `cli_tools_sd_enabled` | `true` | Whether to install sd. |
| `cli_tools_duf_enabled` | `true` | Whether to install duf. |
| `cli_tools_gping_enabled` | `true` | Whether to install gping. |
| `cli_tools_hexyl_enabled` | `true` | Whether to install hexyl. |
| `cli_tools_procs_enabled` | `true` | Whether to install procs. |
| `cli_tools_dust_enabled` | `true` | Whether to install dust (from a GitHub-released .deb). |
| `cli_tools_viddy_enabled` | `true` | Whether to install viddy. |
| `cli_tools_xcp_enabled` | `true` | Whether to install xcp. |
| `cli_tools_doggo_enabled` | `true` | Whether to install doggo. |
| `cli_tools_jaq_enabled` | `true` | Whether to install jaq. |
| `cli_tools_moor_enabled` | `true` | Whether to install moor (the tool formerly known as "moar" — upstream renamed it; the GitHub repo path is unchanged). |
| `cli_tools_yazi_enabled` | `true` | Whether to install yazi (from a GitHub-released .deb). |
| `cli_tools_bat_theme_ref` | see `defaults/main.yml` | Pinned commit of catppuccin/bat the theme file is downloaded from (immutable, unlike the "main" branch). |
| `cli_tools_bat_theme_checksum` | see `defaults/main.yml` | Checksum of the bat theme file at cli_tools_bat_theme_ref, verified by get_url. |
| `cli_tools_btop_catppuccin_version` | see `defaults/main.yml` | Release tag of catppuccin/btop to download the Mocha theme archive from. |
| `cli_tools_btop_catppuccin_checksum` | see `defaults/main.yml` | Checksum of the themes.tar.gz archive at cli_tools_btop_catppuccin_version, verified by get_url. |
| `cli_tools_fzf_version` | see `defaults/main.yml` | fzf version (github-releases junegunn/fzf), installed from a checksum-verified binary tarball. |
| `cli_tools_emoji_fzf_version` | see `defaults/main.yml` | emoji-fzf version (pypi), installed via pipx. |
| `cli_tools_pipx_min_version` | see `defaults/main.yml` | pipx version (pypi) installed via pip --user to satisfy community.general.pipx's >= 1.7.0 requirement, since Ubuntu 24.04's apt-provided pipx is only 1.4.3. Only used when cli_tools_emoji_fzf_enabled. |
| `cli_tools_procs_version` | see `defaults/main.yml` | procs version (github-releases dalance/procs), installed from a checksum-verified zip. |
| `cli_tools_dust_version` | see `defaults/main.yml` | dust version (github-releases bootandy/dust), installed from a checksum-verified .deb. |
| `cli_tools_viddy_version` | see `defaults/main.yml` | viddy version (github-releases sachaos/viddy), installed from a checksum-verified binary tarball. |
| `cli_tools_xcp_version` | see `defaults/main.yml` | xcp version (github-releases tarka/xcp), installed from a checksum-verified binary tarball. |
| `cli_tools_doggo_version` | see `defaults/main.yml` | doggo version (github-releases mr-karan/doggo), installed from a checksum-verified binary tarball. |
| `cli_tools_jaq_version` | see `defaults/main.yml` | jaq version (github-releases 01mf02/jaq), installed from a checksum-verified bare binary. |
| `cli_tools_moor_version` | see `defaults/main.yml` | moor version (github-releases walles/moar), installed from a checksum-verified bare binary. |
| `cli_tools_yazi_version` | see `defaults/main.yml` | yazi version (github-releases sxyazi/yazi), installed from a checksum-verified .deb. |
| `cli_tools_yazi_theme_ref` | see `defaults/main.yml` | Pinned commit of catppuccin/yazi the theme file is downloaded from (no releases/tags published upstream). |
| `cli_tools_yazi_theme_checksum` | see `defaults/main.yml` | Checksum of the yazi theme file at cli_tools_yazi_theme_ref, verified by get_url. |
| `cli_tools_deploy_shell_aliases` | `true` | Whether to deploy a zsh conf.d snippet (~/.config/zsh/conf.d/cli_tools.zsh) with aliases for each enabled tool. |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.cli_tools
```

## Tags

Every component has its own tag in addition to `cli_tools` (the tool name, `emoji_fzf` for emoji-fzf); `shell` selects
the alias snippet. The snippet is also (re)deployed whenever a single tool tag runs.

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

## Checksum verification

Most GitHub-release tools here verify their download against a checksum file
the upstream project publishes (`get_url`'s `checksum:` fetches it directly —
fzf, viddy, doggo). Six tools (`dust`, `jaq`, `moor`, `procs`,
`xcp`, `yazi`) publish **no** checksum file of any kind. Rather than hand-pin a
static checksum that goes stale on every Renovate version bump, the role
derives the checksum at run time from GitHub's own per-asset digest: it fetches
the release metadata from the GitHub API for the pinned version, reads the
asset's `sha256` digest, and feeds it to `get_url`. The checksum always matches
the pinned version, so a Renovate bump needs no manual checksum update. If
GitHub reports no digest for the asset, the role fails loudly rather than
skipping verification.

## pipx bootstrap

`emoji-fzf` is the only pipx-installed tool in this role. Since roles must
be independently runnable, `cli_tools` bootstraps its own adequate pipx
(`pip install --user pipx=={{ cli_tools_pipx_min_version }}`) rather than
assuming a consumer already upgraded the system pipx — identical to the
pattern used by the `code_quality_tools` role.

## moor (formerly "moar")

Upstream (repo `walles/moar`) renamed the tool itself to `moor` to resolve a
name clash — release assets and the installed binary are `moor`, not `moar`,
even though the GitHub repository path is unchanged. `cli_tools_moor_*`
variables and the `less='moor'` alias reflect the current name.

## yazi

Installed from a GitHub-released `.deb` (installs both `yazi` and its
companion `ya` CLI). The Catppuccin Mocha theme is deployed to
`~/.config/yazi/theme.toml` (yazi's expected config filename) — the "mauve"
accent variant, Catppuccin's default. A `y` shell function is deployed
alongside the other aliases: it wraps `yazi` so exiting it also `cd`s your
shell to whatever directory you navigated to inside the file manager
(yazi's own documented pattern, not custom to this role).

## apt package versions

Apt-installed tools in this role (`bat`, `btop`, `duf`, `eza`, `fd-find`,
`gping`, `hexyl`, `htop`, `ripgrep`, `sd`,
`zoxide`) install unpinned (`state: present`) — see the
[root README](../../README.md#apt-package-versions-are-unpinned) for why.
`dust` and `yazi` are downloaded as pinned, checksum-verified local `.deb`
files (their exact version determines which GitHub release artifact is
fetched) but, like every other package in this role, are no longer
dpkg-held after install — a held package blocks even a legitimate reinstall
of a newer pinned `.deb`.

### Known limitation: download staging

Release archives are downloaded to a fixed `/tmp` path and their checksum is verified at download time; the root-level
extraction follows. On a single-user workstation the window in between is accepted. (The AWS CLI and
session-manager-plugin downloads in `cloud_cli` and the OpenCode install in `ai_cli` use private directories instead.)
