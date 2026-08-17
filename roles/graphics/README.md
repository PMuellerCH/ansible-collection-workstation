# pmuellerch.workstation.graphics

Installs raster and vector graphics editing tools: Inkscape, GIMP, and Pinta.

## What it does

1. Installs `inkscape` and `gimp` via apt.
2. Bootstraps Flatpak and the Flathub remote (self-contained — doesn't assume the consumer already set this up).
3. Installs Pinta (`com.github.PintaProject.Pinta`) via Flatpak — not packaged in apt on Ubuntu 24.04.

## Variables

No configurable variables. Neither apt nor Flatpak have a supported Renovate datasource for these packages, so
none are version-pinned — apt and Flatpak manage updates themselves.

## Usage examples

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.graphics
```

## Notes

- **Inkscape** — vector graphics editor.
- **GIMP** — advanced raster image editor.
- **Pinta** — simple raster image editor (Paint.NET-like), installed via Flatpak since it isn't available in apt
  on Ubuntu 24.04 (Noble).

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
