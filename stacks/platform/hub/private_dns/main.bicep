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
@description('Required. Array of custom private DNS zone names.')
param customDnsZoneNames array

@description('Optional. Shared list of Azure Private Endpoint Private DNS Zone names.')
param privateEndpointDnsZoneNames array = []

@description('Required. Private IP address of the inbound endpoint.')
param dnsResolverInboundEndpointIPAddress string

@description('Required. The virtual network that contains the subnet to host the NIC.')
param vnetExisting object

@description('Optional. Array of DNS forwarding rules for the private DNS resolver.')
param forwardingRules array = []

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
// Pattern - Private DNS
// =========================

module privateDns '../../../../modules/patterns/networking/private-dns/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    location: location
    namePrefix: eslzConventions.outputs.namePrefix
    resourceGroupName: eslzConventions.outputs.resourceGroupName
    tags: eslzConventions.outputs.tags
    customDnsZoneNames: customDnsZoneNames
    privateEndpointDnsZoneNames: privateEndpointDnsZoneNames
    dnsResolverInboundEndpointIPAddress: dnsResolverInboundEndpointIPAddress
    vnetExisting: vnetExisting
    forwardingRules: forwardingRules
  }
}
