# pmuellerch.workstation.bitwarden

Installs the Bitwarden GUI desktop application and the `rbw` CLI client, configured for the bitwarden.eu server.

## What it does

1. Installs the Bitwarden GUI via a `.deb` downloaded from a GitHub release (see [Package installation order](../../CLAUDE.md)).
2. Installs the `rbw` CLI binary from a GitHub release tarball.
3. Deploys `~/.config/rbw/config.json`, pointing `rbw` at `vault.bitwarden.eu` / `identity.bitwarden.eu`.

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `bitwarden_version` | see `defaults/main.yml` | Bitwarden GUI version (github-releases: `bitwarden/clients`, tag pattern `desktop-v*`) |
| `bitwarden_rbw_version` | see `defaults/main.yml` | `rbw` binary version (github-releases: `doy/rbw`) |

### Other options

| Variable | Default | Description |
| --- | --- | --- |
| `bitwarden_email` | `""` | Email address written into `rbw`'s `config.json` — set this from your own inventory/vars, not the role default |

## Usage examples

Default install:

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.bitwarden
```

Setting the login email:

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.bitwarden
      vars:
        bitwarden_email: "you@example.com"
```

## Notes

- The Bitwarden `.deb` is downloaded to `/tmp` and installed via `apt`; the installed version is checked first for idempotency.
- Both install tasks (`.deb` GUI, `rbw` binary) skip in `--check` mode via `not ansible_check_mode` — the preceding
  download doesn't actually fetch the file in a dry run, so the install would otherwise fail.
- Neither upstream (`bitwarden/clients`, `doy/rbw`) publishes a plain checksum file for the Linux release assets
  that Ansible's `get_url` `checksum` parameter can consume directly (bitwarden's `latest-linux.yml` has a
  base64-encoded sha512, not a hex digest), so downloads are not checksum-verified — same as before this role
  was migrated.
- `~/.config/rbw/config.json` is rendered with `force: false` — not overwritten if already present, since `rbw` writes device tokens into it after first login.
- After first install, run `rbw login` to authenticate (prompts for master password).

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
