# Local module catalog

The module classes follow [Azure Verified Modules classifications](https://azure.github.io/Azure-Verified-Modules/specs/shared/module-classifications/): `res` for resources, `ptn` for composed patterns, and `utl` for utilities that do not deploy resources.

This repository uses a flat local layout: `modules/<class>/<domain>-<purpose>/main.bicep`. Published AVM modules use separate category and module path segments; their pinned `br/public:avm/...` references retain those canonical paths. The local folders use AVM-style classes and lowercase, hyphenated names without claiming AVM certification.

## Naming and structure

- Use singular module names where practical, such as `compute-image` and `devops-agent`.
- Put the domain first: `network-`, `compute-`, `security-`, or `tenant-`. Utilities with a clear shared purpose can use a short name such as `naming`.
- Use scope suffixes when separate implementations need disambiguation: `-rg` for resource group and `-sub` for subscription.
- Keep `main.bicep` as the entry point, deployment examples in `parameters/`, and validation examples in `tests/`.
- Keep private child modules, scripts, and supporting files inside their owning module. Promote a child to a separate module when it becomes a shared dependency.
- Reference local modules using relative paths; pin external AVM references to explicit versions.

## Patterns (`ptn`)

| Module | Purpose |
| --- | --- |
| [bootstrap-registry](ptn/bootstrap-registry/main.bicep) | Optional private Bicep registry |
| [bootstrap-subscription](ptn/bootstrap-subscription/main.bicep) | Subscription baseline and shared resources |
| [compute-image](ptn/compute-image/main.bicep) | Compute gallery and container image registry |
| [compute-windows-365](ptn/compute-windows-365/main.bicep) | Windows 365 resource group and permissions |
| [container-aks](ptn/container-aks/main.bicep) | AKS baseline and supporting permissions |
| [devops-agent](ptn/devops-agent/main.bicep) | Agent pattern stub; implementation is incomplete |
| [network-fortinet](ptn/network-fortinet/main.bicep) | Fortinet appliance composition |
| [network-private-dns](ptn/network-private-dns/main.bicep) | Private DNS zones and resolution |
| [network-vnet](ptn/network-vnet/main.bicep) | Virtual network baseline and related networking |
| [security-pki](ptn/security-pki/main.bicep) | PKI supporting infrastructure |
| [security-sentinel](ptn/security-sentinel/main.bicep) | Sentinel workspace, settings, and connectors |
| [security-syslog](ptn/security-syslog/main.bicep) | Syslog collection infrastructure |
| [tenant-compliance](ptn/tenant-compliance/main.bicep) | Policy and initiative assignments |
| [tenant-hierarchy](ptn/tenant-hierarchy/main.bicep) | Management group hierarchy stub; implementation is incomplete |
| [test-resource-group](ptn/test-resource-group/main.bicep) | Resource group and RBAC scratch example |

## Resources (`res`)

| Module | Purpose |
| --- | --- |
| [authorization-role-assignment-rg](res/authorization-role-assignment-rg/main.bicep) | Role assignment at resource group scope |
| [authorization-role-assignment-sub](res/authorization-role-assignment-sub/main.bicep) | Role assignment at subscription scope |
| [management-subscription-assignment](res/management-subscription-assignment/main.bicep) | Subscription assignments to management groups |
| [network-virtual-network](res/network-virtual-network/main.bicep) | Virtual network with subnet and peering child modules |

## Utilities (`utl`)

| Module | Purpose |
| --- | --- |
| [naming](utl/naming/main.bicep) | Shared resource names, prefixes, and tags |

For example, a stack at `stacks/platform/hub/bootstrap/main.bicep` imports the naming utility as:

```bicep
module conventions '../../../../modules/utl/naming/main.bicep' = {
  name: '${deployment().name}-naming'
  params: {
    tenant: 'ex'
    zoneName: 'hub'
    environmentName: 'nonprod'
    location: 'australiaeast'
    function: 'bootstrap'
    commonTags: {
      IaCLanguage: 'Bicep'
    }
  }
}
```
