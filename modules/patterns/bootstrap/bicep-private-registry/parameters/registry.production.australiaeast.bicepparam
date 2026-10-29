using '../main.bicep'

param resourceGroupName = 'ex-hub-prod-auea-bicepregistry-rg'
param containerRegistryName = 'exhubprodaueabicepacr'
param tags = {
  Owner: 'Platform/Azure/ESLZ'
  'Created By': 'Platform team'
  Reason: 'Bicep module registry to support development for ex'
}

param registryRoleAssignments = [
  {
    principalId: '00000000-0000-0000-0000-000000000033' // ex - sg-user-administrators
    principalType: 'Group'
    roleDefinitionIdOrName: 'AcrPush'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000025' // ex - spn-ex-alz-sub-hub-Platform-azp
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'AcrPush'
  }
]
