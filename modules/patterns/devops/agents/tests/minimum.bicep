targetScope = 'subscription'

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-agents-min'

@secure()
@description('Required. Password supplied by the caller for the test virtual machine.')
param vmAdminPassword string

// =========================
// Resource Group(s)
// =========================

resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${namePrefix}-deps-rg'
  location: location
}

// =========================
// Dependencies
// =========================

module patternTestDependencies './dependencies.bicep' = {
  scope: testResourceGroup
  name: '${deployment().name}-deps'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

// =========================
// Test - Minimum Params
// =========================

module patternTestContainerRegistry '../main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    resourceGroupName: '${namePrefix}-rg'
    namePrefix: namePrefix
    vmAdminUsername: 'test-admin'
    vmAdminPassword: vmAdminPassword
    vnetExisting: {
      name: '${namePrefix}-vnet'
      resourceGroupName: testResourceGroup.name
    }
    keyVaultExisting: {
      name: '${namePrefix}-kv'
      resourceGroupName: testResourceGroup.name
      subscriptionId: subscription().subscriptionId
    }
  }
  dependsOn: [patternTestDependencies]
}
