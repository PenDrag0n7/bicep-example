targetScope = 'subscription'

// =========================
// Example ESLZ Common
// =========================

@description('Required. ESLZ environment name that will be hosting the resources.')
param environment string

@description('Required. Azure region for deployment.')
param location string

@description('Required. The role that the deployment will be supporting. e.g. "Monitoring"')
param function string

// YAML sourced configuration for common parameters
var zone = loadYamlContent('../zone.yaml')
var common = loadYamlContent('../../../common.yaml')

// Pattern parameters
@description('Optional. The service tier for the Azure Container Registry.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param acrSku string = 'Basic'

@description('Optional. Enable Diagnostic Settings for supported resources.')
param diagnosticSettings array = []

@description('Required. The virtual network that contains the subnet to host the NIC.')
param vnetExisting object

@description('Required. Existing Private DNS Zone that will be associated with the private endpoint for the container registry.')
param privateDnsZoneExisting object

@description('Optional. Array of role assignments to create for the Azure Compute Gallery.')
param acgRoleAssignments array = []

@description('Optional. Images to create.')
param acgImages array?

@description('Optional. Array of role assignments to create for the Azure Container Registry.')
param acrRoleAssignments array = []

// =========================
// ESLZ Conventions
// =========================

module eslzConventions '../../../../modules/resources/helpers/conventions-subscription/main.bicep' = {
  name: '${deployment().name}-convention'
  params: {
    tenant: common.tenant
    zoneName: zone.name
    environmentName: environment
    location: location
    function: function
    zoneTags: zone.tags
    commonTags: common.tags
  }
}

// =============================
// Pattern - Images
// =============================

module images '../../../../modules/patterns/compute/images/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    tags: eslzConventions.outputs.tags
    vnetExisting: vnetExisting
    acrSku: acrSku
    diagnosticSettings: diagnosticSettings
    privateDnsZoneExisting: privateDnsZoneExisting
    acgRoleAssignments: acgRoleAssignments
    acgImages: acgImages
    acrRoleAssignments: acrRoleAssignments
  }
}
