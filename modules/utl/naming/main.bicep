targetScope = 'subscription'

// =========================
// Parameters
// =========================

// common
@minLength(2)
@maxLength(4)
@description('Required. Tenant prefix to be used for naming conventions, e.g Example.')
param tenant string

// environmentName
@minLength(4)
@maxLength(10)
@allowed([
  'nonprod'
  'production'
  'tenant'
])
@description('Required. Environment name that the resources will be deployed into.')
param environmentName string

@minLength(3)
@maxLength(14)
@allowed([
  'tenant'
  'hub'
  'security'
  'identity'
  'management'
  'core'
])
@description('Required. Name of the zone that the deployment is targeting.')
param zoneName string

@allowed([
  'australiaeast'
  'australiasoutheast'
])
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Required. Common deployment tags to be associated with every resource. Stored in common.yaml.')
param commonTags object

@description('Optional. Tags to be associated to this specific zone. E.g. {"CostCentre": "12345"}')
param zoneTags object = {}

@description('Optional. Tags to be associated to this specific module or runtime. {ModuleVersion: "1.0.0"}')
param moduleTags object = {}

@description('Required. The role that the deployed resources will be supporting. e.g. "Monitoring"')
param function string

// =========================
// Variables
// =========================

var envShortName = {
  production: 'prod'
  nonprod: 'nprd'
  tenant: 'tent'
}

var zoneShortName = {
  security: 'sec'
  management: 'mgt'
  identity: 'ide'
  vdicorp: 'vdc'
  vdipaw: 'vdp'
  core: 'cor'
  hub: 'hub'
}

var tags = union({
    Environment: environmentName
    Function: function
    Zone: zoneName
  },
  commonTags,
  zoneTags,
  moduleTags
)

var locationCodes = {
  global: 'glbl'
  australiasoutheast: 'ause'
  australiaeast: 'auea'
  australiacentral: 'auce'
  australiacentral2: 'auc2'
}

// =========================
// Master Naming Convention
// =========================

// <tenant>-<zoneName>-<environment_name>-<location_code>-<function>
var resourceGroupName = toLower('${tenant}-${zoneName}-${envShortName[environmentName]}-${locationCodes[location]}-${function}-rg')
var namePrefix = toLower('${tenant}-${zoneShortName[zoneName]}-${envShortName[environmentName]}-${locationCodes[location]}-${function}')

var resourceMappings = {
  logAnalyticsWorkspace: '${namePrefix}-law'
  storageAccount: '${take(replace(namePrefix, '-', ''), 22)}sa'
}

// General name prefix for the majority of resources
output resourceGroupName string = resourceGroupName
output namePrefix string = namePrefix
output resourceNames object = resourceMappings
output tags object = tags
