using '../main.bicep'

param function = 'images'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Container registry config
param acrSku = 'Premium'

param vnetExisting = {
  name: 'ex-mgt-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-management-nprd-auea-networking-rg'
}

param privateDnsZoneExisting = {
  name: 'privatelink.azurecr.io'
  resourceGroupName: 'ex-hub-nprd-auea-private-dns-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000013' // ex-platform-nonproduction-hub-sub
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
    principalId: '00000000-0000-0000-0000-000000000030' // spn-ex-nonprod-sub-management-Platform-azp
  }
]
