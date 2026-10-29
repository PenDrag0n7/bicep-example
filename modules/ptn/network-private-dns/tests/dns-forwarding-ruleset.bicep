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
// Test - DNS Forwarding Ruleset Params
// =========================

module patternTestHubPrivateResolver '../main.bicep' = {
  name: '${deployment().name}-pattern-hub'
  params: {
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-hub-rg'
    vnetExisting: {
      name: '${namePrefix}-vnet'
      resourceGroupName: testResourceGroup.name
    }
    dnsResolverInboundEndpointIPAddress: '10.68.1.36'
    customDnsZoneNames: [
      {
        name: 'hub.test.com.au'
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
    forwardingRules: [
      {
        name: 'hub-zone'
        domainName: 'hub.test.com.au.'
        targetDnsServers: [
          {
            ipAddress: '10.68.1.36'
            port: '53'
          }
        ]
      }
    ]
  }
  dependsOn: [patternTestDependencies]
}
