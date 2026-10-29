# Bicep standards and framework examples

A starting point for Azure infrastructure conventions, reusable modules, and deployment stacks. The examples cover tenant governance, shared platform services, and application infrastructure.

## Structure

```text
.azuredevops/                # Example pipelines, stages, and steps
.ps-rule/                   # Custom infrastructure rules
modules/
  res/                      # Resource modules, e.g. network-virtual-network
  ptn/                      # Patterns, e.g. compute-image and network-vnet
  utl/                      # Utilities, e.g. naming
scripts/                    # Local and pipeline build/deployment helpers
stacks/
  common.yaml               # Shared example settings
  platform/
    tenant/                 # Management group hierarchy and compliance
    hub/                    # Connectivity, private DNS, and firewalls
    identity/
    management/
    security/
  applications/
    core/
```

Each stack follows `stacks/<category>/<name>/<function>/main.bicep`, with environment-specific examples under `parameters/<function>.<environment>.<region>.bicepparam`. Stack metadata lives in `zone.yaml`; the zone terminology describes a logical grouping within a stack.

## Conventions

- Keep organization-wide example settings in `stacks/common.yaml` and stack tags in `zone.yaml`.
- Keep reusable resource logic in `modules/res`, compositions in `modules/ptn`, and non-deploying helpers in `modules/utl`.
- Use lowercase, hyphenated module names that combine domain and purpose, such as `ptn/compute-image`. Each module owns its `main.bicep`, tests, and child modules. See the [module catalog](modules/README.md) for the layout and naming rules.
- Reference repository modules with relative paths. Third-party Azure Verified Modules use pinned `br/public:avm/res/...:<version>` references; no private registry is required.
- Use `modules/utl/naming/main.bicep` for naming and tags. The sample tenant prefix is `ex`, environments are `production`, `nonprod`, and `tenant`, and the sample regions are Australian Azure regions.
- Supply secrets through secure parameters or a secret store. Keep generated ARM templates, local settings, and credentials out of Git.

## Customize the examples

The parameter and YAML files contain dummy IDs of the form `00000000-0000-0000-0000-000000000001`, example resource names, `example.com` domains, and example Azure DevOps connection names. Replace them with your own tenant/root management group, subscription and principal IDs, resource IDs, DNS names, image locations, and pipeline connections before deployment. Repeated dummy IDs represent the same example dependency across files. Azure built-in role, policy, and initiative IDs remain intact.

Review network ranges, regions, tags, policy initiatives, and module/service versions for your environment. These examples include existing-resource dependencies; build success does not verify that those resources exist or that you have permissions to deploy them.

## Incomplete examples

The imported source includes two unfinished patterns. `modules/ptn/devops-agent/main.bicep` is a resource-group/RBAC stub, and `modules/ptn/tenant-hierarchy/main.bicep` currently creates a test management group instead of processing the supplied hierarchy. Their stack wrappers and tests expect interfaces these stubs do not implement, so the agent and hierarchy examples do not compile. Complete these patterns before enabling the `ado-agents` or `hierarchy` pipeline functions. The other examples compile with the pinned public dependencies; existing linter warnings still need review before production use.

## Build and validate

Install Azure CLI with Bicep and PowerShell 7. Run commands from the repository root. Public module restoration requires internet access; building does not require an Azure sign-in.

```powershell
az bicep install
. ./scripts/Manage-Eslz.ps1
Build-Bicep -ZoneCategory platform -ZoneName hub -FunctionName bootstrap -OutputPath ./build/hub-bootstrap
```

Build a parameter file directly with:

```powershell
az bicep build-params --file ./stacks/platform/hub/bootstrap/parameters/bootstrap.nonprod.australiaeast.bicepparam --outfile ./build/bootstrap.parameters.json
```

PSRule configuration lives in `ps-rule.yaml`; the analysis pipeline is `.azuredevops/tests-bicep-psrule.yaml`. Deployment pipelines are `.azuredevops/deploy-*.yaml` and share reusable templates. Configure your Azure DevOps service connections and environments before using them. Build jobs use hosted Ubuntu agents by default and require no service connection.

## Preview a deployment

After replacing the example values, sign in to Azure and select your target subscription. The deployment helper defaults to what-if:

```powershell
. ./scripts/Manage-Eslz.ps1
Deploy-Zone -ZoneCategory platform -ZoneName hub -FunctionName bootstrap -Location australiaeast -Environment nonprod -DeploymentScope sub -Bicep
```

Review the preview before explicitly passing `-WhatIf $false`. For management-group deployments, also supply `-RootManagementGroupId`.
