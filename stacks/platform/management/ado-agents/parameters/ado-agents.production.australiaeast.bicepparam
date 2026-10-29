using '../main.bicep'

param function = 'ado-agents'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

param vnetExisting = {
  name: 'ex-mgt-prod-auea-networking-vnet'
  resourceGroupName: 'ex-management-prod-auea-networking-rg'
}

param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

param keyVaultExisting = {
  name: 'exhubprodaueabootstr-kv'
  resourceGroupName: 'ex-hub-prod-auea-bootstrap-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000029' // ex-platform-production-hub-sub
}

param imageReferenceId = '/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/ex-management-prod-auea-images-rg/providers/Microsoft.Compute/galleries/exmgtprodaueaimagesacg/images/ado-ubuntu-2204'

param acgImageVersion = '20240604.1.0'
