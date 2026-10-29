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

param vnetAddressPrefixes = ['10.64.0.0/21']
param createNetworkWatcher = true

param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

// =========================
// Route Tables
// =========================

param routeTables = [
  {
    name: 'baseline'
    routes: []
  }
  {
    name: 'gateway'
    routes: [
      // {
      //   name: 'Default'
      //   properties: {
      //     addressPrefix: '0.0.0.0/0'
      //     nextHopType: 'Internet'
      //     hasBgpOverride: false
      //   }
      // }
    ]
  }
  {
    name: 'mgmt'
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
          addressPrefix: '10.64.0.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.2.62'
          hasBgpOverride: false
        }
      }
      {
        name: 'Subnet-Local'
        properties: {
          addressPrefix: '10.64.3.0/26'
          nextHopType: 'VnetLocal'
          hasBgpOverride: false
        }
      }
    ]
  }
  {
    name: 'dmz'
    routes: [
      {
        name: 'Spoke-Management-Prod'
        properties: {
          addressPrefix: '10.64.8.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.1.190'
          hasBgpOverride: false
        }
      }
      {
        name: 'Spoke-Security-Prod'
        properties: {
          addressPrefix: '10.64.24.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.1.190'
          hasBgpOverride: false
        }
      }
      {
        name: 'Spoke-Identity-Prod'
        properties: {
          addressPrefix: '10.64.16.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.1.190'
          hasBgpOverride: false
        }
      }
      {
        name: 'Spoke-Core-Prod'
        properties: {
          addressPrefix: '10.64.56.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.64.1.190'
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
    name: 'GatewaySubnet'
    addressPrefix: '10.64.0.0/24'
    assignNsg: false
    routeTable: 'gateway'
  }
  {
    name: 'sn-untrust-waf'
    addressPrefix: '10.64.1.0/26'
    assignNsg: true
  }
  {
    name: 'sn-untrust-fw'
    addressPrefix: '10.64.1.64/26'
    assignNsg: true
  }
  {
    name: 'sn-dmz'
    addressPrefix: '10.64.1.128/26'
    assignNsg: true
    routeTable: 'dmz'
  }
  {
    name: 'sn-trust'
    addressPrefix: '10.64.2.0/26'
    assignNsg: true
  }
  {
    name: 'sn-dns-in'
    addressPrefix: '10.64.2.64/26'
    assignNsg: true
    delegations: [
      {
        name: 'Microsoft.Network.dnsResolvers'
        properties: {
          serviceName: 'Microsoft.Network/dnsResolvers'
        }
      }
    ]
  }
  {
    name: 'sn-dns-out'
    addressPrefix: '10.64.2.128/26'
    assignNsg: true
    delegations: [
      {
        name: 'Microsoft.Network.dnsResolvers'
        properties: {
          serviceName: 'Microsoft.Network/dnsResolvers'
        }
      }
    ]
  }
  {
    name: 'sn-mgmt'
    addressPrefix: '10.64.3.0/26'
    assignNsg: true
    routeTable: 'mgmt'
  }
  // {
  //   name: 'sn-tactical'
  //   assignNsg: false
  //   addressPrefix: '10.64.3.64/26'
  // }
]

// =========================
// Public IP Prefix
// =========================

param publicIpPrefixLength = '29'

// =========================
// Peerings
// =========================

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
