targetScope = 'subscription'

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-dns-min'

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

module patternTestDependencies 'dependencies.bicep' = {
  scope: testResourceGroup
  name: '${deployment().name}-deps'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

// =========================
// Test - Minimum Params
// =========================

module patternTestPrivateResolver '../main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'
    vnetExisting: {
      name: '${namePrefix}-vnet'
      resourceGroupName: testResourceGroup.name
    }
    dnsResolverInboundEndpointIPAddress: '10.68.1.36'
    customDnsZoneNames: [
      {
        name: 'test.com.au'
        registrationEnabled: true
      }
    ]
    privateEndpointDnsZoneNames: [
      'privatelink.managedhsm.azure.net'
      'privatelink.azconfig.io'
      'privatelink.file.core.windows.net'
      'privatelink.azure-devices.net'
      'privatelink.blob.core.windows.net'
    ]
  }
  dependsOn: [patternTestDependencies]
}
