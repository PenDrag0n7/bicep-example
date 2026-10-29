using '../main.bicep'

param function = 'aks'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

param workspaceResourceId = common.diagnosticSettings.workspaceResourceId

// Networking Parameters
param vnetExisting = {
  vnetName: 'ex-mgt-prod-auea-networking-vnet'
  resourceGroup: 'ex-management-prod-auea-networking-rg'
  nodePoolSubnet: 'sn-aks-nodes-01'
  podSubnet: 'sn-aks-pods-01'
  keyVaultSubnet: 'sn-aks-keyvaults'
}

// ACR parameters Production
param containerRegistryExisting = {
  name: 'exmgtprodaueaimagesacr'
  resourceGroup: 'ex-management-prod-auea-images-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000004'
}

//Private DNS Zone parameters
param privateDnsZoneExisting = {
  resourceGroupName: 'ex-hub-prod-auea-private-dns-rg'
  privateDnsSubscriptionId: '00000000-0000-0000-0000-000000000029'
}

// KeyVault parameters
param keyVaultConfig = {
  enable: true
  sku: 'standard'
}

// AKS parameters
param aksConfig = {
  kubernetesVersion: '1.29.4'
  enablePrivateCluster: true
  outboundType: 'userDefinedRouting'
  networkPolicy: 'calico'

  //Role assignments
  roleAssignments: [
    {
      principalId: '00000000-0000-0000-0000-000000000009' //pag-azure-root_mg_owner
      roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
    }
    {
      principalId: '00000000-0000-0000-0000-000000000015' // spn-ex-prod-sub-management-Platform-azp
      roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
    }
  ]

  //System node pool
  systemNodePool: {
    availabilityZones: ['1', '2', '3']
  }
  //User node pool
  userNodePools: [
    {
      name: 'user01'
      enableAutoScaling: true
      availabilityZones: ['1', '2', '3']
      minCount: 1
      maxCount: 1
    }
  ]
}
