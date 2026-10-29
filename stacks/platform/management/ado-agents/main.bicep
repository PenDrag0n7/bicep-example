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
@description('Optional. Enable Diagnostic Settings for supported resources.')
param diagnosticSettings array = []

@description('Required. The virtual network that contains the subnet to host the NIC.')
param vnetExisting object

@description('Required. Key Vault hosting the Virtual Machine admin credentials.')
param keyVaultExisting object

@description('Optional. Virtual Machine image reference Id.')
param imageReferenceId string?

@description('Optional. The version of the Azure Compute Gallery image for the Virtual Machine Scale Set.')
param acgImageVersion string?

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
// Pattern - Azure DevOps Agents
// =============================

module images '../../../../modules/patterns/devops/agents/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    tags: eslzConventions.outputs.tags
    vnetExisting: vnetExisting
    diagnosticSettings: diagnosticSettings
    keyVaultExisting: keyVaultExisting
    imageReferenceId: imageReferenceId
    acgImageVersion: acgImageVersion
  }
}
