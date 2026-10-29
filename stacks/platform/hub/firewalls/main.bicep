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

// Module specific parameters
@description('Required: The name of the Virtual Network that contains the subnets for the Virtual Machines.')
param vnetExisting object

@description('Required. Key Vault hosting the Virtual Machine admin credentials.')
param keyVaultExisting object

@description('Required. Location of the existing Public IP Prefix located in the Hub zone.')
param publicIpPrefixExisting object

@description('Required. Deploy and configure the fortiManager Nodes.')
param fortiManagerConfig object = {}

@description('Required. Deploy and configure the fortiGate Nodes.')
param fortiGateConfig object = {}

@description('Required. Deploy and configure the fortiWeb Nodes.')
param fortiWebConfig object = {}

@description('Required. Deploy and configure the fortiAnalyzer Nodes.')
param fortiAnalyzerConfig object = {}

@description('Required. Deploy and configure the fortiAuthenticator Nodes.')
param fortiAuthenticatorConfig object = {}

@description('Required. Deploy and configure the fortiWebManager Nodes.')
param fortiWebManagerConfig object = {}

@description('Required. Enable Diagnostic Settings for supported resources.')
param diagnosticSettings array = []

@description('Optional. Existing Private DNS Zone that will host the A Records for the Management Interface IP.')
param privateDnsZoneExisting object = {}

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
// Pattern - Firewalls
// =========================

module fortinet '../../../../modules/patterns/networking/fortinet/main.bicep' = {
  name: '${deployment().name}-pattern'
  params: {
    namePrefix: eslzConventions.outputs.namePrefix
    location: location
    keyVaultExisting: keyVaultExisting
    vnetExisting: vnetExisting
    publicIpPrefixExisting: publicIpPrefixExisting
    fortiAnalyzerConfig: fortiAnalyzerConfig
    fortiAuthenticatorConfig: fortiAuthenticatorConfig
    fortiGateConfig: fortiGateConfig
    fortiManagerConfig: fortiManagerConfig
    fortiWebConfig: fortiWebConfig
    fortiWebManagerConfig: fortiWebManagerConfig
    privateDnsZoneExisting: privateDnsZoneExisting
    diagnosticSettings: diagnosticSettings
    tags: eslzConventions.outputs.tags
  }
}

/*
ToDo - Prerequisite
az vm image terms accept --urn fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:7.4.2
az vm image terms accept --urn fortinet:fortinet_fortiweb-vm_v5:fortinet_fw-vm:7.4.0
az vm image terms accept --urn fortinet:fortinet-fortianalyzer:fortinet-fortianalyzer:7.4.0
az vm image terms accept --urn fortinet:fortinet-fortimanager:fortinet-fortimanager:7.4.2
az vm image terms accept --urn fortinet:fortinet-fortiauthenticator-vm:fortinet-fac-vm:6.0.2
*/
