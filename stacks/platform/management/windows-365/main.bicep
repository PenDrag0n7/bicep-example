targetScope = 'subscription'

// =========================
// Example ESLZ Common
// =========================

@description('ESLZ environment name that will be hosting the resources.')
param environment string

// Common parameters
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('The role that the deployment will be supporting. e.g. "Monitoring"')
param function string

// YAML sourced configuration for common parameters
var zone = loadYamlContent('../zone.yaml')
var common = loadYamlContent('../../../common.yaml')

// Pattern parameters
@description('Required. The Enterprise App Object ID for the Windows 365 deployments.')
param win365PrincipalId string

@description('Required. The existing Virtual Network that the Windows 365 NICs will attach to.')
param vnetExisting object

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
    zoneTags: zone.tags
    commonTags: common.tags
  }
}

// =========================
// Pattern - Win365 Cloud PC
// =========================

module win365CloudPc '../../../../modules/ptn/compute-windows-365/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    vnetExisting: vnetExisting
    win365PrincipalId: win365PrincipalId
    tags: eslzConventions.outputs.tags
  }
}
