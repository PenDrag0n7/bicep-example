targetScope = 'subscription'

/* TODO
- Additional test cases aligned with AVM - minimum, WAF aligned, etc
- Scripts for creating and destroying infra for testing
*/

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-zone-min'

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
    tags: {
      Test: 'Tag'
    }
    roleAssignments: {
      keyVault: [
        {
          principalId: '00000000-0000-0000-0000-000000000034' // sg-pag-az-rootmg-owner - PIM admin group
          roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        }
        {
          principalId: '00000000-0000-0000-0000-000000000021' // spn-ex-dev-sub-hub-Platform-azp
          roleDefinitionIdOrName: 'Key Vault Secrets User'
        }
      ]
      storageAccount: []
    }
  }
}
