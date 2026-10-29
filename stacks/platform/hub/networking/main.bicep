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
@description('Required. Array of CIDR ranges that will be assigned to the VNet.')
param vnetAddressPrefixes array

@description('Required. Array of subnets that will be created within the VNet.')
param vnetSubnets array

@description('Required. The role that the deployment will be supporting. e.g. "Monitoring"')
param routeTables array

@description('Optional. Array of DNS Servers to use within the VNet.')
param vnetDnsServers array = []

@description('Optional. Array of peerings for the VNet.')
param vnetPeerings array = []

@description('Optional. Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet.')
param vnetEncryption bool = false

@description('Optional. Enables NSG Flow logs on any NSG that is created and assigned to subnets within this pattern. Requires flowLogSettings to be supplied.')
param enableNsgFlowLogs bool = false

@description('Optional. An array of diagnostic settings to apply to applicable resources.')
param diagnosticSettings array = []

@description('Optional. An object containing the logging storage account that the flow logs will be stored in.')
param flowLogSettings object = {}

@description('Optional. Length of the Public IP Prefix. Value must be between 28 and 31 inclusive.')
param publicIpPrefixLength string = ''

@description('Optional. Create a Network Watcher resource if one does not already exist for the subscription and region.')
param createNetworkWatcher bool = false


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
// Pattern - Networking
// =========================

module networking '../../../../modules/patterns/networking/vnet-baseline/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetSubnets: vnetSubnets
    vnetPeerings: vnetPeerings
    vnetDnsServers: vnetDnsServers
    vnetEncryption: vnetEncryption
    enableNsgFlowLogs: enableNsgFlowLogs
    createNetworkWatcher: createNetworkWatcher
    publicIpPrefixLength: publicIpPrefixLength
    flowLogSettings: flowLogSettings
    routeTables: routeTables
    diagnosticSettings: diagnosticSettings
    tags: eslzConventions.outputs.tags
  }
}
