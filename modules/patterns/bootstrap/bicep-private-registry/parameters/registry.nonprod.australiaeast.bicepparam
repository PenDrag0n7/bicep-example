using '../main.bicep'

param resourceGroupName = 'ex-hub-nprd-auea-bicepregistry-rg'
param containerRegistryName = 'exhubnprdaueabicepacr'
param tags = {
  Owner: 'Platform/Microsoft/ESLZ'
  Reason: 'Private Bicep module registry for ESLZ Development'
}

param registryRoleAssignments = [
  {
    principalId: '00000000-0000-0000-0000-000000000010' // ex - sg-pag-az_root_mg_owner
    principalType: 'Group'
    roleDefinitionIdOrName: 'AcrPush'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000020' // ex - spn-eslz-dev-sub-hub
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'AcrPush'
  }
]
