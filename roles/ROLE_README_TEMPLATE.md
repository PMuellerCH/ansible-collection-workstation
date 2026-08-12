# pmuellerch.workstation.<role_name>

One-sentence description of what this role installs/configures and why.

## What it does

1. Installs `<tool>` via <apt / GitHub release / Flatpak / npm / pipx> (see [Package installation order](../CLAUDE.md)).
2. Deploys config to `~/.config/<tool>/` (Catppuccin Mocha theme applied).
3. <any other steps — zsh conf.d snippet, systemd unit, etc.>

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `<role>_version` | `1.2.3` | Pinned version (Renovate-managed, see comment in `defaults/main.yml`) |
| `<role>_some_setting` | `false` | What it toggles and why you'd flip it |

### Internal vars (not for overriding)

Only include this section if the role has `_<role>_*` computed vars worth documenting (e.g. OS-derived paths).

## Usage examples

Default install:

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.<role_name>
```

Overriding a setting:

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.<role_name>
      vars:
        <role>_some_setting: true
```

## Notes

- Non-obvious behavior, known limitations, deviations from repo conventions (with reasons) — same bar as the root `README.md`'s troubleshooting guide.
- Idempotency caveats, check-mode guards, anything a future editor would trip over.

## Testing

```bash
cd roles/<role_name> && molecule test
```

*(omit this section entirely if the role has no `molecule/default/` scenario)*

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
