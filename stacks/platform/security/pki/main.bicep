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
@description('Optional. An array of diagnostic settings to apply to applicable resources.')
param diagnosticSettings array = []

@description('Required. Key Vault hosting the PostgreSQL admin credentials.')
param keyVaultExisting object

@description('Required. Name of the Azure Kubernetes Service managed cluster.')
param aksClusterExisting object

@description('Optional. Enable or disable the deployment of Root CA Key Vault.')
param deployRootCa bool = false

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
// Pattern - PKI
// =========================

module pki '../../../../modules/patterns/security/pki/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    diagnosticSettings: diagnosticSettings
    tags: eslzConventions.outputs.tags
    aksClusterExisting: aksClusterExisting
    keyVaultExisting: keyVaultExisting
    deployRootCa: deployRootCa
  }
}
