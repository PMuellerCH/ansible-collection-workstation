# Changelog

## [0.1.17](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.16...0.1.17) (2026-08-21)


### Features

* add maintenance role for apt upgrade and system cleanup ([#128](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/128)) ([d1804ee](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/d1804ee2aaa4795d367ad362e486eab5267f58b7))

## [0.1.16](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.15...0.1.16) (2026-08-21)


### Bug Fixes

* rename base role's vault ZSH snippet to avoid colliding with iac_tools ([#125](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/125)) ([89bb1f9](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/89bb1f966ea0bdc48514514c4e87ff60631664dd))


### Miscellaneous

* **deps:** update dependency @anthropic-ai/claude-code to v2.1.238 ([#122](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/122)) ([85f213a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/85f213ab4091d73623657ad941e8373945028dbf))
* **deps:** update dependency aws/aws-cli to v2.36.28 ([#123](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/123)) ([c56ee4b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/c56ee4b1fbf4ebddd91b61b71d9f9259347c1182))
* **deps:** update dependency ryanoasis/nerd-fonts to v3.5.1 ([#127](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/127)) ([24ca251](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/24ca251823603b9cc0cda3938ef3e879824258c2))

## [0.1.15](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.14...0.1.15) (2026-08-20)


### Features

* run molecule only for roles that actually changed ([#118](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/118)) ([c1be725](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/c1be7250ea0a270b1aaf6ea0cd2e1e7fe73d0b2a))


### Bug Fixes

* content-aware check for .github/requirements.txt changes ([#121](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/121)) ([b0a4659](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/b0a465913661f3b128941c74f7f8e869aae17529))
* dorny/paths-filter needs token: '' to avoid API permission failure ([#115](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/115)) ([5e2df4d](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5e2df4db14a8ce52e8acce093199a3146d79fce9))
* stale verify.yml pins + skip molecule on non-role Renovate PRs ([#112](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/112)) ([5970be6](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5970be6b2abf21605b8c91b6ecb4b0154a59e507))


### Miscellaneous

* **deps:** update dependency @anthropic-ai/claude-code to v2.1.234 ([#92](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/92)) ([7a40037](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/7a40037931aa0d240a466f7f951b5c163a1bc3c2))
* **deps:** update dependency @anthropic-ai/claude-code to v2.1.237 ([#99](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/99)) ([8056ed8](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/8056ed8f50c965528fe6735d64e3f88671027679))
* **deps:** update dependency ansible-core to v2.21.3 ([#80](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/80)) ([93e485a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/93e485a15e0fd83b22441a176084426b3887490d))
* **deps:** update dependency ansible-lint to v26.8.0 ([#89](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/89)) ([220e2fb](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/220e2fb13a43ae650b89022a8f5c5c6f2ba96a03))
* **deps:** update dependency aquasecurity/trivy to v0.74.0 ([#100](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/100)) ([715ad12](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/715ad12603c9b315ee02c4ff9013eb51e07e0929))
* **deps:** update dependency astral-sh/uv to v0.12.5 ([#95](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/95)) ([23f3278](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/23f3278ca3431df1ab6908644b9596bc94dcf67c))
* **deps:** update dependency aws/aws-cli to v2.36.25 ([#74](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/74)) ([74a91d7](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/74a91d7f70ad933e7d637d57cca9b8ffd8caef6a))
* **deps:** update dependency aws/aws-cli to v2.36.27 ([#102](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/102)) ([1407f28](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/1407f28d32e42b0af1eca820b2ffffa0aa0d8483))
* **deps:** update dependency checkov to v3.3.11 ([#86](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/86)) ([35771cd](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/35771cddfaba968c8790f9feb0c28e866826c921))
* **deps:** update dependency checkov to v3.3.13 ([#103](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/103)) ([25c4dd1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/25c4dd1554bc2c26b78d68d978a13f01be3c69cc))
* **deps:** update dependency community.docker to v5.2.2 ([#75](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/75)) ([bff7b84](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/bff7b84af18c201c3a2e76ad86e8962e4df2c0aa))
* **deps:** update dependency community.general to v13.3.0 ([#81](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/81)) ([37b0f14](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/37b0f14f37986d84d03432bc880eadb7efd9987a))
* **deps:** update dependency helm/helm to v4.2.4 ([#96](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/96)) ([b7dd6b1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/b7dd6b1cbb91ef743385749823093eda45a03692))
* **deps:** update dependency ismaelmartinez/teams-for-linux to v2.16.0 ([#101](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/101)) ([5a8cc9c](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5a8cc9cf93ad20026ca768ce4c47d829347772be))
* **deps:** update dependency ismaelmartinez/teams-for-linux to v2.17.0 ([#119](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/119)) ([1e1cff4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/1e1cff47d4e31bbe54c3c8b0d2ebeb2844ebdd7d))
* **deps:** update dependency jesseduffield/lazygit to v0.64.1 ([#97](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/97)) ([fd2e35b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/fd2e35bbe43e902388f08496bf53c818703692fb))
* **deps:** update dependency junegunn/fzf to v0.74.3 ([#98](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/98)) ([c8537b1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/c8537b1036c06d5dadbc33d35afe340759de8661))
* **deps:** update dependency kubernetes/kubernetes to v1.36.4 ([#113](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/113)) ([313f9d0](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/313f9d096661c6b3fb986596e6a8cb41477a168c))
* **deps:** update dependency moby/moby to v29.7.2 ([#76](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/76)) ([3590908](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/3590908afff88128698e01d26e21782747e06e71))
* **deps:** update dependency molecule to v26.8.0 ([#90](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/90)) ([084bcb2](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/084bcb24482aaf650c4fb355c03ad0885af78ad0))
* **deps:** update dependency pipx to v1.16.7 ([#59](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/59)) ([1a84f96](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/1a84f96be1c9a2539d0b80cb3129e5e5825c013d))
* **deps:** update dependency terraform to v1.15.9-1 ([#104](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/104)) ([1bc46b1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/1bc46b1f863f2c784fa8f24794f192337c81d678))
* **deps:** update dorny/paths-filter action to v4 ([#114](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/114)) ([4759633](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/47596339c85bac57bfc11e28766961d63f03d9fa))


### CI/CD

* enable Renovate automerge for non-major updates ([#116](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/116)) ([c5b2fcf](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/c5b2fcf17a63c83858152510b9ae5233205ec655))
* wire up molecule testing ([#108](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/108)) ([feea88a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/feea88aef24129d7f1c675c858954909721722bb))


### Documentation

* standardize role READMEs and drop private-repo migration history ([#105](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/105)) ([367b9a1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/367b9a15d24650eb1f25faa5ff05d705d7117e89))

## [0.1.14](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.13...0.1.14) (2026-08-12)


### Features

* add clipboard_tools role (wl-clipboard, cliphist, clipse) ([#85](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/85)) ([ca721ef](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/ca721efbc0cc406bb9081331d141049c0a4937c9))
* add desktop_apps role (onlyoffice + firefox) ([#87](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/87)) ([603ea55](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/603ea556528ae8ca45dc49312772f40b84ac6a36))
* extend cli_dev_env with Claude Code CLI (npm, NodeSource Node.js) ([#88](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/88)) ([0a9f230](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/0a9f230e8ec3d78803bb45a7a16176e6e217e3d1))

## [0.1.13](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.12...0.1.13) (2026-08-10)


### Bug Fixes

* skip modern_cli's pinned nodejs/npm install if npm already works ([#78](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/78)) ([befe235](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/befe2350646bf652021db3602332b1dcdafca40b))

## [0.1.12](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.11...0.1.12) (2026-08-10)


### Features

* add cli_dev_env role (merge lazygit + neovim, absorb presenterm plugin config) ([#68](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/68)) ([9a54b6b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/9a54b6bf9a9f698d47d65e18cb11b2d29ba62a28))
* add emoji-picker (smile Flatpak) to desktop_customization role ([#67](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/67)) ([a95e938](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/a95e9380cf36936d76687ff71fa8d3bb30d4bd7e)), closes [#62](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/62)
* add iac_tools role (ansible, docker, aws, terraform, kubernetes_tools) ([#72](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/72)) ([9981436](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/9981436663c91a2ac55743d4ccd72fdb2a6b9eb7))
* add terminal_env role (merge zsh + tmux + kitty) ([#71](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/71)) ([2b016b1](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/2b016b170b21ccbf6a3b849bb23dd0571e0a7719))
* extend modern_cli with fzf, presenterm, and emoji-fzf ([#70](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/70)) ([54364f0](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/54364f0948ab4508bea59c12374f55d4a4b53a1e))


### Miscellaneous

* **deps:** update dependency astral-sh/uv to v0.12.3 ([#69](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/69)) ([831c82a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/831c82a4f47dd452a2bb4f83cd4ca3ce6dfea0df))

## [0.1.11](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.10...0.1.11) (2026-08-04)


### Features

* fold htop into modern_cli role ([#55](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/55)) ([da16cc8](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/da16cc8f85f015ad84ae15770863c37d9d75f1a6))

## [0.1.10](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.9...0.1.10) (2026-08-04)


### Features

* add code_quality_tools role (trivy, pre-commit tool installs) ([#56](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/56)) ([889b1f0](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/889b1f0a951faaa9f793fc81ab0926990cf7ed07))

## [0.1.9](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.8...0.1.9) (2026-08-04)


### Features

* add desktop_customization role (merge gui-customization + flameshot) ([#51](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/51)) ([4a49ba4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/4a49ba49c22880949cb80c1d6a75d72e3563627d))

## [0.1.8](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.7...0.1.8) (2026-08-03)


### Bug Fixes

* skip teams-for-linux checksum chain cleanly under --check ([#48](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/48)) ([bfc727b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/bfc727b79c1334d9a6183522c5de13ba27b61c8d))

## [0.1.7](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.6...0.1.7) (2026-08-03)


### Features

* add chat_clients role, merge slack + teams ([#38](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/38)) ([336fcc3](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/336fcc31ae1b284185f55782b6a048c93a5725ea))


### Bug Fixes

* use dynamic checksum verification for uv and nerd-fonts downloads ([#40](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/40)) ([224264e](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/224264e4974efd229ebd88a1041e2d10852a14ee))


### Miscellaneous

* **deps:** update dependency astral-sh/uv to v0.12.1 ([#41](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/41)) ([03d6622](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/03d6622266d995c3059ec525e983225146a53ed6))
* **deps:** update dependency checkov to v3.3.9 ([#43](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/43)) ([b3ad50b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/b3ad50b638bbc32a23b8436fca287f06c635c5e8))
* **deps:** update dependency ismaelmartinez/teams-for-linux to v2.14.1 ([#46](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/46)) ([b2878c4](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/b2878c41f77299cf32da469bea4ad3a608d68372))
* **deps:** update dependency markdownlint-cli2 to v0.23.2 ([#42](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/42)) ([5f96a77](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/5f96a7745a82634c99277b0216c1c347c05176a6))
* **deps:** update dependency ryanoasis/nerd-fonts to v3.5.0 ([#44](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/44)) ([1db02c8](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/1db02c833f5b8bed38a9e85ded6c47ced8d4099d))

## [0.1.6](https://github.com/swisstopo/infra-ansible-collection-workstation/compare/0.1.5...0.1.6) (2026-07-22)


### Features

* add base role, absorb git/ssh/python/fonts ([b75c0c6](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/b75c0c6f02d653196fb32999b8b9f8d32ed9bcfa))
* add base role, absorb git/ssh/python/fonts ([#30](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/30)) ([ae921a7](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/ae921a70833d93a29e7fa74899368760a401b247))


### Bug Fixes

* add missing become: false on SSH/fonts stat and slurp tasks ([a5e7e15](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/a5e7e154473c404c5bcc642ae1792fc243a489ac))
* address Copilot review findings on base role ([78a596b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/78a596ba62573e10e8604512220cf606b1050149))
* default base_https_proxy to base_http_proxy, hold python/font apt pins ([10b5a0a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/10b5a0a55f2c3dde18b5305ea893fb3d432e6322))
* fourth round of Copilot findings on base role ([391bbab](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/391bbab4e6d53cb6896e628b42f41feec3a9e11a))
* remove unnecessary strict-ssl=false from npm proxy config ([3ec2ee8](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/3ec2ee842d1e4b5c209aaf1a5c130256bb1f8a83))
* robust proxy URL parsing, avoid clobbering existing ssh config ([43a3c76](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/43a3c7652b0b4c0d84c5271dd4720615779a26b4))
* third round of Copilot findings on base role ([e1ab0e2](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/e1ab0e2eff499bb7a42afe3d9cea5916fa32b755))


### Miscellaneous

* **deps:** update dependency ansible-core to v2.21.1 [security] ([#32](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/32)) ([8543f4a](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/8543f4a543384bba9ba9a16ca0e71a625a526545))
* **deps:** update dependency ansible-core to v2.21.2 ([#15](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/15)) ([3da55c3](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/3da55c31b9d3e30faff0b100898d12a8a44b7b83))
* **deps:** update dependency ansible-lint to v26.6.0 ([#17](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/17)) ([72a2c5d](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/72a2c5d78c48baa465dc581f723797adfa113843))
* **deps:** update dependency astral-sh/uv to v0.11.31 ([#35](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/35)) ([290208b](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/290208b715d564d281971517d84167e1b8a0e3d1))
* **deps:** update dependency checkov to v3.3.8 ([#12](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/12)) ([0192133](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/0192133db4f8ce400efb69b0783b0163fc1240e5))
* **deps:** update dependency community.general to v13.2.0 ([#31](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/31)) ([84527bd](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/84527bdb5aea2879e4af0d16eeeb7195b04fce7e))
* **deps:** update dependency markdownlint-cli2 to v0.23.1 ([#33](https://github.com/swisstopo/infra-ansible-collection-workstation/issues/33)) ([30838a8](https://github.com/swisstopo/infra-ansible-collection-workstation/commit/30838a86ad8411d49c756b73898001bba339f20a))

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
