# Changelog

## [3.0.0](https://github.com/PMuellerCH/ansible-collection-workstation/compare/2.0.0...3.0.0) (2026-11-23)


### ⚠ BREAKING CHANGES

* the chat_clients, clipboard_tools, desktop_customization, graphics and multimedia roles are removed and their variables renamed without aliases (chat_clients_* -> desktop_apps_*, desktop_customization_* and clipboard_tools_* -> desktop_integration_*, multimedia_* -> media_*). The clipboard_tools.zsh snippet is replaced by desktop_integration.zsh. See the migration section in the README.
* the cli_dev_env, modern_cli and gh roles are removed and their variables renamed without aliases (base_git_* -> git_*, cli_dev_env_* / modern_cli_* -> editor_*, ai_cli_*, git_*, cli_tools_*, cli_dev_env_claude_code_nodejs_major_version -> base_nodejs_major_version). Claude Code now requires Node.js from the base role. See the migration section in the README.
* the iac_tools role is removed and all its variables are renamed with the new role prefix (ansible_dev_*, cloud_cli_*, k8s_tools_*). run ansible_dev before cloud_cli and k8s_tools.

### Miscellaneous

* **deps:** update dependency @anthropic-ai/claude-code to v2.1.328 ([#133](https://github.com/PMuellerCH/ansible-collection-workstation/issues/133)) ([fa4d5a9](https://github.com/PMuellerCH/ansible-collection-workstation/commit/fa4d5a9b817187fb43f2580cda3d3a9f24bd4fbb))
* **deps:** update dependency @anthropic-ai/claude-code to v2.1.329 ([#146](https://github.com/PMuellerCH/ansible-collection-workstation/issues/146)) ([b26fba1](https://github.com/PMuellerCH/ansible-collection-workstation/commit/b26fba19156938e36961066cfcedb1405d08243a))
* **deps:** update dependency @anthropic-ai/claude-code to v2.1.330 ([#151](https://github.com/PMuellerCH/ansible-collection-workstation/issues/151)) ([b7c033e](https://github.com/PMuellerCH/ansible-collection-workstation/commit/b7c033e9618466635990313b7cc876f737e37c7b))
* **deps:** update dependency 01mf02/jaq to v3.2.0 ([#153](https://github.com/PMuellerCH/ansible-collection-workstation/issues/153)) ([3b0e297](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3b0e29759df88935f446014775839388ccfddecd))
* **deps:** update dependency amazon.aws to v12.1.0 ([#154](https://github.com/PMuellerCH/ansible-collection-workstation/issues/154)) ([46c84af](https://github.com/PMuellerCH/ansible-collection-workstation/commit/46c84afe82eda2acbc51f7642d228d8e9699ae96))
* **deps:** update dependency aquasecurity/trivy to v0.76.2 ([#131](https://github.com/PMuellerCH/ansible-collection-workstation/issues/131)) ([1360e7b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/1360e7b3813d0c3ec073c2ab30a1b5995a87c5c4))
* **deps:** update dependency astral-sh/uv to v0.13.9 ([#132](https://github.com/PMuellerCH/ansible-collection-workstation/issues/132)) ([a6587fa](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a6587faa900e661d9d69f66c3f49fa162759cef5))
* **deps:** update dependency aws/aws-cli to v2.42.1 ([#157](https://github.com/PMuellerCH/ansible-collection-workstation/issues/157)) ([fc2a6c0](https://github.com/PMuellerCH/ansible-collection-workstation/commit/fc2a6c064581a552caf7c29f10c4f9aba3905caf))
* **deps:** update dependency boto3 to v1.44.9 ([#168](https://github.com/PMuellerCH/ansible-collection-workstation/issues/168)) ([60e2c70](https://github.com/PMuellerCH/ansible-collection-workstation/commit/60e2c70a6719c359c6c6868be37ee5a2874241c5))
* **deps:** update dependency checkov to v3.4.6 ([#135](https://github.com/PMuellerCH/ansible-collection-workstation/issues/135)) ([b9612f1](https://github.com/PMuellerCH/ansible-collection-workstation/commit/b9612f18aba4439e7a3e126c50c6ad917e127f3b))
* **deps:** update dependency checkov to v3.4.7 ([#177](https://github.com/PMuellerCH/ansible-collection-workstation/issues/177)) ([1a76e29](https://github.com/PMuellerCH/ansible-collection-workstation/commit/1a76e29006a4c9780abdda240e1e87b681d37ded))
* **deps:** update dependency community.crypto to v3.6.0 ([#161](https://github.com/PMuellerCH/ansible-collection-workstation/issues/161)) ([2db0091](https://github.com/PMuellerCH/ansible-collection-workstation/commit/2db00915ce93d4142c48d4d71cf818258d530b05))
* **deps:** update dependency community.general to v14.0.1 ([#138](https://github.com/PMuellerCH/ansible-collection-workstation/issues/138)) ([a499f6a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a499f6a60eea00e46edd7bb65ecb034eac91b0a6))
* **deps:** update dependency community.postgresql to v5.1.2 ([#139](https://github.com/PMuellerCH/ansible-collection-workstation/issues/139)) ([d9181f8](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d9181f8df84c93d9c8638a7b75e710070bd0c16f))
* **deps:** update dependency community.zabbix to v4.3.0 ([#159](https://github.com/PMuellerCH/ansible-collection-workstation/issues/159)) ([41f692b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/41f692b9d5be46d51625334fb650166e8c359550))
* **deps:** update dependency derailed/k9s to v0.51.0 ([#169](https://github.com/PMuellerCH/ansible-collection-workstation/issues/169)) ([5be33d6](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5be33d60a437d508d23967c3f1486ff70d2d0c21))
* **deps:** update dependency helm/helm to v4.3.2 ([#140](https://github.com/PMuellerCH/ansible-collection-workstation/issues/140)) ([f8d927d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/f8d927d06be2d5b48bde15cab262c672836eac6b))
* **deps:** update dependency ismaelmartinez/teams-for-linux to v2.32.1 ([#160](https://github.com/PMuellerCH/ansible-collection-workstation/issues/160)) ([6d95325](https://github.com/PMuellerCH/ansible-collection-workstation/commit/6d95325934f67bd3e96871b5abc23c27c126a6ca))
* **deps:** update dependency jesseduffield/lazygit to v0.66.3 ([#144](https://github.com/PMuellerCH/ansible-collection-workstation/issues/144)) ([f3efb16](https://github.com/PMuellerCH/ansible-collection-workstation/commit/f3efb1667bb27eb6cb1d3bc128bf6910a7d1e2d6))
* **deps:** update dependency jsonpatch to v1.48 ([#162](https://github.com/PMuellerCH/ansible-collection-workstation/issues/162)) ([d3a581b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d3a581b86c7bcf2381c24133bbb02e92f70910ff))
* **deps:** update dependency junegunn/fzf to v0.75.0 ([#163](https://github.com/PMuellerCH/ansible-collection-workstation/issues/163)) ([d76bcb0](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d76bcb0cd7a2470e2f90fbaf73a787c8d20e5693))
* **deps:** update dependency kubernetes to v37.0.3 ([#145](https://github.com/PMuellerCH/ansible-collection-workstation/issues/145)) ([3f741e7](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3f741e7b66579f1225b90aa3a8b534458d63d0c7))
* **deps:** update dependency markdownlint-cli2 to v0.24.2 ([#147](https://github.com/PMuellerCH/ansible-collection-workstation/issues/147)) ([149bc0c](https://github.com/PMuellerCH/ansible-collection-workstation/commit/149bc0cb08939719bf6d6310354cd73bef35db33))
* **deps:** update dependency nektos/act to v0.2.98 ([#148](https://github.com/PMuellerCH/ansible-collection-workstation/issues/148)) ([ef761d4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/ef761d4a4ed6ca66da895d345e515c1e217e95ab))
* **deps:** update dependency pipx to v1.18.19 ([#149](https://github.com/PMuellerCH/ansible-collection-workstation/issues/149)) ([9db62e0](https://github.com/PMuellerCH/ansible-collection-workstation/commit/9db62e0704e582fc3a2cbc8a4ef1e442134c7a11))
* **deps:** update dependency terraform-docs/terraform-docs to v0.25.1 ([#165](https://github.com/PMuellerCH/ansible-collection-workstation/issues/165)) ([214033a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/214033a1361dc958989a434b5c512c60afdcc07c))
* **deps:** update dependency walles/moar to v2.19.7 ([#150](https://github.com/PMuellerCH/ansible-collection-workstation/issues/150)) ([eb076ca](https://github.com/PMuellerCH/ansible-collection-workstation/commit/eb076ca29b1df65866ceab84030bc21553794b79))
* **deps:** update pre-commit hook davidanson/markdownlint-cli2 to v0.24.2 ([#152](https://github.com/PMuellerCH/ansible-collection-workstation/issues/152)) ([359850e](https://github.com/PMuellerCH/ansible-collection-workstation/commit/359850e587d406bdcbc24558c8fc0c487c2d8bc2))


### CI/CD

* run molecule on all PRs and lint only changed files ([#137](https://github.com/PMuellerCH/ansible-collection-workstation/issues/137)) ([2566b3e](https://github.com/PMuellerCH/ansible-collection-workstation/commit/2566b3ecc39856a8419b6eef694759143c0cfdf9))


### Refactoring

* merge the desktop and media roles into desktop_apps, desktop_integration, media ([#176](https://github.com/PMuellerCH/ansible-collection-workstation/issues/176)) ([85cec08](https://github.com/PMuellerCH/ansible-collection-workstation/commit/85cec08693650be392f081c7c131332f14307d1e))
* split cli_dev_env, modern_cli and gh into git, editor, ai_cli, cli_tools ([#167](https://github.com/PMuellerCH/ansible-collection-workstation/issues/167)) ([0f10722](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0f107225c7acbef3f12c55a998da05ad26bbf510))
* split iac_tools into ansible_dev, cloud_cli and k8s_tools ([#143](https://github.com/PMuellerCH/ansible-collection-workstation/issues/143)) ([93d5ebe](https://github.com/PMuellerCH/ansible-collection-workstation/commit/93d5ebe148eb43f0de8f67811b3d9c386db9cbee))

## [2.0.0](https://github.com/PMuellerCH/ansible-collection-workstation/compare/1.0.1...2.0.0) (2026-11-18)


### ⚠ BREAKING CHANGES

* merge infra-ansible-collection-workstation into pmuellerch.workstation ([#127](https://github.com/PMuellerCH/ansible-collection-workstation/issues/127))

### Features

* merge infra-ansible-collection-workstation into pmuellerch.workstation ([#127](https://github.com/PMuellerCH/ansible-collection-workstation/issues/127)) ([60f8c4d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/60f8c4da07d8148c6d4e3949f90edb9ef5e7cd3f))


### Miscellaneous

* **deps:** update dependency @anthropic-ai/claude-code to v2.1.327 ([#128](https://github.com/PMuellerCH/ansible-collection-workstation/issues/128)) ([42712bf](https://github.com/PMuellerCH/ansible-collection-workstation/commit/42712bfb511025faf55a2b2a74f4d70ea7b5dfb0))
* **deps:** update dependency anomalyco/opencode to v1.19.6 ([#129](https://github.com/PMuellerCH/ansible-collection-workstation/issues/129)) ([cc53838](https://github.com/PMuellerCH/ansible-collection-workstation/commit/cc5383872ee889d16cbddab1530218b3b0386804))
* **deps:** update dependency ansible-core to v2.21.5 ([#98](https://github.com/PMuellerCH/ansible-collection-workstation/issues/98)) ([5fb3b2d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5fb3b2d9473fa99af0a3936480dace0a24a931d5))
* **deps:** update dependency ansible-core to v2.22.0 ([#120](https://github.com/PMuellerCH/ansible-collection-workstation/issues/120)) ([bcb0c39](https://github.com/PMuellerCH/ansible-collection-workstation/commit/bcb0c39bd26a7c54bb826395e58c2fedfbef1b07))
* **deps:** update dependency ansible-lint to v26.10.0 ([#105](https://github.com/PMuellerCH/ansible-collection-workstation/issues/105)) ([63ec4f5](https://github.com/PMuellerCH/ansible-collection-workstation/commit/63ec4f53f56c8592c7b554c05dd51a605f385feb))
* **deps:** update dependency ansible-lint to v26.10.1 ([#108](https://github.com/PMuellerCH/ansible-collection-workstation/issues/108)) ([84b4083](https://github.com/PMuellerCH/ansible-collection-workstation/commit/84b4083c10fcdc50cbf92212b74372202f704abf))
* **deps:** update dependency ansible-lint to v26.11.0 ([#121](https://github.com/PMuellerCH/ansible-collection-workstation/issues/121)) ([f99623e](https://github.com/PMuellerCH/ansible-collection-workstation/commit/f99623e9385f0e5ca7efb543eadd12ccbcd287d7))
* **deps:** update dependency bitwarden/clients to v2026.10.0 ([#110](https://github.com/PMuellerCH/ansible-collection-workstation/issues/110)) ([d08a6a2](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d08a6a27078327c66e20a1f48318cfd9b9d7281e))
* **deps:** update dependency bitwarden/clients to v2026.10.1 ([#112](https://github.com/PMuellerCH/ansible-collection-workstation/issues/112)) ([9f03d0d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/9f03d0d1c4e819905e9c5b46585920e93a0a4251))
* **deps:** update dependency bitwarden/clients to v2026.10.2 ([#115](https://github.com/PMuellerCH/ansible-collection-workstation/issues/115)) ([916c6b8](https://github.com/PMuellerCH/ansible-collection-workstation/commit/916c6b8828b933364f12f79a5e3dbfb0418f91ec))
* **deps:** update dependency bitwarden/clients to v2026.10.3 ([#119](https://github.com/PMuellerCH/ansible-collection-workstation/issues/119)) ([6bdd470](https://github.com/PMuellerCH/ansible-collection-workstation/commit/6bdd470da342cbba322b3e80671190f6fa0cc269))
* **deps:** update dependency bitwarden/clients to v2026.10.4 ([#123](https://github.com/PMuellerCH/ansible-collection-workstation/issues/123)) ([4e5d108](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4e5d108ea1155f169af9f52d990055bcd1bd39e3))
* **deps:** update dependency checkov to v3.3.24 ([#99](https://github.com/PMuellerCH/ansible-collection-workstation/issues/99)) ([e3558ca](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e3558ca3b6438b6a605d43b7cb21d39af9610a87))
* **deps:** update dependency checkov to v3.3.25 ([#101](https://github.com/PMuellerCH/ansible-collection-workstation/issues/101)) ([80640e9](https://github.com/PMuellerCH/ansible-collection-workstation/commit/80640e9713818d9b0fdaf1fe4fe548d502829ac4))
* **deps:** update dependency checkov to v3.3.26 ([#102](https://github.com/PMuellerCH/ansible-collection-workstation/issues/102)) ([e4317df](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e4317df8c5ca74d020d4fbe780e6a30c6b90e04f))
* **deps:** update dependency checkov to v3.3.27 ([#103](https://github.com/PMuellerCH/ansible-collection-workstation/issues/103)) ([a5b8795](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a5b8795d2e66ee392db1080f2af7197d8756b165))
* **deps:** update dependency checkov to v3.3.28 ([#104](https://github.com/PMuellerCH/ansible-collection-workstation/issues/104)) ([3857b4d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3857b4da76a3dbac15e1539b2dcba209b8f4d81e))
* **deps:** update dependency checkov to v3.3.29 ([#109](https://github.com/PMuellerCH/ansible-collection-workstation/issues/109)) ([0f1c746](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0f1c746c6f0b84507c2d3ed8af83a429676165d6))
* **deps:** update dependency checkov to v3.3.30 ([#111](https://github.com/PMuellerCH/ansible-collection-workstation/issues/111)) ([79f19a7](https://github.com/PMuellerCH/ansible-collection-workstation/commit/79f19a72f9f9cb677bd922412a11733878160b81))
* **deps:** update dependency checkov to v3.4.0 ([#114](https://github.com/PMuellerCH/ansible-collection-workstation/issues/114)) ([0142a90](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0142a905350ed9bacf072467bdcaab1fbe94c0ff))
* **deps:** update dependency checkov to v3.4.3 ([#118](https://github.com/PMuellerCH/ansible-collection-workstation/issues/118)) ([e442f27](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e442f2741d718599060b91baea22e4b723922a61))
* **deps:** update dependency checkov to v3.4.5 ([#125](https://github.com/PMuellerCH/ansible-collection-workstation/issues/125)) ([a7a2c00](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a7a2c002002b323358b596ac1de44bb366216a4b))
* **deps:** update dependency hrkfdn/ncspot to v1.5.1 ([#124](https://github.com/PMuellerCH/ansible-collection-workstation/issues/124)) ([97a5329](https://github.com/PMuellerCH/ansible-collection-workstation/commit/97a532972271bad235ffa3e8b6f508b8b77be997))
* **deps:** update dependency molecule to v26.10.0 ([#106](https://github.com/PMuellerCH/ansible-collection-workstation/issues/106)) ([ff7a8da](https://github.com/PMuellerCH/ansible-collection-workstation/commit/ff7a8daff8cd1565bf992c1325244f6c905a5ed5))
* **deps:** update dependency molecule to v26.11.0 ([#122](https://github.com/PMuellerCH/ansible-collection-workstation/issues/122)) ([9f82df8](https://github.com/PMuellerCH/ansible-collection-workstation/commit/9f82df829cc2c676d567c4435134740c0623aa78))
* **deps:** update dependency molecule-plugins to v26.10.12 ([#107](https://github.com/PMuellerCH/ansible-collection-workstation/issues/107)) ([4a553b4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4a553b47c9886c16042876bbb0281c16b7bc20bb))
* **deps:** update dependency molecule-plugins to v26.11.0 ([#117](https://github.com/PMuellerCH/ansible-collection-workstation/issues/117)) ([c0b2248](https://github.com/PMuellerCH/ansible-collection-workstation/commit/c0b224804643190a25b48aded7a0250d3589dc8d))
* **deps:** update pre-commit hook compilerla/conventional-pre-commit to v4.5.0 ([#116](https://github.com/PMuellerCH/ansible-collection-workstation/issues/116)) ([8ff5a8f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8ff5a8fbe23ad4b573b46ea17179555f4d9f0e4f))
* **deps:** update pre-commit hook igorshubovych/markdownlint-cli to v0.50.0 ([#113](https://github.com/PMuellerCH/ansible-collection-workstation/issues/113)) ([e08991a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e08991a6dcca3e21d1786b300dff0f3f1d2373d9))

## [1.0.1](https://github.com/PMuellerCH/ansible-collection-workstation/compare/1.0.0...1.0.1) (2026-10-05)


### Bug Fixes

* skip roles without a molecule scenario in the molecule workflow ([#97](https://github.com/PMuellerCH/ansible-collection-workstation/issues/97)) ([d9aab82](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d9aab821d0b19b20e6898b61f8d499e82d8d19b0)), closes [#96](https://github.com/PMuellerCH/ansible-collection-workstation/issues/96)


### Miscellaneous

* **deps:** update dependency ansible-core to v2.21.4 ([#83](https://github.com/PMuellerCH/ansible-collection-workstation/issues/83)) ([68ec20a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/68ec20a59f18e3b78b9d0f7750f527762c8844f9))
* **deps:** update dependency ansible-lint to v26.9.0 ([#88](https://github.com/PMuellerCH/ansible-collection-workstation/issues/88)) ([a8e1fd8](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a8e1fd87cc826d5973a2fee38051562f4fa65e9f))
* **deps:** update dependency beets to v2.14.0 ([#82](https://github.com/PMuellerCH/ansible-collection-workstation/issues/82)) ([4a3ec12](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4a3ec12dfe296760e95a921e681b16e97a408db5))
* **deps:** update dependency beets to v2.14.1 ([#87](https://github.com/PMuellerCH/ansible-collection-workstation/issues/87)) ([a969a5d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a969a5d2333eac80d16d337e3aa4d24f5760647c))
* **deps:** update dependency bitwarden/clients to v2026.9.0 ([#86](https://github.com/PMuellerCH/ansible-collection-workstation/issues/86)) ([4ee281b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4ee281bf853556c3d11e3b79b630b453903533a7))
* **deps:** update dependency bitwarden/clients to v2026.9.1 ([#94](https://github.com/PMuellerCH/ansible-collection-workstation/issues/94)) ([3645be9](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3645be99170a186cc161de29683df898c49a7b0e))
* **deps:** update dependency checkov to v3.3.15 ([#78](https://github.com/PMuellerCH/ansible-collection-workstation/issues/78)) ([15e675f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/15e675f9b549c66f24d81fe0a46ec93555c9b580))
* **deps:** update dependency checkov to v3.3.16 ([#80](https://github.com/PMuellerCH/ansible-collection-workstation/issues/80)) ([28c5358](https://github.com/PMuellerCH/ansible-collection-workstation/commit/28c535841390e9f7df1f6c1268841c51d4e0ee45))
* **deps:** update dependency checkov to v3.3.17 ([#84](https://github.com/PMuellerCH/ansible-collection-workstation/issues/84)) ([2bd7bcf](https://github.com/PMuellerCH/ansible-collection-workstation/commit/2bd7bcf1a391e05f03fe63172895cc03c1444b13))
* **deps:** update dependency checkov to v3.3.19 ([#85](https://github.com/PMuellerCH/ansible-collection-workstation/issues/85)) ([327f50b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/327f50bdd2e1741b12418fa4e4245b8e3910e395))
* **deps:** update dependency checkov to v3.3.20 ([#90](https://github.com/PMuellerCH/ansible-collection-workstation/issues/90)) ([5e80d41](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5e80d4114f3cf768490d243f471599c70f0bfe5d))
* **deps:** update dependency checkov to v3.3.22 ([#92](https://github.com/PMuellerCH/ansible-collection-workstation/issues/92)) ([fa4ddb3](https://github.com/PMuellerCH/ansible-collection-workstation/commit/fa4ddb37baf21e2618823c53bbad89b7aae9494f))
* **deps:** update dependency checkov to v3.3.23 ([#95](https://github.com/PMuellerCH/ansible-collection-workstation/issues/95)) ([0decd54](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0decd54da10964a25c889c4e6aa2ab497f107e73))
* **deps:** update dependency community.docker to v5.4.0 ([#81](https://github.com/PMuellerCH/ansible-collection-workstation/issues/81)) ([36ca065](https://github.com/PMuellerCH/ansible-collection-workstation/commit/36ca065884da4702e10c6d952ddb8e3bf41b9a03))
* **deps:** update dependency hrkfdn/ncspot to v1.5.0 ([#93](https://github.com/PMuellerCH/ansible-collection-workstation/issues/93)) ([0715a62](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0715a62657f6dcab7d002cdaeee6ad7a1e258499))
* **deps:** update dependency molecule to v26.9.0 ([#89](https://github.com/PMuellerCH/ansible-collection-workstation/issues/89)) ([f06702a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/f06702a1f814740591651114257ef6d63d88e8dc))
* **deps:** update dependency molecule-plugins to v26.9.28 ([#91](https://github.com/PMuellerCH/ansible-collection-workstation/issues/91)) ([8dccfbe](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8dccfbeaafbc22865f3aeffa36cdaf709ff2c010))

## [1.0.0](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.9...1.0.0) (2026-08-21)


### Miscellaneous

* configure release-please for a v1.0.0 release ([#76](https://github.com/PMuellerCH/ansible-collection-workstation/issues/76)) ([0eca883](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0eca8835a063fdb41a838a9994e5af98d94144e1)), closes [#75](https://github.com/PMuellerCH/ansible-collection-workstation/issues/75)

## [0.1.9](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.8...0.1.9) (2026-08-21)


### Miscellaneous

* **deps:** update dependency bitwarden/clients to v2026.8.0 ([#72](https://github.com/PMuellerCH/ansible-collection-workstation/issues/72)) ([c00f585](https://github.com/PMuellerCH/ansible-collection-workstation/commit/c00f585d01794a70b4327207fa0c1a240c2e9f15))
* **deps:** update dependency hrkfdn/ncspot to v1.4.0 ([#74](https://github.com/PMuellerCH/ansible-collection-workstation/issues/74)) ([8e1c87b](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8e1c87b2d980eace716fc39f2fade51e920a9759))

## [0.1.8](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.7...0.1.8) (2026-08-20)


### Features

* run molecule only for roles that actually changed ([#69](https://github.com/PMuellerCH/ansible-collection-workstation/issues/69)) ([195d878](https://github.com/PMuellerCH/ansible-collection-workstation/commit/195d87862dee1653a1ccac67f8b3730154ec3217))


### Bug Fixes

* content-aware check for .github/requirements.txt changes ([#71](https://github.com/PMuellerCH/ansible-collection-workstation/issues/71)) ([bf216dd](https://github.com/PMuellerCH/ansible-collection-workstation/commit/bf216dd5f1411132e289aa97bf8f83e808b33039))
* correct invalid renovate datasource and enable pre-commit manager ([3124728](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3124728d2a550132193f596feff79c459fb4e1f5))
* correct invalid renovate datasource and enable pre-commit manager ([3124728](https://github.com/PMuellerCH/ansible-collection-workstation/commit/3124728d2a550132193f596feff79c459fb4e1f5))
* correct invalid renovate datasource and enable pre-commit manager ([16ba1a3](https://github.com/PMuellerCH/ansible-collection-workstation/commit/16ba1a35fed8b425bdb6c47753d17191d10ada41))
* dorny/paths-filter needs token: '' to avoid API permission failure ([#64](https://github.com/PMuellerCH/ansible-collection-workstation/issues/64)) ([ac7e62d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/ac7e62dc425d1bc5821001ccc5aa12baf8f68258))


### Miscellaneous

* **deps:** update dependency ansible-core to v2.21.1 [security] ([#49](https://github.com/PMuellerCH/ansible-collection-workstation/issues/49)) ([9792f29](https://github.com/PMuellerCH/ansible-collection-workstation/commit/9792f297b942e004db183fc71c9a594d949e0395))
* **deps:** update dependency ansible-core to v2.21.3 ([#59](https://github.com/PMuellerCH/ansible-collection-workstation/issues/59)) ([78f1dbb](https://github.com/PMuellerCH/ansible-collection-workstation/commit/78f1dbb19b2cc4541584ee31873dd1298d11ed30))
* **deps:** update dependency ansible-lint to v26.8.0 ([#50](https://github.com/PMuellerCH/ansible-collection-workstation/issues/50)) ([0d15a44](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0d15a441080ab48c52ee0e554c325427f707061b))
* **deps:** update dependency checkov to v3.3.12 ([#52](https://github.com/PMuellerCH/ansible-collection-workstation/issues/52)) ([e02583a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e02583ae88eede154d43a18792feca2c41bea4aa))
* **deps:** update dependency checkov to v3.3.13 ([#60](https://github.com/PMuellerCH/ansible-collection-workstation/issues/60)) ([8d1c162](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8d1c162eddc2af1265bc2836326477180737fa58))
* **deps:** update dorny/paths-filter action to v4 ([#63](https://github.com/PMuellerCH/ansible-collection-workstation/issues/63)) ([8382129](https://github.com/PMuellerCH/ansible-collection-workstation/commit/83821299e1ebb00d6bbd7c58feb9ecef8a3d7c3a))
* **deps:** update googleapis/release-please-action action to v5 ([#56](https://github.com/PMuellerCH/ansible-collection-workstation/issues/56)) ([defce70](https://github.com/PMuellerCH/ansible-collection-workstation/commit/defce7025b47390832071ea7966f2d95eca3095e))
* **deps:** update pre-commit hook adrienverge/yamllint to v1.38.0 ([#53](https://github.com/PMuellerCH/ansible-collection-workstation/issues/53)) ([d98e759](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d98e75936c738ca991a212056701edec52988cdc))
* **deps:** update pre-commit hook compilerla/conventional-pre-commit to v3.6.0 ([#54](https://github.com/PMuellerCH/ansible-collection-workstation/issues/54)) ([5082157](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5082157428203ffff9655eb3de5019a85880d9b4))
* **deps:** update pre-commit hook compilerla/conventional-pre-commit to v4 ([#57](https://github.com/PMuellerCH/ansible-collection-workstation/issues/57)) ([0e1493a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0e1493a10625b08f971e5d64a9ed4a94af5aaed0))
* **deps:** update pre-commit hook igorshubovych/markdownlint-cli to v0.49.1 ([#55](https://github.com/PMuellerCH/ansible-collection-workstation/issues/55)) ([76d7651](https://github.com/PMuellerCH/ansible-collection-workstation/commit/76d765101c6894f400ce39d9d6c35a436aee158e))
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v6 ([#58](https://github.com/PMuellerCH/ansible-collection-workstation/issues/58)) ([aa12785](https://github.com/PMuellerCH/ansible-collection-workstation/commit/aa12785542e0691a5ec0a5da7627e6a5e2614401))


### CI/CD

* enable Renovate automerge for non-major updates ([#65](https://github.com/PMuellerCH/ansible-collection-workstation/issues/65)) ([4f9e437](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4f9e437b66f59eee503bf1e312b3954802723709))
* migrate onto PMuellerCH/shared-actions reusable workflows ([7e5efa5](https://github.com/PMuellerCH/ansible-collection-workstation/commit/7e5efa573587b36f9713bb380d33133a9f04a900))
* migrate onto PMuellerCH/shared-actions reusable workflows ([7e5efa5](https://github.com/PMuellerCH/ansible-collection-workstation/commit/7e5efa573587b36f9713bb380d33133a9f04a900))
* migrate onto PMuellerCH/shared-actions reusable workflows ([5cae56e](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5cae56e54d46fa9b45eae98a76e3e31a47416a1e)), closes [#43](https://github.com/PMuellerCH/ansible-collection-workstation/issues/43)
* retrigger (propagation check) ([04412e6](https://github.com/PMuellerCH/ansible-collection-workstation/commit/04412e6c5682237735b1fcf8dacdb992c53597c1))
* retrigger after excluding .ansible/ from markdownlint ([5b6d9d4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/5b6d9d4dbfce683867b372bd269b9a3c51f7f11f))
* retrigger after fixing composite action version templating ([4dd6270](https://github.com/PMuellerCH/ansible-collection-workstation/commit/4dd627009f50909ae6e741f84abf422967df26bd))
* retrigger after fixing nested composite action bug ([81427e6](https://github.com/PMuellerCH/ansible-collection-workstation/commit/81427e6319e25ca63851b979feb8dcc96677881a))
* retrigger after granting shared-actions access ([8ed5089](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8ed5089e712369c1b7d51b886283c16ebdc8c913))
* retrigger after making shared-actions public ([0f5196f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0f5196f06d9d54c0ec186be945a83489da6655fb))
* skip molecule on non-role Renovate PRs ([#62](https://github.com/PMuellerCH/ansible-collection-workstation/issues/62)) ([04a6058](https://github.com/PMuellerCH/ansible-collection-workstation/commit/04a6058d44fab5743171e7d798d2a1f1bf2ebfcf)), closes [#61](https://github.com/PMuellerCH/ansible-collection-workstation/issues/61)

## [0.1.7](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.6...0.1.7) (2026-08-18)


### Documentation

* fix stale references and version pins ([27313c4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/27313c4c8e9656e9157443c45b53d49a3a963f06))
* fix stale references and version pins ([27313c4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/27313c4c8e9656e9157443c45b53d49a3a963f06))
* fix stale references and version pins ([a70b5d8](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a70b5d864f5a4967468f259c605cb1b38722b636)), closes [#40](https://github.com/PMuellerCH/ansible-collection-workstation/issues/40)

## [0.1.6](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.5...0.1.6) (2026-08-17)


### Features

* add graphics role ([be4f069](https://github.com/PMuellerCH/ansible-collection-workstation/commit/be4f0697b3c7f6b7cbab578dd7d9e5a9b61d311a))
* add graphics role ([1e80ff4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/1e80ff4d55195c03399d2fd11a0b1ef12f4019d2))

## [0.1.5](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.4...0.1.5) (2026-08-17)


### Features

* add multimedia role (beets + spotify + plex) ([df471d3](https://github.com/PMuellerCH/ansible-collection-workstation/commit/df471d3be8d2731a07347dce8683c2d7a435c016))
* add multimedia role (beets + spotify + plex) ([df471d3](https://github.com/PMuellerCH/ansible-collection-workstation/commit/df471d3be8d2731a07347dce8683c2d7a435c016))
* add multimedia role (beets + spotify + plex) ([c21aed4](https://github.com/PMuellerCH/ansible-collection-workstation/commit/c21aed4842992f71028a86193ff3fdf9a15c004d))


### Bug Fixes

* betterbird role doesn't bootstrap Flatpak/Flathub itself ([eb95f19](https://github.com/PMuellerCH/ansible-collection-workstation/commit/eb95f19db98566a6566214fa73b84ababc49e1db))
* betterbird role doesn't bootstrap Flatpak/Flathub itself ([eb95f19](https://github.com/PMuellerCH/ansible-collection-workstation/commit/eb95f19db98566a6566214fa73b84ababc49e1db))
* betterbird role doesn't bootstrap Flatpak/Flathub itself ([ce0afdb](https://github.com/PMuellerCH/ansible-collection-workstation/commit/ce0afdbf6132b70a2183fa2e26b9756cb96fb965))

## [0.1.4](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.3...0.1.4) (2026-08-13)


### Features

* add betterbird role ([9256a8c](https://github.com/PMuellerCH/ansible-collection-workstation/commit/9256a8cbf630fd7cde09cdf3205f4266fd59a0f4))
* add betterbird role ([d22a79c](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d22a79ce5130d711385242bd0ae024c1c8625984))


### Bug Fixes

* declare community.general as a collection dependency ([649e39f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/649e39f427b050236b7c25a765f11d47d096136d))
* declare community.general as a collection dependency ([649e39f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/649e39f427b050236b7c25a765f11d47d096136d))
* declare community.general as a collection dependency ([0f2acf1](https://github.com/PMuellerCH/ansible-collection-workstation/commit/0f2acf169b336ca6379181cce2d85d7bdb13629e))

## [0.1.3](https://github.com/PMuellerCH/ansible-collection-workstation/compare/0.1.2...0.1.3) (2026-08-13)


### Features

* add synology role ([f3851c2](https://github.com/PMuellerCH/ansible-collection-workstation/commit/f3851c2d1906e05f66eb27c4b228c97f780ed0c6))
* add synology role ([a200627](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a200627a1ba669c9575e2f0727200c5f48f59dac))


### Bug Fixes

* classify .j2 templates as Jinja for language detection ([41a91c9](https://github.com/PMuellerCH/ansible-collection-workstation/commit/41a91c982cfe979b7105b2b64ec29a4f6abe2b48))
* classify .j2 templates as Jinja for language detection ([738bd35](https://github.com/PMuellerCH/ansible-collection-workstation/commit/738bd35ca90e0da184a0faba6f3ae295155b5a62))

## [0.1.2](https://github.com/PMuellerCH/ansible-collection-workstation/compare/v0.1.1...0.1.2) (2026-08-13)


### Bug Fixes

* drop v-prefix from release tags ([8fe65e6](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8fe65e6f2f7f9e619487e39d822b16b50f71a064))
* drop v-prefix from release tags ([ae4697a](https://github.com/PMuellerCH/ansible-collection-workstation/commit/ae4697aae3c6d98d8b0e9385dfd4d87c057f66cd))


### CI/CD

* drop redundant push-to-main trigger from lint workflow ([8615763](https://github.com/PMuellerCH/ansible-collection-workstation/commit/8615763097a6c2b21c901b618bda6cc15479abda))
* drop redundant push-to-main trigger from lint workflow ([1218b32](https://github.com/PMuellerCH/ansible-collection-workstation/commit/1218b32c616d5a97024c68483e24fd72adc8b0f9))

## [0.1.1](https://github.com/PMuellerCH/ansible-collection-workstation/compare/v0.1.0...v0.1.1) (2026-08-12)


### Features

* add bitwarden role ([7aec762](https://github.com/PMuellerCH/ansible-collection-workstation/commit/7aec7625dd30b4f52c5994eaf011a76920f20226))
* add bitwarden role ([d4f4b8d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/d4f4b8d094a3bdb14bc58c9c48a7572409bf91af))
* add molecule testing gated before release ([43f9592](https://github.com/PMuellerCH/ansible-collection-workstation/commit/43f9592f79006c20e35759a01e56393c9799ccbf))
* add molecule testing gated before release ([e8ec285](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e8ec285d85f5bb85df85ddb1c07218c383a7f56b)), closes [#3](https://github.com/PMuellerCH/ansible-collection-workstation/issues/3)
* scaffold collection structure with CI, linting, and Release Please ([976d160](https://github.com/PMuellerCH/ansible-collection-workstation/commit/976d160cc953c9acb00bfdbdbcc60eb6b1875af0)), closes [#1](https://github.com/PMuellerCH/ansible-collection-workstation/issues/1)


### Bug Fixes

* add explicit least-privilege permissions to CI workflows ([cda970d](https://github.com/PMuellerCH/ansible-collection-workstation/commit/cda970d70a9fd1ac326b9830c115a932d791afec))
* add explicit least-privilege permissions to CI workflows ([cbababc](https://github.com/PMuellerCH/ansible-collection-workstation/commit/cbababc9b8385628c97b5750b8d79c59d6782d6b)), closes [#6](https://github.com/PMuellerCH/ansible-collection-workstation/issues/6)
* exclude CHANGELOG.md from markdownlint ([e2dbc40](https://github.com/PMuellerCH/ansible-collection-workstation/commit/e2dbc408abfc0bdd2bcc8b370bcfd782d5baf53b))
* exclude CHANGELOG.md from markdownlint ([7ee5c7c](https://github.com/PMuellerCH/ansible-collection-workstation/commit/7ee5c7cf135bff110520058fb349c65f1ee7e6db))
* regenerate package-lock.json against public npm registry ([58c1fde](https://github.com/PMuellerCH/ansible-collection-workstation/commit/58c1fdef9d017e3fb97feda510f2b80f13bbb21f))
* use generic extra-file updater for galaxy.yml version bump ([368089f](https://github.com/PMuellerCH/ansible-collection-workstation/commit/368089fa43ec96f68fba1f35fd1c367b9de12477))
* use generic extra-file updater for galaxy.yml version bump ([a332d03](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a332d030ec0a2ccd4d18da23d78c62cc7c5f8efa))


### Documentation

* add per-role README template ([a02e3c6](https://github.com/PMuellerCH/ansible-collection-workstation/commit/a02e3c62f90bd8586be68d5ff70b2d8fd75d3986))
* add per-role README template ([7778504](https://github.com/PMuellerCH/ansible-collection-workstation/commit/77785046a4e75ddfbbb91f5add1f1ec7f2b39ef3)), closes [#9](https://github.com/PMuellerCH/ansible-collection-workstation/issues/9)

## Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Release Please manages this file automatically. Do not edit manually. -->
