using '../main.bicep'

param function = 'images'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Container registry config
param acrSku = 'Premium'

param vnetExisting = {
  name: 'ex-mgt-prod-auea-networking-vnet'
  resourceGroupName: 'ex-management-prod-auea-networking-rg'
}

param privateDnsZoneExisting = {
  name: 'privatelink.azurecr.io'
  resourceGroupName: 'ex-hub-prod-auea-private-dns-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000029' // ex-platform-production-hub-sub
}

param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

param acgImages = [
  {
    name: 'ado-ubuntu-2204'
    generation: 'V2'
    features: [
      {
        name: 'SecurityType'
        value: 'TrustedLaunch'
      }
    ]
    osType: 'Linux'
    imageType: 'Generalized'
    publisher: 'Example'
    offer: 'Ubuntu22.04'
    sku: 'Trusted'
  }
]

param acrRoleAssignments = [
  {
    roleDefinitionIdOrName: 'AcrPush'
    principalId: '00000000-0000-0000-0000-000000000015' // spn-ex-prod-sub-management-Platform-azp
  }
]
