# pmuellerch.workstation.multimedia

Installs [beets](https://beets.io/) (music library manager), Spotify + [ncspot](https://github.com/hrkfdn/ncspot)
(Spotify TUI), and Plex Desktop + Plexamp — each independently toggleable via `--tags`.

## What it does

1. Bootstraps Flatpak and the Flathub remote (self-contained — doesn't assume the consumer already set this up;
   needed by Spotify and Plex, not beets).
2. **beets**: installs `libchromaprint-tools` + `ffmpeg` (apt), `beets` (pipx) with `pyacoustid` injected for the
   `chroma` AcoustID fingerprinting plugin, and deploys `~/.config/beets/config.yaml` (first run only — local
   edits are preserved).
3. **spotify**: installs Spotify via Flatpak (`com.spotify.Client`) and `ncspot` (a Spotify TUI) from a GitHub
   release binary, deploying `~/.config/ncspot/config.toml` (first run only).
4. **plex**: installs Plex Desktop (`tv.plex.PlexDesktop`) and Plexamp (`com.plexamp.Plexamp`) via Flatpak — no
   configuration needed.

Each sub-tool's tasks are tagged (`beets`, `spotify`, `plex`) so `--tags` selects independently, e.g.
`ansible-playbook site.yml --tags beets`.

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `multimedia_beets_version` | see `defaults/main.yml` | beets PyPI version |
| `multimedia_beets_pyacoustid_version` | see `defaults/main.yml` | pyacoustid PyPI version (enables the `chroma` plugin) |
| `multimedia_ncspot_version` | see `defaults/main.yml` | ncspot binary version (github-releases: `hrkfdn/ncspot`) |

Plex and Plexamp have no configurable variables — Flatpak manages their versions automatically; there's no
Renovate-compatible datasource for either.

## Usage examples

Default install (all three):

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.multimedia
```

Only beets:

```bash
ansible-playbook site.yml --tags beets
```

## Notes

- **beets**: the AcoustID API key placeholder in `~/.config/beets/config.yaml` must be replaced manually after
  the playbook runs — register at <https://acoustid.org/login>. Files are **copied** into `~/Music` (originals
  kept); set `import.move: true` in the config to move instead.
- **spotify**: the Spotify apt repo has GPG key issues on Ubuntu Noble, so Flatpak is used instead. `ncspot`
  requires a Spotify Premium subscription; OAuth login triggers on first run. Launch Spotify with
  `flatpak run com.spotify.Client` or the TUI with `ncspot`.
- **plex**: no TUI client is installed — no mature standalone Plex TUI with pre-built binaries exists.
- Neither `hrkfdn/ncspot` publishes a checksum Ansible's `get_url` can consume for the Linux release asset, so
  that download is not checksum-verified.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
