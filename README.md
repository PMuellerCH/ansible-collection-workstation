# infra-ansible-collection-workstation

[![CI](https://github.com/swisstopo/infra-ansible-collection-workstation/actions/workflows/ci.yml/badge.svg)](https://github.com/swisstopo/infra-ansible-collection-workstation/actions/workflows/ci.yml)

An Ansible Collection (`swisstopo.workstation`) for provisioning and maintaining
IaC developer workstations running Ubuntu 24.04 with the COSMIC or GNOME desktop
environment.

## Roles

No role declares an Ansible role dependency on another (`meta/main.yml` is
empty everywhere), so every role can run standalone — this is what Molecule
tests. On a real workstation, run `base` first anyway: it sets up locale,
proxy, hostname, git, and fonts that other roles are written to assume are
already in place.

| Role | What it installs |
| --- | --- |
| [base](roles/base/README.md) | Base system packages, hostname, locale, corporate proxy, git, SSH, Python toolchain, fonts — run first |
| [cli_dev_env](roles/cli_dev_env/README.md) | lazygit, neovim (LazyVim), Claude Code CLI |
| [chat_clients](roles/chat_clients/README.md) | Slack, Microsoft Teams |
| [clipboard_tools](roles/clipboard_tools/README.md) | Wayland clipboard tooling: wl-clipboard, cliphist, clipse |
| [code_quality_tools](roles/code_quality_tools/README.md) | trivy, pre-commit, detect-secrets, yamllint, checkov, ansible-lint |
| [desktop_apps](roles/desktop_apps/README.md) | OnlyOffice Desktop Editors, Firefox policies |
| [desktop_customization](roles/desktop_customization/README.md) | GNOME/COSMIC workspace settings, Flameshot, emoji picker (GUI) |
| [gh](roles/gh/README.md) | GitHub CLI |
| [iac_tools](roles/iac_tools/README.md) | ansible-core, Docker CE, AWS CLI, Terraform/Vault, Kubernetes toolchain |
| [maintenance](roles/maintenance/README.md) | apt update/safe-upgrade, autoremove/autoclean, journal vacuum, Docker prune, Flatpak cleanup — for a separate maintenance playbook, not `site.yml` |
| [modern_cli](roles/modern_cli/README.md) | bat, btop, eza, fd, fzf, htop, presenterm, ripgrep, zoxide, emoji-fzf |
| [terminal_env](roles/terminal_env/README.md) | zsh, tmux, kitty |

Every role uses per-tool Ansible tags (in addition to an umbrella
`<role_name>` tag) so a consuming playbook can select a single tool with
`--tags <tool>` — see each role's own README for its tag table.

## apt package versions are unpinned

Packages installed via `ansible.builtin.apt` from a real, enabled repository
(Ubuntu archive, or a vendor's own apt repo — Docker, HashiCorp, GitHub CLI,
Brave, OnlyOffice, LibreWolf-via-extrepo) are installed unpinned
(`state: present`), not exact-version-pinned and dpkg-held. This is a
deliberate departure from this collection's usual "pin everything, Renovate
tracks it" convention, for apt packages specifically:

- **Holding breaks every future version bump.** apt refuses to change a
  dpkg-held package's version without `--allow-change-held-packages`. Any
  Renovate bump (or manual fix) of a pinned+held package's version failed
  to apply on any machine that had already run the playbook once, with
  `Held packages were changed and -y was used without
  --allow-change-held-packages` — confirmed in both `--check` and real
  runs. The three packages that stay pinned (`trivy`, `dust`, `yazi` — see
  below) now pass `allow_change_held_packages: true` on their own install
  task specifically to survive a stale hold left by an older version of
  this collection; every other apt-installed package here is unpinned
  instead, so no version is ever requested that could conflict with a
  hold in the first place.
- **Pins rot out of the archive independently.** A subset of these pins also
  tracked a Renovate `registryUrl` pointed at the base release pocket
  (`suite=noble`), which never receives point-release/security patches —
  those only live in `noble-updates`/`noble-security`. A pin set from a real
  machine's installed version could silently go stale and become
  uninstallable once the archive rotated past it, with no automated way for
  Renovate to notice or propose a fix.

Ongoing security patching for these packages is left to whatever update
mechanism the host actually runs — this collection's job is ensuring the
tooling exists, not being the system's ongoing patch mechanism. Note that
the `base` role itself disables apt's periodic/unattended-upgrade timers
(`/etc/apt/apt.conf.d/99disable-periodic`), so on a machine provisioned by
this collection nothing patches these packages automatically unless the
host owner re-enables that or runs `apt upgrade` by hand. Tools downloaded
as release artifacts (GitHub releases, vendor-published binaries/tarballs/
`.deb` files fetched directly by URL) are unaffected and stay exact-pinned
and checksum-verified as usual; only real apt-repo-installed packages
changed.

**Migrating an already-provisioned machine:** a machine that already ran an
older version of this collection has these packages `dpkg`-held from
before this change — nothing in the new tasks ever unholds them, since a
plain `state: present` install with no version never touches an
already-held package's state. Run `sudo apt-mark unhold $(apt-mark showhold)`
once (or list the specific packages) after upgrading to unblock both this
collection's own installs and any future manual `apt upgrade`. The three
packages that stay pinned (`trivy`, `dust`, `yazi` — see their roles) don't
need this: their install tasks now pass `allow_change_held_packages: true`
so a stale hold from an older role version can't block their own version
bumps.

## Continuous Integration

Lint (`ci.yml`), Molecule (`molecule.yml`), and release (`release-please.yml`) all run
as thin wrappers around reusable workflows in
[infra-github-shared-actions](https://github.com/swisstopo/infra-github-shared-actions),
so tooling versions and behavior stay in sync with the other Ansible collections
(e.g. `infra-ansible-collection-postgres`). Release-please authenticates as a GitHub
App (org secrets `RELEASE_BOT_APP_ID` / `RELEASE_BOT_PRIVATE_KEY`) so release PRs are
not blocked by the org policy on `github-actions[bot]`.

Molecule auto-discovers every role with a `roles/<name>/molecule/default/` scenario and
runs it as a matrix job, but only on the release-please PR, a Renovate PR, or manual
`workflow_dispatch` — not on every ordinary feature PR, since a full matrix run is too
slow to gate routine iteration (those get fast lint-only feedback from `ci.yml` instead).

Renovate automerges non-major updates (minor, patch, digest, pin) once CI is green;
major bumps stay on manual review. The config and the automerge policy come from the
shared `renovate/ansible` preset in `infra-github-shared-actions`, which this repo's
`renovate.json` extends rather than duplicating. That preset sets `platformAutomerge:
true`, so Renovate enables GitHub's native auto-merge on each eligible PR; the
`auto-merge` job in `molecule.yml` (the shared `ansible_renovate_auto_merge.yml`
reusable workflow) then supplies the single approval the default-branch ruleset requires,
but only after lint and Molecule on the PR head have passed. Without that approval job the
PRs would wait for a manual review. This repo keeps `prConcurrentLimit` at 5 to keep the
Molecule matrix load manageable, and pins `ansible-core` away from the broken 2.21.0. A
repo-local regex manager also covers `roles/*/files/requirements.yml`, which the shared
preset's top-level requirements manager does not match. If PRs stop automerging, check
that lint and Molecule are green on the PR head and that the `auto-merge` job approved it.
