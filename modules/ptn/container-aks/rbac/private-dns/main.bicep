@description('Required. Principal ID for the role assignment')
param principalId string

@description('Optional. Principal Type for the role assignment, default is ServicePrincipal. Allowed values are Device, ForeignGroup, Group, ServicePrincipal, User, or empty string for default.')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
  ''
])
param principalType string = 'ServicePrincipal'

@description('Required. Azure RBAC role ID')
param roleId string = 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'

@description('Required. Existing Private DNS Zone')
param privateDnsName string

@description('Existing Private DNS Zone')
resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsName
}

@description('Azure RBAC')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleId
}

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleId, privateDnsName)
  scope: privateDns

  properties: {
    principalId: principalId
    principalType: empty(principalType) ? null : principalType
    roleDefinitionId: roleDefinition.id
  }
}
