using '../main.bicep'

param function = 'ado-agents'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

param vnetExisting = {
  name: 'ex-mgt-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-management-nprd-auea-networking-rg'
}

param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

param keyVaultExisting = {
  name: 'exhubnprdaueabootstr-kv'
  resourceGroupName: 'ex-hub-nprd-auea-bootstrap-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000013' // ex-platform-nonproduction-hub-sub
}

param imageReferenceId = '/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/ex-management-nprd-auea-images-rg/providers/Microsoft.Compute/galleries/exmgtnprdaueaimagesacg/images/ado-ubuntu-2204'

param acgImageVersion = '20240604.1.0'
