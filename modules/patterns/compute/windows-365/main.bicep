targetScope = 'subscription'

metadata name = 'Pattern - Windows 365 Resource Group and RBAC'
metadata description = 'This module deploys a Resource Group and RBAC to allow Windows 365 to function.'
metadata owner = 'Platform team'

// =========================
// Parameters
// =========================

// Common parameters
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Required. Name of the resource group that will be created to host the pattern resources.')
param resourceGroupName string

@description('Required. The Enterprise App Object ID for the Windows 365 deployments.')
param win365PrincipalId string

@description('Required. The existing Virtual Network that the Windows 365 NICs will attach to.')
param vnetExisting object

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

// =========================
// Resource Group - NICs
// =========================

resource win365ResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// =========================
// Role Assignments
// =========================

// Resource Group
module rgRbac '../../../resources/authorization/role-assignments/main.bicep' = {
  name: '${deployment().name}-rbac-rg'
  scope: win365ResourceGroup
  params: {
    roleAssignment: {
      roleDefinitionName: 'Windows 365 Network Interface Contributor'
      principalId: win365PrincipalId
    }
  }
}

// Subscription
module subRbac '../../../resources/authorization/role-assignment-subscription/main.bicep' = {
  name: '${deployment().name}-rbac-subscription'
  params: {
    roleAssignment: {
      roleDefinitionName: 'Reader'
      principalId: win365PrincipalId
    }
  }
}

// Virtual Network
module vnetRbac './rbac-vnet/main.bicep' = {
  name: '${deployment().name}-rbac-vnet'
  scope: resourceGroup(vnetExisting.resourceGroupName)
  params: {
    vnetExisting: vnetExisting
    principalId: win365PrincipalId
  }
}
