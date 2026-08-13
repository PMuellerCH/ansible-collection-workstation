# pmuellerch.workstation.synology

Installs Synology Drive Client, Synology Chat Client, and Synology Note Station Client, and pre-seeds Drive sync configuration.

## What it does

1. Installs all three clients via `.deb` downloaded from `synologydownload.com` (see [Package installation order](../../CLAUDE.md)).
2. Creates the local Drive sync-folder directories.
3. Pre-seeds `~/.SynologyDrive/data/db/sys.sqlite` with server connection details and two sync tasks (private +
   shared), by rendering and running a Python script once, so Drive comes up ready to sync on first login instead
   of needing manual setup.

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `synology_drive_version` | see `defaults/main.yml` | Synology Drive Client version — no Renovate datasource, update manually |
| `synology_chat_version` | see `defaults/main.yml` | Synology Chat Client version — no Renovate datasource, update manually |
| `synology_note_station_version` | see `defaults/main.yml` | Synology Note Station Client version — no Renovate datasource, update manually |
| `synology_drive_private_local` | `~/Documents/SynologyDrive/private` | Local path for the private sync folder |
| `synology_drive_shared_local` | `~/Documents/SynologyDrive/shared` | Local path for the shared sync folder |

### Other options

| Variable | Default | Description |
| --- | --- | --- |
| `synology_drive_server` | `""` | NAS hostname/domain for the pre-seeded connection — set from your own inventory/vars |
| `synology_drive_hostname` | `""` | Display name for the pre-seeded connection |
| `synology_drive_port` | `6690` | NAS Drive port |
| `synology_drive_username` | `""` | Drive account username |
| `synology_drive_ssl_signature` | `""` | NAS SSL certificate fingerprint — must be updated if the certificate is renewed |

## Usage examples

Default install (no pre-seeded connection):

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.synology
```

With a pre-seeded Drive connection:

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.synology
      vars:
        synology_drive_server: "nas.example.com"
        synology_drive_hostname: "nas1"
        synology_drive_username: "jane"
        synology_drive_ssl_signature: "00:11:22:...:ff"
```

## Notes

- All three install tasks skip in `--check` mode via `not ansible_check_mode` — the preceding download doesn't
  actually fetch the `.deb` in a dry run, so the install would otherwise fail.
- Synology doesn't publish a checksum Ansible's `get_url` can consume for these Linux assets, so downloads are
  not checksum-verified.
- Each client uses a different idempotency check because their installed-version format (`dpkg-query`) doesn't
  match their download-URL version format 1:1: Drive Client is `4.x.x-<build>` in the URL vs `8.x.x-<build>` in
  `dpkg`, so idempotency uses the build number; Chat Client is `1.x.x-<build>` in the URL vs `1.x.x~<build>`
  (tilde, no leading zero) in `dpkg`, so idempotency uses the base version only.
- Drive's connection database is only seeded once (`Check if Synology Drive database already exists` guards it)
  — session and NAS IP are left blank so the app prompts for login/DHCP-resolves the NAS on first run; only the
  connection metadata (server name, port, username, SSL fingerprint, sync-task folder mappings) is pre-seeded.
- After first launch, Synology Drive will prompt for the account password.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
