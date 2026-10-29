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

// AKS Parameters
@description('Required. The configuration of the AKS cluster.')
param aksConfig object

// VNet Parameters
@description('Required. The configuration of the VNet to use for the AKS cluster.')
param vnetExisting object

// Private DNS Zone Parameters
@description('Required. The configuration of the private DNS zone to use for the AKS cluster.')
param privateDnsZoneExisting object

// Container Registry Parameters
@description('Required. The configuration of the container registry to use for the AKS cluster.')
param containerRegistryExisting object

@description('Required. The resource ID of the Log Analytics workspace.')
param workspaceResourceId string

// KeyVault
@description('Required. The configuration of the KeyVault to use for the AKS cluster.')
param keyVaultConfig object

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

// =========================
// Pattern - AKS Baseline
// =========================

module aks '../../../../modules/patterns/containers/aks-baseline/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    namePrefix: eslzConventions.outputs.namePrefix
    privateDnsZoneExisting: privateDnsZoneExisting
    vnetExisting: vnetExisting
    keyVaultConfig: keyVaultConfig
    diagnosticSettings: {
      workspaceResourceId: workspaceResourceId
    }
    containerRegistryExisting: containerRegistryExisting
    aksConfig: aksConfig
    tags: eslzConventions.outputs.tags
  }
}
