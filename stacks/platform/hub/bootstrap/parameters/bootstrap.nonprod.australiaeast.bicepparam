using '../main.bicep'

param function = 'bootstrap'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// =========================
// Role Assignments
// =========================

param roleAssignments = {
  keyVault: [
    {
      principalId: '00000000-0000-0000-0000-000000000009' // pag-azure-root_mg_owner
      roleDefinitionIdOrName: 'Key Vault Administrator'
    }
    {
      principalId: '00000000-0000-0000-0000-000000000007' // spn-ex-nonprod-sub-hub-Platform-azp
      roleDefinitionIdOrName: 'Key Vault Secrets User'
    }
    {
      principalId: '00000000-0000-0000-0000-000000000030' // spn-ex-nonprod-sub-management-Platform-azp
      roleDefinitionIdOrName: 'Key Vault Contributor'
    }
  ]
  storageAccount: []
}
