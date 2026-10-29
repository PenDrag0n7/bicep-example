using '../main.bicep'

param function = 'networking'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// =========================
// VNet Baseline Config
// =========================

param vnetAddressPrefixes = ['10.68.0.0/21']
param createNetworkWatcher = true

param diagnosticSettings = [
  {
    name: 'networking-diagnostics'
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
    routes: []
  }
  {
    name: 'mgmt'
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
          addressPrefix: '10.68.0.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.2.62'
          hasBgpOverride: false
        }
      }
      {
        name: 'Subnet-Local'
        properties: {
          addressPrefix: '10.68.3.0/26'
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
        name: 'Spoke-Management-Nonprod'
        properties: {
          addressPrefix: '10.68.8.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.1.190'
          hasBgpOverride: false
        }
      }
      {
        name: 'Spoke-Identity-NonProd'
        properties: {
          addressPrefix: '10.68.16.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.1.190'
          hasBgpOverride: false
        }
      }
      {
        name: 'Spoke-Core-NonProd'
        properties: {
          addressPrefix: '10.68.56.0/21'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.68.1.190'
          hasBgpOverride: false
        }
      }
    ]
  }
]

// Subnet configuration
param vnetSubnets = [
{
    name: 'GatewaySubnet'
    addressPrefix: '10.68.0.0/24'
    assignNsg: false
    routeTable: 'gateway'
  }
  {
    name: 'sn-untrust-waf'
    addressPrefix: '10.68.1.0/26'
    assignNsg: true
  }
  {
    name: 'sn-untrust-fw'
    addressPrefix: '10.68.1.64/26'
    assignNsg: true
  }
  {
    name: 'sn-dmz'
    addressPrefix: '10.68.1.128/26'
    assignNsg: true
    routeTable: 'dmz'
  }
  {
    name: 'sn-trust'
    addressPrefix: '10.68.2.0/26'
    assignNsg: true
  }
  {
    name: 'sn-dns-in'
    addressPrefix: '10.68.2.64/26'
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
    addressPrefix: '10.68.2.128/26'
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
    addressPrefix: '10.68.3.0/26'
    assignNsg: true
    routeTable: 'mgmt'
  }
]

// =========================
// Public IP Prefix
// =========================

param publicIpPrefixLength = '29'


// RBAC TODO

// {
//     principalId: '00000000-0000-0000-0000-000000000027' // spn-ex-nonprod-sub-identity-Platform-azp TICK
//     roleDefinitionName: 'Network Contributor'
//   }
//   {
//     principalId: '00000000-0000-0000-0000-000000000023' // spn-ex-nonprod-sub-core-Platform-azp TICK
//     roleDefinitionName: 'Network Contributor'
//   }
//   {
//     principalId: '00000000-0000-0000-0000-000000000030' // spn-ex-nonprod-sub-management-Platform-azp (Repurposed VDI-PAWs subscription and EA)
//     roleDefinitionName: 'Network Contributor'
//   }
//   {
//     principalId: '00000000-0000-0000-0000-000000000036' // spn-ex-prod-sub-hub-Platform-azp TICK
//     roleDefinitionName: 'Network Contributor'
//   }
