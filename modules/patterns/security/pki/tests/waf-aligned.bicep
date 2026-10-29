targetScope = 'subscription'

// =========================
// Parameters
// =========================

@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string = deployment().location

@description('Required. Name of resources that will be created to host the pattern resources.')
param namePrefix string = '${take(uniqueString(deployment().name, location), 6)}-waf'

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

// =========================
// Resource Group(s)
// =========================

resource dependenciesResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${namePrefix}dep-rg'
  location: location
}

// =========================
// Dependencies Module
// =========================

module patternTestDependencies 'dependencies.bicep' = {
  scope: dependenciesResourceGroup
  name: '${deployment().name}-dep'
  params: {
    location: location
    virtualNetworkName: '${namePrefix}-dep-vnet'
    virtualNetworkPrefix: '10.10.0.0/16'
    sqlSubnetName: '${namePrefix}-dep-sql-snet'
    keyVaultSubnetName: '${namePrefix}-dep-keyVault-snet'
    appSubnetName: '${namePrefix}-dep-app-snet'
    logAnalyticsWorkspaceName: '${namePrefix}-dep-la'
    storageSubnetName: '${namePrefix}-dep-st-snet'
    sqlKeyVaultName: '${namePrefix}dep-kv'
    aksName: '${namePrefix}-dep-aks'
    uaiName: '${namePrefix}-uai'
  }
}

// =========================
// Test - WAF Params
// =========================

module patternTestMinimum '../main.bicep' = {
  name: '${deployment().name}-waf'
  params: {
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'
    location: location
    keyVaultExisting: {
      name: patternTestDependencies.outputs.sqlVaultName
      resourceGroupName: dependenciesResourceGroup.name
      subscriptionId: subscription().subscriptionId
    }
    diagnosticSettings: [
      {
        name: '${namePrefix}-diagnostics'
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
        ]
        metricCategories: []
        workspaceResourceId: patternTestDependencies.outputs.logAnalyticsResourceID
      }
    ]
    postgresConfig: {
      administratorLogin: 'admlocal'
      administrators: [
        {
          objectId: '00000000-0000-0000-0000-000000000032'
          principalName: 'sg-pag-az-Example-development-owner'
          principalType: 'Group'
        }
      ]
      databases: [
        {
          charset: 'UTF8'
          collation: 'en_US.utf8'
          name: 'rsa-iss-ca'
        }
        {
          charset: 'UTF8'
          collation: 'en_US.utf8'
          name: 'ecdsa-iss-ca'
        }
      ]
      privateDnsZoneArmResourceId: patternTestDependencies.outputs.sqlPrivateDNSZoneResourceId
      delegatedSubnetResourceId: patternTestDependencies.outputs.sqlSubnetResourceId
    }
    keyVaultPrivateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          patternTestDependencies.outputs.keyVaultPrivateDNSZoneResourceId
        ]
        service: 'vault'
        subnetResourceId: patternTestDependencies.outputs.keyVaultSubnetResourceId
      }
    ]
    aksClusterExisting: {
      name: '${namePrefix}-dep-aks'
      resourceGroupName: dependenciesResourceGroup.name
      subscriptionId: subscription().subscriptionId
    }
    tags: tags
    deployRootCa: false
    keyVaultConfigCommon: {
      enablePurgeProtection: false
      enableSoftDelete: false
    }
    keyVaultRoleAssignments: [
      {
        roleDefinitionIdOrName: '8311e382-0749-4cb8-b61a-304f252e45ec' // AcrPush
        principalId: patternTestDependencies.outputs.uaiPrincipalId
      }
    ]
  }
}
