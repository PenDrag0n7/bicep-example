@description('An object containing the principalId and roleDefinitionName to use for assigning RBAC to a specific scope.')
param roleAssignment object

module roleId './role-ids/main.bicep' = {
  name: '${deployment().name}-roleid'
  params: {
    roleDefinitionName: roleAssignment.roleDefinitionName
  }
}

resource rgRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(deployment().name, roleAssignment.principalId, roleAssignment.roleDefinitionName)
  properties: {
    principalId: roleAssignment.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.outputs.roleDefinitionId)
  }
}




output roleDefinitionId string = roleId.outputs.roleDefinitionId
output roleDefinitionName string = roleAssignment.roleDefinitionName
