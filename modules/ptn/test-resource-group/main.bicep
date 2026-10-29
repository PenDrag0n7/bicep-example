targetScope = 'subscription'
// Bicep file to create a resource group rty

param  resourceGroupName string


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: 'eastus'
}

module rbac './rbac/main.bicep' = {
  scope: subscription()
  name: 'rbac'
  params: {
    userAssigedPrincipalId: ''
    acrResourceGroup: 'asd'
    aksPrivateDnsName: 'asd'
    aksPrivateDnsResourceGroup: 'asd'
    containerRegistryName: 'asd'
    vnetResourceGroup: 'asd'
  }
}


// test sa asd
