targetScope = 'subscription'

/* TODO
- Additional test cases aligned with AVM - minimum, WAF aligned, etc
- Scripts for creating and destroying infra for testing
*/

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-vnetbase-min'

// =========================
// Resource Group(s)
// =========================

// Dependency resource group goes here

// =========================
// Dependencies
// =========================

// Dependency resources go here

// =========================
// Test - Minimum Params
// =========================

module patternTestMinimum '../main.bicep' = {
  name: '${deployment().name}-minimum'
  params: {
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'
    vnetAddressPrefixes: ['10.0.0.0/16']
    createNetworkWatcher: false
    enableNsgFlowLogs: false
  }
}
