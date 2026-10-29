targetScope = 'subscription'

/* TODO
- Additional test cases aligned with AVM - minimum, WAF aligned, etc
- Scripts for creating and destroying infra for testing
*/

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-vnetbase-waf'

// =========================
// Resource Group(s)
// =========================

resource testResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${namePrefix}-deps-rg'
  location: location
}

// =========================
// Dependencies
// =========================

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.3.3' = {
  name: '${deployment().name}-dep-law'
  scope: testResourceGroup
  params: {
    enableTelemetry: false
    name: '${namePrefix}-law'
    location: location
  }
}

module virtualNetworkHub 'br/public:avm/res/network/virtual-network:0.1.4' = {
  name: '${deployment().name}-dep-vnet'
  scope: testResourceGroup
  params: {
    addressPrefixes: [
      '10.1.0.0/16'
    ]
    name: '${namePrefix}-testdep-hub-vnet'
    location: location
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.6.3' = {
  name: '${deployment().name}-dep-storage'
  scope: testResourceGroup
  params: {
    name: '${take(uniqueString(deployment().name, location), 6)}sa01'
    allowBlobPublicAccess: false
    enableTelemetry: false
  }
}

// =========================
// Test - WAF-Aligned Params
// =========================

module patternTest '../main.bicep' = {
  name: '${deployment().name}-wafaligned'
  params: {
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'
    roleAssignments: []
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalytics.outputs.resourceId
        storageAccountResourceId: storageAccount.outputs.resourceId
      }
    ]
    flowLogSettings: {
      workspaceResourceId: logAnalytics.outputs.resourceId
      storageAccountResourceId: storageAccount.outputs.resourceId
    }
    enableNsgFlowLogs: false
    createNetworkWatcher: false
    vnetAddressPrefixes: ['10.0.0.0/16']
    vnetPeerings: [
      {
        remoteVirtualNetworkId: virtualNetworkHub.outputs.resourceId
      }
    ]
    routeTables: [
      {
        name: 'baseline'
        routes: [
          {
            name: 'default'
            properties: {
              addressPrefix: '0.0.0.0/0'
              nextHopIpAddress: '172.16.0.20'
              nextHopType: 'VirtualAppliance'
            }
          }
        ]
      }
      {
        name: 'aks'
        routes: []
      }
    ]
    vnetSubnets: [
      {
        addressPrefix: '10.0.1.0/24'
        name: 'servers'
        assignNsg: true
        routeTable: 'baseline'
        securityRules: [
          {
            name: 'TestRule'
            properties: {
              access: 'Allow'
              description: 'Tests specific IPs and ports'
              destinationAddressPrefix: '*'
              destinationPortRange: '8080'
              direction: 'Inbound'
              priority: 100
              protocol: '*'
              sourceAddressPrefix: '*'
              sourcePortRange: '*'
            }
          }
        ]
      }
      {
        addressPrefix: '10.0.2.0/24'
        name: 'aks-nodes'
        routeTable: 'aks'
        assignNsg: true
      }
      {
        addressPrefix: '10.0.3.0/24'
        name: 'subnet-3'
        routeTable: 'baseline'
        assignNsg: true
        securityRules: []
      }
      {
        addressPrefix: '10.0.4.0/27'
        name: 'subnet-1'
        assignNsg: true
        routeTable: 'baseline'
      }
      {
        addressPrefix: '10.0.5.0/27'
        name: 'GatewaySubnet'
        assignNsg: false
      }
    ]
  }
}

output resourceGroupName string = testResourceGroup.name
