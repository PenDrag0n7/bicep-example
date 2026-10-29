targetScope = 'subscription'

// =========================
// Parameters
// =========================

param location string = deployment().location
param function string = 'acr'
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-acr-min'

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
    vnetExisting: {
      name: '${namePrefix}-vnet'
      resourceGroupName: testResourceGroup.name
    }
    privateDnsZoneExisting: {
      name: 'privatelink.azurecr.io'
      resourceGroupName: testResourceGroup.name
      subscriptionId: subscription().subscriptionId
    }
    acrSku: 'Premium'
    acrRoleAssignments: [
      {
        principalId: '00000000-0000-0000-0000-000000000033' // ex - sg-user-administrators
        principalType: 'Group'
        roleDefinitionIdOrName: 'AcrPush'
      }
      {
        principalId: '00000000-0000-0000-0000-000000000001' // ex - spn-ex-dev-sub-vdi-paw-Platform-azp
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'AcrPush'
      }
    ]
    diagnosticSettings: [
      {
        name: '${function}-diagnostics'
        workspaceResourceId: patternTestDependencies.outputs.workspaceResourceId
      }
    ]
  }
  dependsOn: [patternTestDependencies]
}
