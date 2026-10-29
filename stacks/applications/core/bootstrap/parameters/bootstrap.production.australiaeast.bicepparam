using '../main.bicep'

param function = 'bootstrap'

// Environment parameters
param environment = 'production'
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
      principalId: '00000000-0000-0000-0000-000000000011' // spn-ex-prod-sub-core-Platform-azp
      roleDefinitionIdOrName: 'Key Vault Secrets User'
    }
  ]
  storageAccount: []
}
