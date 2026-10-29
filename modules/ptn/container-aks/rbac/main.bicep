targetScope = 'subscription'

@description('User Assigned Identity Principal Id')
param userAssigedPrincipalId string

@description('Required. Existing Private DNS Zone')
param aksPrivateDnsName string

@description('Required. Existing Private DNS Zone')
param aksPrivateDnsResourceGroup string

@description('Required. Existing Private DNS Zone')
param aksPrivateDnsSubscriptionId string = subscription().subscriptionId

// ACR
@description('Required. Existing Private DNS Zone')
param acrResourceGroup string

@description('Required. Existing Private DNS Zone')
param acrSubscriptionId string = subscription().subscriptionId

@description('Required. Name of ACR Registry')
param containerRegistryName string

//VNET
@description('Required. Existing Private DNS Zone')
param vnetResourceGroup string

// =========================
// ACR RBAC
// =========================

// If containerRegistryName is not provided, then the module will not be deployed
module acrPullRBAC './container-registry/main.bicep' = if(!empty(containerRegistryName)) {
  name: '${deployment().name}-rbac-acr'
  scope: resourceGroup(acrSubscriptionId, acrResourceGroup ?? '')
  params: {
    containerRegistryName: containerRegistryName
    principalId: userAssigedPrincipalId
    roleId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // ACR Pull
  }
}

// =========================
// Private DNS Zone RBAC
// =========================
module privateDnsRBAC './private-dns/main.bicep' = if(!empty(aksPrivateDnsResourceGroup) && !empty(aksPrivateDnsName)) {
  name: '${deployment().name}-rbac-dns'
  scope: resourceGroup(aksPrivateDnsSubscriptionId, aksPrivateDnsResourceGroup ?? '')
  params: {
    privateDnsName: aksPrivateDnsName
    principalId: userAssigedPrincipalId
    roleId: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f' // Private DNS Zone Contributor
  }
}

// =========================
// VNET RBAC
// =========================
module vnetRbac '../../../res/authorization-role-assignment-rg/main.bicep' = {
  name: '${deployment().name}-rbac-vnet'
  scope: resourceGroup(vnetResourceGroup)
  params: {
    roleAssignment: {
      principalId: userAssigedPrincipalId
      roleDefinitionName: 'Network Contributor' // Network Contributor
    }
  }
}
