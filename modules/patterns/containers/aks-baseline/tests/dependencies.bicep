// General Parameters
@description('Required. The location to deploy to.')
param location string = resourceGroup().location

// Log Analytics Workspace Parameters
@description('Required. The name of the Log Analytics Workspace to create.')
param logAnalyticsWorkspaceName string

// Virtual Network Parameters
@description('Required. The name of the Virtual Network to create.')
param virtualNetworkName string

@description('Required. The name of the Virtual Network to create.')
param addressPrefix string


// =========================
// Virtual Network
// =========================

var subnet = [
  {
    name: 'sn-aks-pods-01'
    addressPrefix: cidrSubnet(addressPrefix, 23, 8)
    privateEndpointNetworkPolicies: 'Disabled'
    // Key vault delegation
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
    ]
    delegations: [
      {
        name: 'managedClusters'
        properties: {
          serviceName: 'Microsoft.ContainerService/managedClusters'
        }
      }
    ]
  }
  {
    name: 'sn-aks-nodes-01'
    addressPrefix: cidrSubnet(addressPrefix, 24, 10)
    privateEndpointNetworkPolicies: 'Disabled'
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    name: 'sn-aks-keyvaults'
    addressPrefix: cidrSubnet(addressPrefix, 27, 11)
    privateEndpointNetworkPolicies: 'Disabled'
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
  {
    name: 'sn-aks-ilb'
    addressPrefix: cidrSubnet(addressPrefix, 27, 12)
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'sn-container-registry'
    addressPrefix: cidrSubnet(addressPrefix, 29, 13)
    privateEndpointNetworkPolicies: 'Disabled'
  }
]
module vnet 'br/public:avm/res/network/virtual-network:0.1.5' = {
  name: '${deployment().name}-vnet'
  params: {
    location: location
    name: virtualNetworkName
    enableTelemetry: false
    addressPrefixes: [addressPrefix]
    subnets: subnet
  }
}

module acr 'br/public:avm/res/container-registry/registry:0.1.1' = {
  name: '${deployment().name}-acr'
  params: {
    location: location
    name: toLower(replace('${deployment().name}acr01', '-', ''))
    acrSku: 'Standard'
    enableTelemetry: false
  }
}
// =========================
// DNS Zone
// =========================

var privetDNSZones = [
  'privatelink.vaultcore.azure.net'
  'privatelink.file.core.windows.net'
  'privatelink.australiaeast.azmk8s.io'
  'privatelink.australiasoutheast.azmk8s.io'
]

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.5' = [ for (zone, index) in privetDNSZones : {
  name: '${deployment().name}-prvDns-${index}'
  params: {
    location: 'global'
    name: zone
    enableTelemetry: false
    virtualNetworkLinks: [
      {
        name: '${vnet.name}-vnetlink'
        virtualNetworkResourceId: vnet.outputs.resourceId
        registrationEnabled: false
        location: 'global'
      }
    ]
  }
}]

var vnetInfo = {
  name: vnet.outputs.name
  resourceId: vnet.outputs.resourceId
  aksPodSubnet: {
      name: vnet.outputs.subnetNames[0]
      id: vnet.outputs.subnetResourceIds[0]
    }
    aksNodeSubnet: {
      name: vnet.outputs.subnetNames[1]
      id: vnet.outputs.subnetResourceIds[1]
    }
    aksKeyVaultSubnet: {
      name: vnet.outputs.subnetNames[2]
      id: vnet.outputs.subnetResourceIds[2]
    }
    aksLbSubnetId: {
      name: vnet.outputs.subnetNames[3]
      id: vnet.outputs.subnetResourceIds[3]
    }
    aksAcrSubnetId: {
      name: vnet.outputs.subnetNames[4]
      id: vnet.outputs.subnetResourceIds[4]
    }
}


// =========================
// Log analytics
// =========================

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

// =========================
// Outputs
// =========================

output rgName string = resourceGroup().name

@description('The resource ID of the created Virtual Network.')
output vnetResourceId string = vnet.outputs.resourceId

@description('The subnet ID of the created Virtual Network.')
output vnet object = vnetInfo

output acrName string = acr.outputs.name


@description('The resource ID of the created Log Analytcis Workspace.')
output logAnalyticsResourceID string = law.id
