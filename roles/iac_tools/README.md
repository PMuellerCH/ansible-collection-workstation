# swisstopo.workstation.iac_tools

Installs infra/cloud CLI tooling a cloud engineer reaches for together:
`ansible-core` (pipx) with Galaxy collections, Docker CE, AWS CLI v2 +
session-manager-plugin, Terraform + Vault + tfswitch/tflint/terraform-docs,
and a full Kubernetes toolchain (kubectl, k9s, helm, kubectx/kubens, stern,
krew, kubeconform, kube-linter). Merges what used to be five separate roles
in `computer-setup` (`ansible`, `docker`, `aws`, `terraform`,
`kubernetes_tools`) — the same category of tool for provisioning and
operating cloud infrastructure.

## Tagging (for backward-compatible selective runs)

Every task carries its own tag in addition to the umbrella `iac_tools` tag,
so a consuming playbook can still filter by the tool's original identity
even though it's one role:

| Sub-role | Tag |
| --- | --- |
| ansible-core, Galaxy collections | `ansible`, `iac_tools` |
| Docker CE | `docker`, `iac_tools` |
| AWS CLI, session-manager-plugin | `aws`, `iac_tools` |
| Terraform, Vault, tfswitch, tflint, terraform-docs | `terraform`, `iac_tools` |
| kubectl, k9s, helm, kubectx/kubens, stern, krew, kubeconform, kube-linter | `kubernetes_tools`, `iac_tools` |
| pipx bootstrap | runs if `ansible`, `aws`, or `kubernetes_tools` is enabled — carries all three tags plus `iac_tools` |

**Do not** put an outer `tags:` on the role invocation in your play — that
tag cascades to every task in the role and defeats this per-tool filtering.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `iac_tools_ansible_enabled` | `true` | Install ansible-core + Galaxy collections |
| `iac_tools_docker_enabled` | `true` | Install Docker CE |
| `iac_tools_aws_enabled` | `true` | Install AWS CLI v2 + session-manager-plugin |
| `iac_tools_terraform_enabled` | `true` | Install Terraform/Vault/tfswitch/tflint/terraform-docs |
| `iac_tools_kubernetes_tools_enabled` | `true` | Install the Kubernetes toolchain |
| `iac_tools_http_proxy` | `""` | Corporate HTTP proxy URL. Leave empty on machines without a proxy |
| `iac_tools_https_proxy` | `iac_tools_http_proxy` | Corporate HTTPS proxy URL |
| `iac_tools_no_proxy` | `""` | Comma-separated proxy bypass list |
| `iac_tools_vault_addr` | `""` | HashiCorp Vault server address. Leave empty to skip Vault shell integration |
| `iac_tools_pipx_min_version` | `1.7.1` | pipx version bootstrapped via `pip install --user`, see below |
| `iac_tools_ansible_core_version` | `2.21.2` | ansible-core version (pypi), via pipx |
| `iac_tools_ansible_molecule_version` | `26.6.0` | molecule version (pypi), injected into the ansible-core venv |
| `iac_tools_ansible_molecule_plugins_version` | `26.7.15` | molecule-plugins[docker] version (pypi), injected into the ansible-core venv |
| `iac_tools_hvac_version` | `2.4.0` | hvac version (pypi), injected into the ansible-core venv by both `ansible` and `kubernetes_tools` |
| `iac_tools_docker_version` | `29.7.1` | Docker CE version (github-releases: `moby/moby`) |
| `iac_tools_aws_cli_version` | `2.36.16` | AWS CLI v2 version (github-tags: `aws/aws-cli`) |
| `iac_tools_aws_boto3_version` | `1.43.27` | boto3 version (pypi), injected into the ansible-core venv |
| `iac_tools_aws_session_manager_plugin_version` | `1.2.814.0` | session-manager-plugin version (github-releases: `aws/session-manager-plugin`) |
| `iac_tools_aws_profiles` | `[]` | AWS SSO profiles rendered into `~/.aws/config` — see below |
| `iac_tools_terraform_version` | see `defaults/main.yml` | Terraform apt package version (deb: HashiCorp apt) |
| `iac_tools_vault_version` | see `defaults/main.yml` | Vault apt package version (deb: HashiCorp apt) |
| `iac_tools_tflint_version` | `0.64.0` | tflint binary version (github-releases) |
| `iac_tools_terraform_docs_version` | `0.24.0` | terraform-docs binary version (github-releases) |
| `iac_tools_tfswitch_version` | `1.19.0` | tfswitch binary version (github-releases: `warrensbox/terraform-switcher`), checksum-verified |
| `iac_tools_terraform_cloud_token` | `""` | Terraform Cloud API token from the consumer's own secret store |
| `iac_tools_terraform_vault_github_token` | `""` | GitHub PAT for `vault login --method=github`, from the consumer's own secret store |
| `iac_tools_kubectl_version` | `1.36.3` | kubectl version (github-releases: `kubernetes/kubernetes`), checksum-verified |
| `iac_tools_k9s_version` | `0.50.18` | k9s version (github-releases) |
| `iac_tools_helm_version` | `4.2.3` | helm version (github-releases) |
| `iac_tools_kubectx_version` | `0.11.0` | kubectx/kubens version (github-releases) |
| `iac_tools_stern_version` | `1.34.0` | stern version (github-releases) |
| `iac_tools_krew_version` | `0.5.0` | krew version (github-releases) |
| `iac_tools_kubeconform_version` | `0.8.0` | kubeconform version (github-releases) |
| `iac_tools_kube_linter_version` | `0.8.3` | kube-linter version (github-releases) |
| `iac_tools_kubernetes_pip_kubernetes_version` | `36.0.3` | Python `kubernetes` library version (pypi), non-Ubuntu targets only |
| `iac_tools_kubernetes_pip_jsonpatch_version` | `1.33` | Python `jsonpatch` library version (pypi), non-Ubuntu targets only |
| `iac_tools_kubernetes_pip_pyhcl_version` | `0.4.5` | Python `pyhcl` library version (pypi), non-Ubuntu targets only |
| `iac_tools_kubernetes_clusters` | `[]` | EKS clusters rendered into `~/.kube/config` — see below |
| `iac_tools_kubernetes_current_context` | `""` | kubeconfig `current-context`; defaults to the first cluster entry |

## Parameterized personal data

Two files in the original `computer-setup` roles hardcoded real
organization-specific data (SSO account IDs, EKS cluster CA certs, IAM role
ARNs). A shared collection can't ship those as static files — they're now
Jinja2 templates driven by list-of-dict variables, both defaulting to an
empty list. **When the list is empty, the corresponding file is not
deployed at all** (rather than writing an empty or broken config).

### `iac_tools_aws_profiles` → `~/.aws/config`

```yaml
iac_tools_aws_profiles:
  - name: default # renders a bare [default] block
    sso_start_url: "https://example.awsapps.com/start#/"
    sso_region: eu-central-1
    output: json
  - name: example-master # renders [profile example-master]
    sso_start_url: "https://example.awsapps.com/start#/"
    sso_role_name: AdministratorAccess
    sso_account_id: "111111111111"
    sso_region: eu-central-1
    region: eu-central-1
    output: json
```

`sso_role_name`, `sso_account_id`, and `region` are optional per entry (a
bare `[default]` block typically only needs `sso_start_url`/`sso_region`/
`output`).

### `iac_tools_kubernetes_clusters` → `~/.kube/config`

Each entry reconstructs one EKS cluster + its matching context + the `aws
eks get-token` exec-auth user entry:

```yaml
iac_tools_kubernetes_clusters:
  - context_name: example-dev
    cluster_name: dev
    region: eu-central-1
    account_id: "222222222222"
    certificate_authority_data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
    server: "https://XXXXXXXX.gr7.eu-central-1.eks.amazonaws.com"
    role_arn: "arn:aws:iam::222222222222:role/kubernetes-admins-dev"
    aws_profile: example-master
```

The cluster/user ARN (`arn:aws:eks:<region>:<account_id>:cluster/<cluster_name>`)
is derived from `region`/`account_id`/`cluster_name` rather than stored as a
separate field, so there's no risk of it drifting out of sync.

## Shared ansible-core pipx venv

`ansible`, `aws`, and `kubernetes_tools` (on non-Ubuntu targets) all inject
packages into the *same* `ansible-core` pipx venv. In `computer-setup` this
worked via implicit ordering across three separate roles in `site.yml`; as
one role, the injects are now sequenced explicitly within a single task
list: `ansible-core` install → `hvac`/`molecule`/`molecule-plugins` inject
(ansible) → Galaxy collections → ... → `boto3` inject (aws) → ... →
Kubernetes Python libraries inject (kubernetes_tools, non-Ubuntu only).
`hvac` is injected by both `ansible` and `kubernetes_tools`; a single shared
`iac_tools_hvac_version` variable keeps both injects requesting the same
version instead of fighting over the venv.

The `boto3` (aws) and Kubernetes Python library (kubernetes_tools,
non-Ubuntu only) injects also require `iac_tools_ansible_enabled: true` —
the `ansible-core` pipx app they inject into is only installed by the
`ansible` sub-role. If `iac_tools_ansible_enabled` is `false`, those
injects are skipped rather than failing (`pipx inject` requires the target
app to already exist); AWS CLI / kubectl / etc. themselves still install
normally either way, just without the Python library wired into that venv.

### pipx bootstrap

`community.general.pipx` hard-requires pipx **>= 1.7.0**. Ubuntu 24.04's
apt-provided `pipx` is only **1.4.3**. Per role independence, this role
can't assume a consumer has already upgraded pipx globally, so it
bootstraps an adequate pipx itself — same pattern as the
`code_quality_tools` role (see that role's README for the full mechanism:
`pip3 install --user pipx=={{ iac_tools_pipx_min_version }}
--break-system-packages`, which shadows the older apt-provided pipx on
`sys.path` without any `PATH` manipulation). The bootstrap only runs when
`ansible`, `aws`, or `kubernetes_tools` is enabled (the sub-roles that
actually touch the shared venv) — a consumer running only `docker`/
`terraform` doesn't pay for it.

Because the bootstrap's `pip3 install --user` step reports `changed` under
`ansible-playbook --check` without actually installing anything, every
pipx-based task downstream of it (the `ansible-core` install itself and
every inject) is gated with `when: not ansible_check_mode`.

## Notes

- **kubectl** is checksum-verified against its published `.sha256` from
  `dl.k8s.io` — unchanged from the original role.
- **AWS CLI v2 installer** and **session-manager-plugin** only publish a GPG
  `.sig` upstream, not a plain or structured checksum file — outside the
  two-tier `get_url` checksum pattern used elsewhere in this collection
  (plain `sha256sum`-format file, or a structured file `get_url` can't parse
  directly). GPG signature verification isn't yet an established pattern in
  this collection, so this is deliberately deferred rather than blocking —
  matching how earlier batches treated downloads with no straightforward
  checksum path.
- **Terraform and Vault** install from the official HashiCorp apt
  repository (`signed_by` a pinned GPG keyring). apt itself validates
  package integrity against that repo's signed `Release` metadata, so no
  separate per-package checksum is needed on top of that.
- `tfswitch` is downloaded from a pinned GitHub release and
  checksum-verified against upstream's own `..._checksums.txt` (tier-1,
  same as tflint/terraform-docs above) — not the upstream shell installer
  (`curl | bash` against a mutable branch URL), which would be both a
  supply-chain risk and non-reproducible.
- `terraformrc` (containing the Terraform Cloud token, when set) is
  deployed with `no_log: true`.
- `docker`, `terraform` (Vault GitHub token file), and `aws` all deploy
  their real config/credential files with `force: false` so user-made
  changes (e.g. `docker login` credentials, manually-tweaked AWS/kube
  profiles) survive re-runs.
- `python3-kubernetes`/`python3-jsonpatch`/`python3-hvac`/`python3-pyhcl`
  are installed via apt on Ubuntu; on non-Ubuntu targets (e.g. Pop!_OS,
  which `computer-setup` itself runs on) the equivalent pip packages are
  injected into the shared ansible-core pipx venv instead.

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
