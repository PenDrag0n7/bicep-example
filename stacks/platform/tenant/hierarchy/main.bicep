targetScope = 'managementGroup'

// =========================
// Example ESLZ Common
// =========================

// YAML sourced configuration for common parameters
var zone = loadYamlContent('../zone.yaml')
var common = loadYamlContent('../../../common.yaml')

// =========================
// Pattern - Sub Hierarchy
// =========================

@description('Required. List of arrays of management group objects. Requires "displayName", "id", "parentId" and "subscriptionIds".')
param subscriptionHierarchy array

@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

module managementGroups '../../../../modules/ptn/tenant-hierarchy/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    subscriptionHierarchy: subscriptionHierarchy
    location: location
    rootManagementGroup: zone.rootManagementGroup
    tenant: common.tenant
  }
}
