param vnetExisting object

param principalId string

param roleDefinitionId string = '7eabc9a4-85f7-4f71-b8ab-75daaccc1033' // 'Windows 365 Network User'


// =========================
// Existing Virtual Network
// =========================

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetExisting.name
}

// =========================
// Role Assignments
// =========================

@description('Azure RBAC')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitionId
}

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, vnetExisting.name)
  scope: virtualNetwork

  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinition.id
  }
}
