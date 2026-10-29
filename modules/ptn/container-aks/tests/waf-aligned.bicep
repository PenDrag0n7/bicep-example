targetScope = 'subscription'

// =========================
// Parameters
// =========================

@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string = deployment().location

@description('Required. Name of resources that will be created to host the pattern resources.')
param namePrefix string = 't${take(uniqueString(deployment().name, location), 6)}-waf'

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

var dependenciesRGName = '${namePrefix}dep-rg'
resource dependenciesResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: dependenciesRGName
  location: location
}

module testDependencies 'dependencies.bicep' = {
  scope: dependenciesResourceGroup
  name: '${deployment().name}-aks-dep'
  params: {
    location: location
    virtualNetworkName: '${namePrefix}-dep-vnet'
    addressPrefix: '10.10.0.0/16'
    logAnalyticsWorkspaceName: '${namePrefix}-dep-law'
  }
}

module wafTest '../main.bicep' = {
  name: '${deployment().name}-aks'
  params: {
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'

    privateDnsZoneExisting: {
      resourceGroupName: dependenciesRGName
      privateDnsSubscriptionId: subscription().subscriptionId
    }

    vnetExisting: {
      vnetName: '${namePrefix}-dep-vnet'
      resourceGroup: dependenciesRGName
      nodePoolSubnet: testDependencies.outputs.vnet.aksNodeSubnet.name
      podSubnet: testDependencies.outputs.vnet.aksPodSubnet.name
      keyVaultSubnet: testDependencies.outputs.vnet.aksKeyVaultSubnet.name
    }

    // KeyVault
    keyVaultConfig: {
      enable: true
      sku: 'standard'
    }

    diagnosticSettings: {
      workspaceResourceId: testDependencies.outputs.logAnalyticsResourceID
    }

    containerRegistryExisting: {
      name: testDependencies.outputs.acrName
      resourceGroup: dependenciesRGName
    }

    aksConfig: {
      kubernetesVersion: '1.29.2'
      networkPolicy: 'calico'
      outboundType: 'loadBalancer'

      //Role assignments
      roleAssignments: [{
        principalId: '00000000-0000-0000-0000-000000000032' // sg-pag-az-Example-development-owner
        roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
      }]

      //System node pool
      systemNodePool: {
        vmSize: 'Standard_B2s'
        osDiskSizeGB: 30
      }
      //User node pool
      userNodePools: [
        {
          name: 'user01'
          vmSize: 'Standard_B2s'
          osDiskSizeGB: 30
          maxCount: 2
          minCount: 1
          enableAutoScaling: true
        }
      ]
    }
    tags: tags
  }
  dependsOn: [
    testDependencies
  ]
}
