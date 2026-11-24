# pmuellerch.workstation.git

Configures git and installs the git tooling: the global git config (identity, defaults, SSH commit/tag signing), the
GitHub CLI (`gh`), `lazygit` and `delta` (diff pager, Catppuccin Mocha). Replaces the git part of the former `base`
role, the `gh` role, `lazygit` from `cli_dev_env` and `delta` from `modern_cli`.

The variables use the `git_` prefix, so a consumer's top-level `git_user_name` / `git_user_email` are picked up directly
without a mapping in the playbook.

## What it does

1. **config** — installs `git` and sets `user.name`, `user.email`, `init.defaultBranch`, `pull.rebase`, `push.default`,
   `core.editor` and, when signing is enabled, SSH signing (`gpg.format`, `user.signingkey`, `commit.gpgsign`,
   `tag.gpgSign`).
2. **gh** — installs the GitHub CLI from the Ubuntu archive.
3. **lazygit** — installs lazygit from a checksum-verified GitHub release and deploys its Catppuccin Mocha config.
4. **delta** — installs `git-delta`, deploys the Catppuccin Mocha theme, wires it into the global git config as the pager
   and aliases `diff` to `delta` (`~/.config/zsh/conf.d/git.zsh`).

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

`git_user_name` and `git_user_email` are required (no sensible generic default).

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `git_lazygit_enabled` | `true` | Whether to install lazygit. |
| `git_lazygit_version` | see `defaults/main.yml` | lazygit version (github-releases jesseduffield/lazygit), installed from a checksum-verified archive. |
| `git_lazygit_download_base` | see `defaults/main.yml` | Base URL the lazygit archive and its checksums.txt are downloaded from, before the filename. |
| `git_delta_enabled` | `true` | Whether to install delta (apt package git-delta), with Catppuccin Mocha theming wired into git config. |
| `git_delta_catppuccin_ref` | see `defaults/main.yml` | Pinned commit of catppuccin/delta the theme gitconfig is downloaded from (no releases/tags published upstream). |
| `git_delta_catppuccin_checksum` | see `defaults/main.yml` | Checksum of the catppuccin.gitconfig file at git_delta_catppuccin_ref, verified by get_url. |
| `git_user_name` | *(required)* | Value for git's global user.name. No sensible generic default exists — must be supplied by the consumer. |
| `git_user_email` | *(required)* | Value for git's global user.email. No sensible generic default exists — must be supplied by the consumer. |
| `git_default_branch` | `main` | Value for git's global init.defaultBranch. |
| `git_pull_rebase` | `true` | Whether git pull rebases instead of merges (pull.rebase). |
| `git_push_default` | `simple` | Value for git's global push.default. |
| `git_editor` | `vim` | Value for git's global core.editor. Defaults to vim (always present on Debian/Ubuntu); override to your preferred editor. |
| `git_signing_enabled` | `true` | Whether to configure SSH-based commit/tag signing (gpg.format=ssh, user.signingkey, commit.gpgsign, tag.gpgSign). Disable if you don't sign commits. |
| `git_signing_key` | see `defaults/main.yml` | Path to the SSH public key used as git's user.signingkey. Only applied when git_signing_enabled is true. |
| `git_gh_enabled` | `true` | Whether to install the GitHub CLI (gh). |
| `git_deploy_shell_aliases` | `true` | Whether to deploy the zsh snippet aliasing diff to delta (requires git_delta_enabled). |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.git
      vars:
        git_user_name: Jane Doe
        git_user_email: jane@example.com
        git_editor: nvim
```

## Tags

| Component | Tags |
| --- | --- |
| config | `config`, `git` |
| gh | `gh`, `git` |
| lazygit | `lazygit`, `git` |
| delta | `delta`, `git` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

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

## delta git integration

Unlike bat/btop (standalone theme files), delta only does anything once it's
wired into git itself. This role sets `core.pager = delta` and
`delta.features = catppuccin-mocha` globally via `community.general.git_config`,
and downloads `catppuccin/delta`'s theme gitconfig (pinned to a commit SHA —
that repo publishes no releases/tags) to
`~/.config/git/catppuccin-delta.gitconfig`, included into the global
gitconfig via `include.path`. This is delta-specific
integration rather than generic git configuration, so it lives in `delta.yml` next to the delta install, not in
`config.yml`. The `diff` → `delta` alias is deployed to `~/.config/zsh/conf.d/git.zsh`.

## Migrating from `base`

The `base_git_*` variables were renamed to `git_*` (`base_git_user_name` → `git_user_name`, and so on). There are no aliases.

### Download staging

Release archives are staged in a private per-run directory (`ansible.builtin.tempfile`, mode 0700, created in the role's
`tasks/main.yml` and removed in an `always` section, also on failure) rather than fixed `/tmp` paths, so no other local
user can pre-create or swap a file between the checksum-verified download and the root-level extraction.
