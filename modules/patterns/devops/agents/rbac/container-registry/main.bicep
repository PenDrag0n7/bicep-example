@description('Required. Principal ID for the role assignment')
param principalId string

@description('Required. Azure RBAC role ID')
param roleId string

@description('Required. Name of Registry')
param containerRegistryName string

@description('Existing Registry')
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: containerRegistryName
}

@description('Azure RBAC')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleId
}

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleId, containerRegistryName)
  scope: containerRegistry
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinition.id
  }
}


// TEST asd asd
