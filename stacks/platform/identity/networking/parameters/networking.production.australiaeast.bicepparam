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

param vnetAddressPrefixes = ['10.64.16.0/21']
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
          addressPrefix: '10.64.16.0/21'
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

param vnetSubnets = []

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
