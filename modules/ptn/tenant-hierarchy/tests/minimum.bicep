targetScope = 'managementGroup'

// =========================
// Parameters
// =========================

param location string = deployment().location
param tenant string = 'ex'

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
    tenant: tenant
    rootManagementGroup: 'ex-eslz-dev-root'
    subscriptionHierarchy: [
      {
        displayName: 'Decomissioned'
        id: 'mg-decom'
        parentId: 'eslz-dev-root'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'LZ'
        id: 'mg-lz'
        parentId: 'eslz-dev-root'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'Platform'
        id: 'mg-platform'
        parentId: 'eslz-dev-root'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'Sandbox'
        id: 'mg-sandbox'
        parentId: 'eslz-dev-root'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'Non-Production'
        id: 'mg-nonprod'
        parentId: 'mg-lz'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'Production'
        id: 'mg-prod'
        parentId: 'mg-lz'
        subscriptionIds: [
        ]
      }
      {
        displayName: 'Secure Research Enclaves'
        id: 'mg-enclave'
        parentId: 'mg-lz'
        subscriptionIds: [
        ]
      }
    ]
  }
}
