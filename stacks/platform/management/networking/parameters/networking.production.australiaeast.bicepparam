using '../main.bicep'

param function = 'networking'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// =========================
// VNet Prefixes
// =========================

param vnetAddressPrefixes = ['10.64.8.0/21']
param vnetDnsServers = ['10.64.2.68']
param createNetworkWatcher = true

// =========================
// Route Tables
// =========================

param routeTables = [
  {
    name: 'baseline'
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.2.62'
          hasBgpOverride: false
        }
      }
      {
        name: 'Vnet-Local'
        properties: {
          addressPrefix: '10.64.8.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.2.62'
          hasBgpOverride: false
        }
      }
    ]
  }
]

// =========================
// Subnets
// =========================

param vnetSubnets = [
  {
    name: 'sn-aks-pods-01'
    addressPrefix: '10.64.8.0/23'
    assignNsg: true
    routeTable: 'baseline'
    delegations: [
      {
        name: 'Microsoft.ContainerService/managedClusters'
        properties: {
          serviceName: 'Microsoft.ContainerService/managedClusters'
        }
      }
    ]
  }
  {
    name: 'sn-aks-nodes-01'
    addressPrefix: '10.64.10.0/24'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-aks-keyvaults'
    addressPrefix: '10.64.11.0/27'
    assignNsg: true
    routeTable: 'baseline'
    privateEndpointNetworkPolicies: 'Enabled'
  }
  {
    name: 'sn-aks-ilb'
    addressPrefix: '10.64.11.32/27'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-container-registry'
    addressPrefix: '10.64.11.64/29'
    assignNsg: true
    routeTable: 'baseline'
    privateEndpointNetworkPolicies: 'Enabled'
  }
  {
    name: 'sn-pki-keyvaults'
    addressPrefix: '10.64.11.72/29'
    assignNsg: true
    routeTable: 'baseline'
    privateEndpointNetworkPolicies: 'Enabled'
  }
  {
    name: 'sn-devops-agents'
    addressPrefix: '10.64.11.80/28'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-vdi-corp'
    addressPrefix: '10.64.11.128/26'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-vdi-paw'
    addressPrefix: '10.64.11.192/26'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-image-build'
    addressPrefix: '10.64.12.0/29'
    assignNsg: true
    routeTable: 'baseline'
  }
  {
    name: 'sn-postgres'
    addressPrefix: '10.64.12.16/28'
    assignNsg: true
    routeTable: 'baseline'
    delegations: [
      {
        name: 'Microsoft.DBforPostgreSQL.flexibleServers'
        properties: {
          serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
        }
      }
    ]
  }
]

// =========================
// Peerings
// =========================

param vnetPeerings = [
  {
    remoteVirtualNetworkId: common.hubVnetResourceIds.prod
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remotePeeringAllowForwardedTraffic: true
    remotePeeringAllowVirtualNetworkAccess: true
    remotePeeringEnabled: true
    useRemoteGateways: false
  }
]
