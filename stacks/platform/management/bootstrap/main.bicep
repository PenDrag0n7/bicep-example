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

@description('Optional. Object of role assignments to create.')
param roleAssignments object = {}

// YAML sourced configuration for common parameters
var zone = loadYamlContent('../zone.yaml')
var common = loadYamlContent('../../../common.yaml')

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
// Pattern - Zone Bootstrap
// =========================

module bootstrap '../../../../modules/patterns/bootstrap/zone/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    tags: eslzConventions.outputs.tags
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    roleAssignments: roleAssignments
  }
}
