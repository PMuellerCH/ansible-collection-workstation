# Changelog

## [0.1.5](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/v0.1.4...0.1.5) (2026-07-08)


### Bug Fixes

* cut release tags without a v prefix ([2e8d8f4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/2e8d8f4047c614f541fe392b126527b7e3a5cd44))
* cut release tags without a v prefix ([#27](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/27)) ([62882be](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/62882be8f7e320ef1f74362419066bc6de9f44ff))

## [0.1.4](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/v0.1.3...v0.1.4) (2026-07-08)


### Features

* add gh, git, and modern_cli roles ([ff31076](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/ff31076e61a460f5c1c8ffcd26035000413e186d))
* add gh, git, and modern_cli roles ([#24](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/24)) ([47a8ced](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/47a8ced839a2d7de50abd1d5f027a2c42a0bf905)), closes [#22](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/22)


### Bug Fixes

* address Copilot review findings on PR [#24](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/24) ([e1561c5](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/e1561c5817f2a20bd2e8a8869487cb67b4105e3b))
* address second Copilot review round on PR [#24](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/24) ([abfed0c](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/abfed0cb8f0e629fd1be62720ad71e77bbe5f874))
* address third Copilot review round on PR [#24](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/24) ([e17d237](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/e17d2374c4fdde0670f2e021b3e36d01dfafdc06))
* declare community.general dependency in requirements.yml ([ae3760c](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/ae3760cee08aefe51b1a08b34758d3aec8522be1))


### Miscellaneous

* merge main into feat/22-gh-git-modern-cli-roles ([907f216](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/907f2169de198a013006ab1918233c918f29828b))


### CI/CD

* migrate CI/CD to shared infra-github-shared-actions workflows ([10c70b6](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/10c70b66aabb718c77fa66f7cf2bf68281fd45b0)), closes [#18](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/18)
* migrate CI/CD to shared infra-github-shared-actions workflows ([#19](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/19)) ([81916d5](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/81916d5bc1e9339b571138d44cedc2dd8e75b836))
* retrigger after repo visibility change ([5f93a85](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5f93a85e054eaee1703591d4d4f9bab019b1ff03))
* retrigger workflow check ([a1c799b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/a1c799b1529c2f07de0f7ac16436a491a87a5efc))

## [0.1.3](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/v0.1.2...v0.1.3) (2026-05-26)


### Bug Fixes

* restore --- in galaxy.yml and prevent recurrence via generic updater ([#10](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/10)) ([3365431](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/3365431699bb4eb8f8eaee6d3c784e63fd092837))
* restore --- in galaxy.yml and switch release-please to generic updater ([f3fba28](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/f3fba28c44c7fb2485d51d706dda8fcdb6bca00e))

## [0.1.2](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/v0.1.1...v0.1.2) (2026-05-26)


### Bug Fixes

* resolve pre-commit markdownlint failures ([bfc4498](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/bfc4498f23704f4f6a50f3aa5b2902885996ac60)), closes [#7](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/7)
* resolve pre-commit markdownlint failures ([#8](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/8)) ([cdb8cf0](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/cdb8cf050c9618617331c8309c31a7f17f1bcfeb))

## [0.1.1](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/v0.1.0...v0.1.1) (2026-05-26)


### Features

* scaffold collection structure with CI, linting, and Release Please ([5f7310b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5f7310ba6f1da206f96eaca0cbef643f1c84251a)), closes [#1](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/1)
* scaffold collection structure with CI, linting, and Release Please ([#2](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/2)) ([d35aeb4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/d35aeb4571e0d8e5d0bb62b9d79a05725294f3a8)), closes [#1](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/1)


### Bug Fixes

* add empty requirements.yml so CI dependency step does not error ([4dd4cee](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/4dd4cee00225f352ec717c7f9adc16c7c0200b0a))
* add required galaxy tag for ansible-lint production profile ([60965c4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/60965c45580f32162597e71ba07545da26b204be))
* always run pip install, cache only speeds up downloads not install ([37fb9ba](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/37fb9bad81cf5ec42e96a683695db9ee7ffe4f1a))
* regenerate package-lock.json against public npm registry ([49164d0](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/49164d0e9f1f2c172352ba5ae73e167488ff9047))
* resolve markdownlint violations in CLAUDE.md and README.md ([f86634b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/f86634b566d7cca0880d0e4c50502ca47f05dc2c))


### Miscellaneous

* **deps:** update googleapis/release-please-action action to v5 ([8466e44](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/8466e44920d1b53c29ffd7901caac4f46bb3a1e3))
* **deps:** update googleapis/release-please-action action to v5 ([#4](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/4)) ([8872d2b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/8872d2b1645ceca50673f4b484a03ab79c0cf2c5))


### CI/CD

* skip pip install on cache hit ([0f87745](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/0f8774506230f782a5a1ff9b666498b67ba61192))

<!-- Release Please manages this file automatically. Do not edit manually. -->
