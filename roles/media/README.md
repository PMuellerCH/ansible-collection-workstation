# pmuellerch.workstation.media

Installs media and graphics tools: Inkscape, GIMP and Pinta (graphics), [beets](https://beets.io/) (music library
manager), Spotify with [ncspot](https://github.com/hrkfdn/ncspot) (Spotify TUI), and Plex Desktop with Plexamp.
Merged from the former `graphics` and `multimedia` roles.

## What it does

1. **flatpak** — bootstraps Flatpak and the Flathub remote (self-contained; needed by Pinta, Spotify and Plex, not
   by beets).
2. **graphics** — `inkscape` and `gimp` (apt) and Pinta (`com.github.PintaProject.Pinta`, Flatpak — not packaged in
   apt on Ubuntu 24.04).
3. **beets** — `libchromaprint-tools` and `ffmpeg` (apt), `beets` (pipx) with `pyacoustid` injected for the `chroma`
   AcoustID plugin, and `~/.config/beets/config.yaml` (first run only; local edits are preserved).
4. **spotify** — Spotify via Flatpak (`com.spotify.Client`) and `ncspot` from a checksum-verified GitHub release
   binary, plus `~/.config/ncspot/config.toml` (first run only).
5. **plex** — Plex Desktop (`tv.plex.PlexDesktop`) and Plexamp (`com.plexamp.Plexamp`) via Flatpak.

## Requirements

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes (molecule covers beets only; the Flatpak GUI apps are not a good fit for container tests) |

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `media_beets_version` | see `defaults/main.yml` | beets PyPI version, see defaults/main.yml |
| `media_beets_pyacoustid_version` | see `defaults/main.yml` | pyacoustid PyPI version (enables beets' chroma plugin), see defaults/main.yml |
| `media_ncspot_download_base` | see `defaults/main.yml` | Base URL the ncspot archive and its .sha256 file are downloaded from. |
| `media_ncspot_version` | see `defaults/main.yml` | ncspot binary version (GitHub release tag v<version>), see defaults/main.yml |
| `media_graphics_enabled` | `true` | Whether to install Inkscape, GIMP and Pinta (Flatpak). |
| `media_beets_enabled` | `true` | Whether to install beets (pipx) and deploy its config. |
| `media_spotify_enabled` | `true` | Whether to install Spotify (Flatpak) and ncspot. |
| `media_plex_enabled` | `true` | Whether to install Plex Desktop and Plexamp (Flatpak). |

Inkscape, GIMP, Pinta, Plex and Plexamp have no version variables: apt and Flatpak manage their versions, and there is
no Renovate datasource for them.

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.media
      vars:
        media_plex_enabled: false
```

## Tags

| Component | Tags |
| --- | --- |
| flatpak | `graphics`, `spotify`, `plex`, `media` |
| graphics | `graphics`, `media` |
| beets | `beets`, `media` |
| spotify | `spotify`, `media` |
| plex | `plex`, `media` |

**Do not** put an outer `tags:` on the role invocation in your play — it cascades to every task and defeats the per-component filtering.

## Notes

- **beets**: the AcoustID API key placeholder in `~/.config/beets/config.yaml` must be replaced manually after the
  run — register at <https://acoustid.org/login>. Files are **copied** into `~/Music` (originals kept); set
  `import.move: true` in the config to move instead.
- **spotify**: the Spotify apt repository has GPG key issues on Ubuntu Noble, so Flatpak is used. `ncspot` needs a
  Spotify Premium subscription; OAuth login triggers on first run. Launch Spotify with
  `flatpak run com.spotify.Client` or the TUI with `ncspot`. The ncspot archive is verified against upstream's
  per-asset `.sha256` file.
- **plex**: no TUI client is installed — no mature standalone Plex TUI with pre-built binaries exists.

### Known limitation: download staging

Release downloads land in a fixed `/tmp` path and their checksum is verified at download time; the root-level install
follows. On a single-user workstation the window in between is accepted (tracked in #170). The OnlyOffice and Brave apt
keys are fetched over TLS without a fingerprint pin (tracked in #171).
