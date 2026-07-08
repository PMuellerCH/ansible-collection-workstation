# swisstopo.workstation.git

Installs git via apt and configures global identity, default-branch, pull/push
strategy, editor, and SSH-based commit-signing preferences.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `git_version` | `1:2.43.0-1ubuntu7.3` | Exact apt package version of git to install |
| `git_user_name` | *(required)* | Value for `user.name` — no generic default exists |
| `git_user_email` | *(required)* | Value for `user.email` — no generic default exists |
| `git_default_branch` | `main` | Value for `init.defaultBranch` |
| `git_pull_rebase` | `true` | Whether `pull.rebase` is enabled |
| `git_push_default` | `simple` | Value for `push.default` |
| `git_editor` | `vim` | Value for `core.editor` |
| `git_signing_enabled` | `true` | Whether to configure SSH commit/tag signing |
| `git_signing_key` | `{{ ansible_facts['env']['HOME'] }}/.ssh/id_ed25519.pub` | SSH public key used as `user.signingkey`, only applied when `git_signing_enabled` |

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
