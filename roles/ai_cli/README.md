# pmuellerch.workstation.ai_cli

Installs the AI coding agent CLIs: [Claude Code](https://docs.claude.com/en/docs/claude-code) (npm, with a default set of
MCP servers), the [Kiro CLI](https://kiro.dev/cli/) (`kiro-cli`, official installer) and
[OpenCode](https://opencode.ai/) (pinned GitHub release, Mistral backend). Split out of the former `cli_dev_env` role.
These tools change fast, so they live in their own role: a Renovate bump of Claude Code or OpenCode only needs this
role's molecule scenario.

## What it does

1. **claude-code** — installs the CLI via npm into the user's prefix (`~/.local`), removes a legacy root-owned global
   install, and merges a default set of MCP servers into `~/.claude.json`.
2. **kiro** — installs `kiro-cli` via its official script, sets its default behaviour and deploys the `ki`/`kil` aliases.
3. **opencode** — installs a pinned, checksum-verified OpenCode into `~/.local/bin`, deploys a config pinning the default
   Mistral model and the `oc`/`ocr` aliases.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |

- **Node.js/npm** (Claude Code only): provided by the `base` role. Run `base` (or `--tags nodejs`) first.
- The Kiro install script needs a downloader (`curl` or `wget`), `unzip` and `sha256sum`; `base` provides `curl` and
  `unzip`, `coreutils` provides `sha256sum`. `cli.kiro.dev` must be reachable.
- OpenCode is downloaded from `github.com` and its checksum is resolved from `api.github.com`.

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `ai_cli_claude_code_enabled` | `true` | Whether to install the Claude Code CLI, and configure its MCP servers (needs Node.js/npm from the `base` role). |
| `ai_cli_kiro_enabled` | `true` | Whether to install the Kiro CLI (kiro-cli), set its default behaviour (v3 agent engine, tool auto-search, autonomous mode), and deploy its shell aliases. |
| `ai_cli_claude_code_version` | see `defaults/main.yml` | @anthropic-ai/claude-code npm package version (npm datasource). |
| `ai_cli_mcp_ansible_version` | see `defaults/main.yml` | Pinned version of the @ansible/ansible-mcp-server MCP server package (npm datasource, Renovate-managed). |
| `ai_cli_mcp_aws_documentation_version` | see `defaults/main.yml` | Pinned version of the awslabs.aws-documentation-mcp-server MCP server package (PyPI datasource, Renovate-managed). |
| `ai_cli_mcp_aws_core_version` | see `defaults/main.yml` | Pinned version of the awslabs.core-mcp-server MCP server package (PyPI datasource, Renovate-managed). |
| `ai_cli_mcp_terraform_version` | see `defaults/main.yml` | Pinned version of the terraform-mcp-server MCP server package (npm datasource, Renovate-managed). |
| `ai_cli_mcp_github_version` | see `defaults/main.yml` | Pinned version of the `github/github-mcp-server` release binary (github-releases datasource, Renovate-managed). |
| `ai_cli_mcp_github_asset` | `github-mcp-server_Linux_x86_64.tar.gz` | Release asset; its sha256 digest is fetched from the release API at run time. |
| `ai_cli_mcp_github_bin` | `~/.local/bin/github-mcp-server` | Install path, also the MCP server command. |
| `ai_cli_mcp_github_api_token` | `{{ ai_cli_github_api_token }}` | Optional token to raise the API rate limit for the digest lookup. |
| `ai_cli_mcp_renovate_version` | see `defaults/main.yml` | Pinned version of the renovate-mcp MCP server package (npm datasource, Renovate-managed). |
| `ai_cli_claude_code_aws_profile` | `default` | AWS_PROFILE passed to the awslabs.core MCP server. |
| `ai_cli_claude_code_aws_region` | `eu-central-1` | AWS_REGION passed to the awslabs.core MCP server. |
| `ai_cli_claude_code_github_token` | `""` | GitHub PAT passed as GITHUB_PERSONAL_ACCESS_TOKEN to the github MCP server (from the consumer's own secret store, e.g. Ansible Vault). Empty by default. |
| `ai_cli_kiro_bin` | see `defaults/main.yml` | Absolute path to the kiro-cli binary. Used to detect an existing install and to invoke the binary by full path, since ~/.local/bin is not guaranteed to be on $PATH for a non-interactive Ansible run. |
| `ai_cli_kiro_install_url` | `https://cli.kiro.dev/install` | URL of the official kiro-cli install script, downloaded and run when the binary is absent. Unpinned by necessity — kiro-cli is a self-updating binary with no versioned release asset to pin; see README. |
| `ai_cli_kiro_update` | `true` | When the binary is already present, run `kiro-cli update --non-interactive` to converge to the latest release. Set false to leave an existing install untouched. |
| `ai_cli_kiro_agent_engine` | `v3` | Value for the global `chat.agentEngine` setting ("v3 cli"). Applied via `kiro-cli settings`. |
| `ai_cli_kiro_tool_search_enabled` | `true` | Value for the global `toolSearch.enabled` setting ("autosearch for tools"). Applied via `kiro-cli settings`. |
| `ai_cli_kiro_disable_trust_all_confirmation` | `true` | Value for the global `chat.disableTrustAllConfirmation` setting. When true, the `ki` alias (which passes `--trust-all-tools`) starts autonomous chat without a per-launch confirmation prompt. |
| `ai_cli_kiro_sandbox_enabled` | `true` | Set up the Kiro local command sandbox (needs kiro-cli >= 2.31): install `bubblewrap` and `socat` and create `~/.kiro/settings/sandbox.json` if absent (never overwritten). |
| `ai_cli_kiro_sandbox_network_access` | `DEFAULT_BLOCKED` | `networkAccess` written to a newly created `sandbox.json`. Allowed hosts are `sandbox_network` permission rules of the team configuration. |
| `ai_cli_kiro_team_config_repo` | `""` | Git URL of the shared Kiro team configuration (steering, skills, hooks, permissions) with an idempotent `install.sh`. Empty disables it. Set per consumer. |
| `ai_cli_kiro_team_config_dest` | `~/Repos/infra-ai-skills` | Directory the team configuration repository is cloned to. |
| `ai_cli_kiro_team_config_version` | `main` | Branch or tag to check out (a tag is preferable). `install.sh` is re-run when the checkout changes. |
| `ai_cli_kiro_deploy_shell_aliases` | `true` | Whether to deploy ~/.config/zsh/conf.d/kiro.zsh with the chat and login aliases. |
| `ai_cli_kiro_alias_chat` | `ki` | Alias name for `kiro-cli chat --trust-all-tools` (autonomous mode). |
| `ai_cli_kiro_alias_login` | `kil` | Alias name for `kiro-cli login`. |
| `ai_cli_opencode_enabled` | `true` | Whether to install OpenCode (model-agnostic AI coding agent), deploy its default-model config, and deploy its shell aliases. |
| `ai_cli_opencode_bin` | see `defaults/main.yml` | Absolute path to the opencode binary. Used to detect an existing install, read the installed version, and invoke the binary by full path, since ~/.local/bin is not guaranteed to be on $PATH for a non-interactive Ansible run. |
| `ai_cli_opencode_version` | see `defaults/main.yml` | OpenCode version (github-releases anomalyco/opencode), installed from a release tarball verified against GitHub's per-asset digest. |
| `ai_cli_opencode_download_base` | see `defaults/main.yml` | Base URL the opencode release asset is downloaded from, before the filename. |
| `ai_cli_opencode_asset` | `opencode-linux-x64.tar.gz` | Linux x64 release asset filename. Contains a single flat `opencode` binary and is verified against GitHub's per-asset sha256 digest (OpenCode publishes no checksum file). |
| `ai_cli_opencode_github_api_token` | see `defaults/main.yml` | Optional GitHub API token used only to raise the rate limit when resolving the opencode release-asset digest. Defaults to the same GH_TOKEN/GITHUB_TOKEN env lookup as ai_cli_github_api_token. |
| `ai_cli_opencode_model` | `mistral/mistral-medium-2604` | Default model OpenCode talks to ("provider/model-id"), written into the deployed opencode.json. Defaults to a date-pinned Mistral AI model with tool-call support; mistral/codestral-2508 is a completion-focused alternative. The MISTRAL_API_KEY and `opencode` login are left to the user. |
| `ai_cli_opencode_deploy_config` | `true` | Whether to deploy ~/.config/opencode/opencode.json. The role owns only the top-level `model` key, rewriting the file only when it differs (user-added keys are preserved). |
| `ai_cli_opencode_deploy_shell_aliases` | `true` | Whether to deploy ~/.config/zsh/conf.d/opencode.zsh with the TUI and headless-run aliases. |
| `ai_cli_opencode_alias_tui` | `oc` | Alias name for `opencode` (interactive TUI). |
| `ai_cli_opencode_alias_run` | `ocr` | Alias name for `opencode run` (headless prompt, no TUI). |
| `ai_cli_github_api_token` | see `defaults/main.yml` | Optional GitHub API token, used only to raise the rate limit when resolving the opencode release-asset digest. |

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: pmuellerch.workstation.ai_cli
      vars:
        ai_cli_claude_code_aws_profile: default
        ai_cli_claude_code_aws_region: eu-central-1
        ai_cli_claude_code_github_token: "{{ vault_github_pat }}"
```

## Tags

| Component | Tags |
| --- | --- |
| claude-code | `claude-code`, `ai_cli` |
| kiro | `kiro`, `ai_cli` |
| opencode | `opencode`, `ai_cli` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

## Claude Code

Installs the [Claude Code](https://docs.claude.com/en/docs/claude-code) CLI
globally via npm. Node.js itself comes from the `base` role (see [Node.js](#nodejs)).

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
colliding with `cloud_cli` over `vault.zsh`. The `claude` binary ends up in
`~/.local/bin`, which `terminal_env`'s `.zshrc` already puts ahead of
`/usr/bin` on `PATH`. This means Claude Code can self-update (`claude
update` / auto-update) without root, and a re-run of this role doesn't need
root for the CLI itself either (the Node.js/npm install, done by `base`, does).

If a machine already has the old root-owned global install from a previous
version of this role, it's detected (`stat
/usr/lib/node_modules/@anthropic-ai/claude-code`) and removed with a
one-time `become: true` cleanup task, so there isn't a second, never-updated
copy left on disk.

Some `@anthropic-ai/claude-code` versions run a `postinstall` that installs the
native self-updating binary under `~/.local/share/claude/versions/<version>/`
and links `~/.local/bin/claude` to it while npm is still installing; npm's own
bin-linking step then fails with `EEXIST` although the pinned version is in
place. The role therefore skips the npm install when `~/.local/bin/claude`
already links into `versions/<pinned version>`, tolerates an `EEXIST` from the
npm task, and always finishes with a `claude --version` check that asserts the
installed version is at least `ai_cli_claude_code_version` (`>=`, so a
self-update past the pin does not fail the role).

### Node.js

Claude Code needs Node.js and npm. This role does not install them: the `base` role installs Node.js LTS from
NodeSource (`base_nodejs_major_version`). The role asserts `npm` is on `PATH` before touching Claude Code and fails
with a message pointing at `base` otherwise. Disable Claude Code with `ai_cli_claude_code_enabled: false` if you only
want the other agents.

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
| `ansible` | `npx -y @ansible/ansible-mcp-server@<version> --stdio` | Ansible module/collection lookup |
| `awslabs.aws-documentation` | `uvx awslabs.aws-documentation-mcp-server@<version>` | AWS documentation search |
| `awslabs.core` | `uvx awslabs.core-mcp-server@<version>` | AWS MCP server discovery/routing (uses `ai_cli_claude_code_aws_profile`/`_aws_region`) |
| `terraform` | `npx -y terraform-mcp-server@<version>` | Terraform registry/provider lookup |
| `github` | `~/.local/bin/github-mcp-server stdio` | GitHub API access (uses `ai_cli_claude_code_github_token`) |
| `renovate` | `npx -y renovate-mcp@<version>` | Renovate config lookup |

Every server is pinned to an exact version (`ai_cli_mcp_<server>_version` in
`defaults/main.yml`, tracked by Renovate), so nothing floats on `latest` at
login — important because the servers start with every Claude Code session and
the `github` server receives the GitHub token. A Renovate bump changes the
`args` in `~/.claude.json` on the next run. The `github` server is the
official `github/github-mcp-server` Go binary (it replaced the archived
`@modelcontextprotocol/server-github` npm package): it is installed from the
GitHub release into `~/.local/bin`, verified against GitHub's per-asset sha256
digest fetched at run time, and reinstalled when `ai_cli_mcp_github_version`
changes.

The two `uvx`-launched servers (`awslabs.*`) set `UV_SYSTEM_CERTS: "true"` in
their own `env` block, on top of (belt-and-suspenders with) the `base` role's
global `UV_SYSTEM_CERTS` in `/etc/environment` — see that role's README for
why `uv`/`uvx` need this at all behind a TLS-inspecting corporate proxy.

A stray `mcpServers` key in `~/.claude/settings.json` (the *project/user
settings* file, distinct from `~/.claude.json`) is removed if present — MCP
servers belong exclusively in `~/.claude.json`, and an older Claude Code
version or manual edit may have left one there.

Both JSON-writing tasks run **without `become`** (as the invoking user, not
root) since they write into `$HOME` — the same as every other user-config task in this role.

## Kiro CLI

Installs the [Kiro CLI](https://kiro.dev/cli/) (`kiro-cli`) for the target
user and sets its default behaviour: the **v3 agent engine**, **tool
auto-search**, and **autonomous mode** (trust-all-tools) wired into a short
`ki` shell alias. Also deploys a zsh `conf.d` snippet with `ki` (autonomous
chat) and `kil` (login) aliases.

**Authentication (`kiro-cli login`, aliased to `kil`) is interactive and is
left to the user** — this role installs and configures the CLI; it does not
log in.

### What it does

- Installs `kiro-cli` into the user's `~/.local/bin` via the official install
  script (`https://cli.kiro.dev/install --force`), but only when the binary is
  not already present, then re-checks that the binary exists.
- When the binary is already present, optionally runs `kiro-cli update
  --non-interactive` to converge to the latest release
  (`ai_cli_kiro_update`, default `true`).
- Persists three global settings via `kiro-cli settings`, each read as JSON
  first and written only when the current value differs (idempotent):
  - `chat.agentEngine = v3` — the v3 CLI agent engine.
  - `toolSearch.enabled = true` — tool auto-search.
  - `chat.disableTrustAllConfirmation = true` — so the autonomous `ki` alias
    starts without a per-launch confirmation prompt.
- Deploys `~/.config/zsh/conf.d/kiro.zsh` with:
  - `ki`  → `kiro-cli chat --trust-all-tools` (autonomous mode)
  - `kil` → `kiro-cli login`
- Sets up the **local command sandbox** (`ai_cli_kiro_sandbox_enabled`, needs
  kiro-cli >= 2.31): installs `bubblewrap` and `socat` (apt, root) and creates
  `~/.kiro/settings/sandbox.json` (`enabled: true`, `networkAccess:
  DEFAULT_BLOCKED`) only when it does not exist yet, so a hand-edited file is
  never overwritten. The allowed hosts are `sandbox_network` permission rules
  that belong to the team configuration, not to this role.
- Optionally installs the **team configuration** (opt-in: set
  `ai_cli_kiro_team_config_repo`): clones the repository to
  `ai_cli_kiro_team_config_dest`, checks out `ai_cli_kiro_team_config_version`
  (use a tag rather than a branch) and runs its `install.sh`, which is
  idempotent, symlinks steering/skills/agents into `~/.kiro/` and never
  overwrites a permissions file the user wrote. `install.sh` re-runs only when
  the checkout changed or `~/.kiro/steering/team` is missing. The repository may
  be private and needs the user's own git credentials (SSH key or token); this
  role does not manage them. Secrets such as Jira/Confluence tokens and the Kiro
  login stay with the user. Disabled by default because the value is
  user/organisation specific.

### Autonomous mode is an alias, not a setting

kiro-cli has no persistent "autonomous mode" setting. Autonomy is the
`--trust-all-tools` chat flag, which lets the agent run tools without asking
for confirmation. This role therefore makes autonomous mode the default by
baking the flag into the `ki` alias, and sets the global
`chat.disableTrustAllConfirmation` so the alias runs without an extra prompt.
Launch kiro-cli without the alias (`kiro-cli chat`) for an interactive,
confirm-each-tool session.

### kiro-cli is installed via the official script (unpinned)

`kiro-cli` is a self-updating single binary distributed only through the
official install script. Upstream publishes no versioned, individually
downloadable release asset, so there is nothing to exact-pin and
checksum-verify the way the binary installs in `desktop_integration` or `base`
do. The install URL is therefore an **unpinned remote source** — a deliberate
departure from this collection's "pin everything, Renovate tracks it"
convention, documented here like the
[apt-unpinned deviation](../../README.md#apt-package-versions-are-unpinned):

- The role only runs the installer when the binary is absent, so the unpinned
  fetch happens once per machine rather than on every run.
- Keeping the binary current afterwards is delegated to `kiro-cli update`
  (the tool's own supported mechanism), exposed through `ai_cli_kiro_update`.
- There is no Renovate manager for this version, by design: the binary tracks
  its own releases.

### Notes

- All kiro-cli tasks run as the target user (`become: false`): `kiro-cli` is a
  per-user binary in `~/.local/bin`, its settings live in the user's data
  directory, and the alias snippet is written under the user's home. The
  binary is always invoked by its full path (`ai_cli_kiro_bin`), because
  `~/.local/bin` is not guaranteed to be on `$PATH` for a non-interactive
  Ansible run.
- Install is detected with `ansible.builtin.stat` on `ai_cli_kiro_bin`
  (not `command -v`, which cannot work through the `command` module), and the
  binary is re-checked after the install step.
- The settings tasks read each value as JSON first and write only on a
  difference, so re-running the role reports no change once converged.
- Under `ansible-playbook --check` the install, update, and settings tasks are
  skipped (`not ansible_check_mode`), because they depend on the downloaded
  installer and a working binary; the alias-snippet deployment still runs.

## OpenCode

Installs [OpenCode](https://opencode.ai/) (`opencode`), a model-agnostic,
CLI-first AI coding agent, for the target user from a pinned GitHub release
tarball, deploys a config pinning its default model, and deploys `oc`/`ocr`
shell aliases. The backend here is **Mistral AI** (see
`ai_cli_opencode_model`).

**The `MISTRAL_API_KEY` and the `opencode` login are left to the user** — this
role installs and configures OpenCode but never writes the key and does not
authenticate it, exactly as Claude Code's `claude login` and kiro-cli's
`kiro-cli login` are left to the user. Provide the API key from your own
environment or secret store.

### What it does

- Downloads the `ai_cli_opencode_asset` tarball
  (`opencode-linux-x64.tar.gz` by default) for the pinned
  `ai_cli_opencode_version` and extracts the single flat `opencode`
  binary straight into `~/.local/bin`, but only when the installed version
  (read via `opencode --version`) differs from the pinned one.
- Deploys `~/.config/opencode/opencode.json` pinning the default model
  (`ai_cli_opencode_deploy_config`, default `true`). The role owns only
  the top-level `model` key: it reads any existing config, merges the desired
  model onto it, and rewrites the file only when `model` differs from
  `ai_cli_opencode_model`. A changed model therefore takes effect on a
  re-run (unlike a blind `force: false`), while any other keys a user added by
  hand are preserved (unlike a blind overwrite). This is a
  read-compare-then-write merge. If the
  existing file is not valid JSON (or not a JSON object), it cannot be merged
  into: the role replaces it with a minimal config and keeps a timestamped
  `.bak` alongside it (`copy`'s `backup: true`).
- Deploys `~/.config/zsh/conf.d/opencode.zsh`
  (`ai_cli_opencode_deploy_shell_aliases`, default `true`) with:
  - `oc`  → `opencode` (interactive TUI)
  - `ocr` → `opencode run` (headless: send a prompt, print the reply, no TUI)

### Model and backend

The default model is `mistral/mistral-medium-2604`: in OpenCode's models.dev
catalog, tool-call capable (262k context) and date-pinned rather than a
`-latest` alias. (The earlier default `devstral-medium-2507` is not in the
catalog, so OpenCode rejected the deployed config.) `mistral/codestral-2508` is
a completion-focused alternative. To list valid ids run
`opencode models mistral` once a Mistral key is configured. Mistral is
a built-in catalog provider for OpenCode, so no custom-provider config is
needed; only the `MISTRAL_API_KEY` in the user's own environment (which this
role never writes). Point `ai_cli_opencode_model` at any
`provider/model-id` OpenCode's catalog knows to switch model or provider.

### Pinned and checksum-verified (unlike kiro-cli)

In contrast to kiro-cli — whose upstream ships no versioned, individually
downloadable release asset, forcing an unpinned installer — OpenCode publishes
versioned release tarballs, so it is **exact-version-pinned
(`ai_cli_opencode_version`, Renovate-tracked via a
`github-releases` manager) and checksum-verified**, the same as the pinned, checksum-verified
binaries in the `git` and `editor` roles. This is the collection's normal "pin everything, Renovate tracks it"
convention, **not** a deviation — so OpenCode does not belong with the
[kiro-cli](#kiro-cli-is-installed-via-the-official-script-unpinned) or
[apt-unpinned](../../README.md#apt-package-versions-are-unpinned) exceptions.

anomalyco/opencode publishes no checksum file of any kind with its releases,
so the archive (as for neovim in the `editor` role) is verified against GitHub's own
per-asset sha256 digest: the role fetches the release metadata from the GitHub
API for the pinned version, reads the `sha256` digest of the asset, and feeds
it to `get_url`. The checksum is always derived from the pinned version, so a
Renovate version bump needs no manual checksum update, and if GitHub ever
reports no digest for the asset the role fails loudly rather than skipping
verification. `ai_cli_opencode_github_api_token` (defaulting to the same
`GH_TOKEN`/`GITHUB_TOKEN` lookup as `ai_cli_github_api_token`) only raises
the API rate limit for that digest fetch; unauthenticated runs still work,
subject to GitHub's 60 requests/hour per-IP limit. The metadata fetch is retried (3 retries, 15 s apart) to ride out
transient GitHub API rate limiting or errors; it still fails loudly if every
attempt fails.

### Notes

- All opencode tasks run as the target user (`become: false`): `opencode` is a
  per-user binary in `~/.local/bin`, its config lives under the user's home,
  and the alias snippet is written there too — the same user-context posture as
  kiro-cli and the Claude Code npm install. The binary is always invoked by its
  full path (`ai_cli_opencode_bin`), because `~/.local/bin` is not
  guaranteed to be on `$PATH` for a non-interactive Ansible run.
- Install is detected by reading `opencode --version` at
  `ai_cli_opencode_bin`; the download, checksum resolution, and extraction
  only run when the installed version differs from the pinned one, so a
  converged machine reports no change.
- Under `ansible-playbook --check` the digest fetch, download, and install
  tasks are skipped (`not ansible_check_mode`), because they depend on the
  fetched metadata and downloaded archive; the config and alias-snippet
  deployments still run.
