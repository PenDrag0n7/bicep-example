targetScope = 'subscription'

// =========================
// Example ESLZ Common
// =========================

@description('ESLZ environment name that will be hosting the resources.')
param environment string

@description('Azure region for deployment.')
param location string

@description('The role that the deployment will be supporting. e.g. "Monitoring"')
param function string

@description('If false, the Entity Analytics settings will be skipped, Use this as a workaround for ETAG errors.')
param enableEntityAnalytics bool = true

@description('If false, the User and Entity Behavior Analytics settings will be skipped, Use this as a workaround for ETAG errors.')
param enableUeba bool = true

// YAML sourced configuration for common parameters
var zone = loadYamlContent('../zone.yaml')
var common = loadYamlContent('../../../common.yaml')

@description('Optional. Array of role assignments to create.')
param logAnalyticsRoleAssignments array = []

// =========================
// ESLZ Conventions
// =========================

module eslzConventions '../../../../modules/utl/naming/main.bicep' = {
  name: '${deployment().name}-convention'
  params: {
    tenant: common.tenant
    zoneName: zone.name
    environmentName: environment
    location: location
    function: function
    commonTags: common.tags
    zoneTags: zone.tags
  }
}

// =========================
// Pattern - Sentinel
// =========================

module sentinel '../../../../modules/ptn/security-sentinel/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    namePrefix: eslzConventions.outputs.namePrefix
    enableEntityAnalytics: enableEntityAnalytics
    logAnalyticsRoleAssignments: logAnalyticsRoleAssignments
    enableUeba: enableUeba
    tags: eslzConventions.outputs.tags
  }
}
