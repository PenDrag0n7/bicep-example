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

module minimum '../main.bicep' = {
  name: '${deployment().name}-aks'
  params: {
    tags: tags
    aksConfig: {
      kubernetesVersion: '1.29.2'
    }
    location: location
    namePrefix: namePrefix
    resourceGroupName: '${namePrefix}-rg'
    vnetExisting: {
      vnetName: '${namePrefix}-dep-vnet'
      resourceGroup: dependenciesRGName
      nodePoolSubnet: testDependencies.outputs.vnet.aksNodeSubnet.name
      podSubnet: testDependencies.outputs.vnet.aksPodSubnet.name
    }
  }
  dependsOn: [
    testDependencies
  ]
}
