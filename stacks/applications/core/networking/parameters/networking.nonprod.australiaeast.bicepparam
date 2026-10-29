using '../main.bicep'

param function = 'networking'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// =========================
// VNet Prefixes
// =========================

param vnetAddressPrefixes = ['10.68.56.0/21']
param vnetDnsServers = ['10.68.2.68']
param createNetworkWatcher = true

// Route table configuration
param routeTables = [
  {
    name: 'baseline'
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.2.62'
          hasBgpOverride: false
        }
      }
      {
        name: 'Vnet-Local'
        properties: {
          addressPrefix: '10.68.56.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.2.62'
          hasBgpOverride: false
        }
      }
    ]
  }
]

// Subnet configuration
param vnetSubnets = []

param vnetPeerings = [
  {
    remoteVirtualNetworkId: common.hubVnetResourceIds.nonprod
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remotePeeringAllowForwardedTraffic: true
    remotePeeringAllowVirtualNetworkAccess: true
    remotePeeringEnabled: true
    useRemoteGateways: false
  }
]
