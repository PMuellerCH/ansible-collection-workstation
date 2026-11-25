# pmuellerch.workstation.k8s_tools

Installs the Kubernetes toolchain: `kubectl`, `k9s`, `helm` (with the `helm-diff` plugin), `kubectx`/`kubens`, `stern`,
`krew`, `kubeconform`, `kube-linter` and the Python Kubernetes libraries, and renders `~/.kube/config` from your EKS
cluster list. Split out of the former `iac_tools` role.

## What it does

1. Installs `kubectl` (checksum-verified against `dl.k8s.io`), `k9s` (with the Catppuccin Mocha skin), `helm` and the
   `helm-diff` plugin, `kubectx`/`kubens`, `stern`, `krew`, `kubeconform` and `kube-linter` — all binaries from pinned,
   checksum-verified release downloads (`helm-diff` is the exception, see Notes).
2. Installs the Python Kubernetes libraries: via apt on Ubuntu (`python3-kubernetes`, `-jsonpatch`, `-hvac`, `-pyhcl`),
   or injected into the `ansible-core` pipx venv on other distributions.
3. Renders `~/.kube/config` from `k8s_tools_clusters` and deploys a zsh snippet (`~/.config/zsh/conf.d/k8s_tools.zsh`)
   with the krew `PATH` entry and helm/stern completions.

## Variables

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
| --- | --- | --- |
| `k8s_tools_kubectl_version` | see `defaults/main.yml` | kubectl (github-releases: `kubernetes/kubernetes`, Renovate-managed) |
| `k8s_tools_kubectl_url` | see `defaults/main.yml` | Download URL for the pinned kubectl binary |
| `k8s_tools_kubectl_checksum_url` | see `defaults/main.yml` | URL of kubectl's published `.sha256` file |
| `k8s_tools_k9s_version` | see `defaults/main.yml` | k9s (github-releases, Renovate-managed) |
| `k8s_tools_helm_version` | see `defaults/main.yml` | helm (github-releases, Renovate-managed) |
| `k8s_tools_helm_diff_version` | see `defaults/main.yml` | helm-diff plugin tag (github-releases: `databus23/helm-diff`, Renovate-managed) |
| `k8s_tools_kubectx_version` | see `defaults/main.yml` | kubectx/kubens (github-releases, Renovate-managed) |
| `k8s_tools_kubectx_archive` | see `defaults/main.yml` | Filename of the kubectx release archive |
| `k8s_tools_kubens_archive` | see `defaults/main.yml` | Filename of the kubens release archive |
| `k8s_tools_stern_version` | see `defaults/main.yml` | stern (github-releases, Renovate-managed) |
| `k8s_tools_krew_version` | see `defaults/main.yml` | krew (github-releases, Renovate-managed) |
| `k8s_tools_kubeconform_version` | see `defaults/main.yml` | kubeconform (github-releases, Renovate-managed) |
| `k8s_tools_kube_linter_version` | see `defaults/main.yml` | kube-linter (github-releases, Renovate-managed) |
| `k8s_tools_pip_kubernetes_version` | see `defaults/main.yml` | Python `kubernetes` (pypi), non-Ubuntu only (Renovate-managed) |
| `k8s_tools_pip_jsonpatch_version` | see `defaults/main.yml` | Python `jsonpatch` (pypi), non-Ubuntu only (Renovate-managed) |
| `k8s_tools_pip_pyhcl_version` | see `defaults/main.yml` | Python `pyhcl` (pypi), non-Ubuntu only (Renovate-managed) |
| `k8s_tools_clusters` | `[]` | EKS clusters rendered into `~/.kube/config` — see below |
| `k8s_tools_current_context` | `""` | kubeconfig `current-context`; defaults to the first cluster entry |

## Usage examples

```yaml
- hosts: localhost
  roles:
    - role: pmuellerch.workstation.k8s_tools
      vars:
        k8s_tools_clusters:
          - context_name: example-dev
            cluster_name: dev
            region: eu-central-1
            account_id: "222222222222"
            certificate_authority_data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
            server: "https://XXXXXXXX.gr7.eu-central-1.eks.amazonaws.com"
            role_arn: "arn:aws:iam::222222222222:role/kubernetes-admins-dev"
            aws_profile: example-master
```

Each entry reconstructs one EKS cluster, its matching context and the `aws eks get-token` exec-auth user. The ARN
(`arn:aws:eks:<region>:<account_id>:cluster/<cluster_name>`) is derived from `region`/`account_id`/`cluster_name`
rather than stored separately, so it can't drift. **When the list is empty, `~/.kube/config` is not deployed at all.**
The exec-auth entries call `aws`, so pair this role with `cloud_cli` for the AWS CLI.

| Component | Tags |
| --- | --- |
| kubectl | `kubectl`, `k8s_tools` |
| k9s and its skin/config | `k9s`, `k8s_tools` |
| helm, helm-diff | `helm`, `k8s_tools` |
| kubectx/kubens, stern, krew, kubeconform, kube-linter | `kube_utils`, `k8s_tools` |
| Python Kubernetes libraries | `python_libs`, `k8s_tools` |
| kubeconfig, shell snippet | `config`, `k8s_tools` |

**Do not** put an outer `tags:` on the role
invocation in your play — it cascades to every task and defeats the per-component filtering. There are no
per-component enable switches: the role as a whole is the unit.

## Notes

- **Checksums**: every download is verified against upstream release metadata fetched at run time (no static hashes to
  keep in sync). k9s, helm, kubectx/kubens, stern, krew, kubeconform and kubectl use the upstream checksum file.
  kube-linter publishes none (only sigstore bundles), so its sha256 is read from the GitHub releases API
  (`assets[].digest`) — this needs unauthenticated `api.github.com` access and is only called when an install or upgrade
  is actually needed (a rate-limited shared proxy IP would surface as a clear failure, never as skipped verification).
  The kube-linter metadata fetch is retried (3 retries, 15 s apart) first.
  All downloads are staged in a private temporary directory (mode 0700, removed afterwards, also on failure): helm
  (`helm.yml`) and krew (`kube_utils.yml`) in their own directories, every other archive in a per-run directory created in `tasks/main.yml`.
- **Python libraries on non-Ubuntu**: injected into the `ansible-core` pipx venv created by the `ansible_dev` role,
  and skipped (not failed) if that venv doesn't exist yet — run `ansible_dev` first and re-run this role. `hvac` is
  injected by `ansible_dev` only.
- **helm-diff** is installed from the upstream repository at the pinned tag `k8s_tools_helm_diff_version` (Renovate-tracked) with
  `--verify=false` (the plugin ships no provenance file); this is a known limitation: the
  tag is pinned (not commit-pinned) and there is no provenance verification. `git` (for the plugin clone) and `curl`
  (used by the plugin's install hook) are installed for it.
- `~/.kube/config` and the k9s config are deployed with `force: false` so manual edits survive re-runs.
- The zsh snippet was renamed from `kubernetes_tools.zsh` to `k8s_tools.zsh`; the role removes the old file.

## Testing

```bash
cd roles/k8s_tools && molecule test
```

## Platforms

| OS | Tested |
| --- | --- |
| Ubuntu 24.04 | yes |
