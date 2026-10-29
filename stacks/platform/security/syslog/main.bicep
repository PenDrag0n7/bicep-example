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

@description('Required. Vnet object to be used for the syslog deployment.')
param vnetExisting object

@description('Required. The name of the key vault to be used for the syslog deployment.')
param keyVaultName string

@description('Required. The IP address of the internal load balancer to be used for the syslog deployment.')
param ilbIpAddress string

@description('Required. The name of the resource group that the key vault is in.')
param keyVaultResourceGroupName string

@description('Optional. Syslog data sources to be used for the syslog deployment')
param dataSources object = {}

@description('Optional. Syslog data flows to be used for the syslog deployment.')
param dataFlows array = []

@description('Optional. Syslog Log Analytics destinations to be used for the syslog deployment.')
param destinations object = {}

@description('Optional. Diagnostic settings to be used for the syslog deployment.')
param diagnosticSettings object = {}

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
// Pattern - Syslog
// =========================

module syslog '../../../../modules/ptn/security-syslog/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    keyVaultExisting: {
      name: keyVaultName
      resourceGroupName: keyVaultResourceGroupName
    }
    ilbIpAddress: ilbIpAddress
    diagnosticSettings: diagnosticSettings
    namePrefix: eslzConventions.outputs.namePrefix
    location: location
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    vnetExisting: vnetExisting
    dataFlows: dataFlows
    dataSources: dataSources
    destinations: destinations
  }
}
