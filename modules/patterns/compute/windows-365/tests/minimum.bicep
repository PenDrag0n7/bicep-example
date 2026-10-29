targetScope = 'subscription'

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-w365-min'

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
    tags: {
      test: 'tag'
    }
    resourceGroupName: '${namePrefix}-rg'
    vnetExisting: {
      name: 'ex-mgt-prod-auea-networking-vnet'
      resourceGroupName: 'ex-management-prod-auea-networking-rg'
    }
    win365PrincipalId: '00000000-0000-0000-0000-000000000019'
  }
}
