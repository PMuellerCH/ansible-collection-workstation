# pmuellerch.workstation.betterbird

Installs [Betterbird](https://www.betterbird.eu/) (Thunderbird fork) via Flatpak and pre-configures it with email
(IMAP/SMTP), CalDAV calendars, and CardDAV contacts.

## What it does

1. Installs Betterbird via Flatpak (`eu.betterbird.Betterbird`, see [Package installation order](../../CLAUDE.md)).
2. Installs the `hunspell-de-ch` apt package for Swiss German spellcheck (used by other Hunspell-based apps too, not just Betterbird).
3. Registers the default profile via templated `profiles.ini`/`installs.ini` — Betterbird ignores a profile
   without a matching `[InstallXXXX]` section, so the install hash is extracted from any existing `installs.ini`
   before regenerating it.
4. Deploys `prefs.js` (first-run account setup, only if it doesn't already exist) and `user.js` (idempotent
   settings re-applied on every startup) with the mail identity, IMAP/SMTP servers, CalDAV calendars, and CardDAV
   address book.
5. Downloads a Swiss German dictionary extension into the profile's `distribution/extensions/` (treated as a system extension — auto-enabled, no user approval prompt).

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `betterbird_imap_port` | `993` | IMAP port (SSL) |
| `betterbird_smtp_port` | `465` | SMTP port (SSL) |
| `betterbird_profile_base` | `~/.var/app/eu.betterbird.Betterbird/.thunderbird` | Flatpak profile base directory |
| `betterbird_profile_dir` | `{{ betterbird_profile_base }}/profile.default` | Default profile directory |
| `betterbird_hunspell_de_ch_version` | see `defaults/main.yml` | `hunspell-de-ch` apt package version |
| `betterbird_dict_de_ch_version` | see `defaults/main.yml` | Swiss German dictionary extension version — no Renovate datasource, update manually |
| `betterbird_dict_de_ch_url` | see `defaults/main.yml` | Swiss German dictionary extension download URL |
| `betterbird_dict_de_ch_checksum` | see `defaults/main.yml` | Swiss German dictionary extension checksum |

### Other options

All default to `""` (or `[]` for `betterbird_calendars`) — set from your own inventory/vars:

| Variable | Description |
| --- | --- |
| `betterbird_email_address` | Email address for the mail identity |
| `betterbird_email_full_name` | Display name for the mail identity and signature |
| `betterbird_email_username` | IMAP/SMTP/CalDAV/CardDAV username |
| `betterbird_email_mobile` | Mobile number shown in the HTML signature |
| `betterbird_email_address_line1` / `_line2` | Address lines shown in the HTML signature |
| `betterbird_imap_host` | IMAP server hostname |
| `betterbird_smtp_host` | SMTP server hostname |
| `betterbird_caldav_base` | CalDAV base URL |
| `betterbird_caldav_principal` | CalDAV principal path segment |
| `betterbird_calendars` | List of `{uuid, name, slug, color, main}` — one CalDAV calendar each |
| `betterbird_carddav_url` | CardDAV address book URL |
| `betterbird_carddav_name` | CardDAV address book display name |

## Usage examples

Default install (Betterbird only, no account pre-configured):

```yaml
- hosts: localhost
  roles:
    - pmuellerch.workstation.betterbird
```

With an email account and one CalDAV calendar:

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.betterbird
      vars:
        betterbird_email_address: "jane@example.com"
        betterbird_email_full_name: "Jane Doe"
        betterbird_email_username: "jane"
        betterbird_imap_host: "mail.example.com"
        betterbird_smtp_host: "mail.example.com"
        betterbird_caldav_base: "https://nas.example.com:5001/caldav.php/"
        betterbird_caldav_principal: "jane%40example.com"
        betterbird_calendars:
          - uuid: "e2b297db-cf17-412d-99b3-117d2485e1d8"
            name: "Personal"
            slug: "personal"
            color: "#3182bd"
            main: true
```

## Notes

- Profile directory: `~/.var/app/eu.betterbird.Betterbird/.thunderbird/` (standard Flatpak data path — Betterbird
  is a Thunderbird fork and keeps the upstream profile directory name).
- `prefs.js` (first-run account setup) is deployed with `when: not ... exists` — not overwritten if already present.
- `user.js` (idempotent preferences) is always deployed and takes effect on the next Betterbird start.
- The Swiss German dictionary XPI is installed to `distribution/extensions/` in the profile base — treated as a
  system extension (auto-enabled, no user prompt).
- On first launch, Betterbird will prompt for the email and CalDAV/CardDAV account passwords.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 (COSMIC) | yes |
