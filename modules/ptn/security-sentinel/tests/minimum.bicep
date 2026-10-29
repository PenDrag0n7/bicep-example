targetScope = 'subscription'


// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-sentinel-min'
param resourceGroupName string = '${namePrefix}-rg'

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
  params:{
    location: location
    namePrefix: namePrefix
    resourceGroupName: resourceGroupName
    enableEntityAnalytics: true
    logAnalyticsRoleAssignments: [
      {
        principalId: '00000000-0000-0000-0000-000000000033' // ex - sg-user-administrators
        principalType: 'Group'
        roleDefinitionIdOrName: 'Log Analytics Contributor'
      }
      {
        principalId: '00000000-0000-0000-0000-000000000001' // ex - spn-ex-dev-sub-vdi-paw-Platform-azp
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Log Analytics Contributor'
      }
    ]
    enableUeba: true
  }
}
