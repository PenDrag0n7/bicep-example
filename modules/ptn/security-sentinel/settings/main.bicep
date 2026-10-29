// =========================
// Parameters
// =========================

@description('Required. Log Analytics workspace name used by Sentinel.')
param logAnalyticsWorkspaceName string

@allowed([
  'EntityAnalytics'
  'Ueba'
  'EyesOn'
  'Anomalies'
])
@description('Optional. Security Insights setting name. Defaults to "Ueba".')
param settingsKind string = 'Ueba'

@allowed([
  'AuditLogs'
  'AzureActivity'
  'SecurityEvent'
  'SigninLogs'
])
@description('Optional. User and Entity Behavior Analytics (UEBA) data sources.')
param dataSources array = ['AuditLogs','AzureActivity','SigninLogs']

@description('Optional. Entity Analytics providers array. Defaults to "[AzureActiveDirectory]"')
@allowed([
  'ActiveDirectory'
  'AzureActiveDirectory'
])
param entityProvider array = ['AzureActiveDirectory']

var settingsProperties = {
  Ueba: {dataSources: dataSources}
  EntityAnalytics: {entityProviders: entityProvider}
  EyesOn: {}
  Anomalies: {}
}

// =========================
// Log Analytics Workspace
// =========================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

// =========================
// Sentinel Setting
// =========================

resource settings 'Microsoft.SecurityInsights/settings@2023-10-01-preview' = {
  name: settingsKind
  scope: logAnalyticsWorkspace
  kind: settingsKind // To-DO: How do I disable this on the linter - doesn't exist?
  properties: settingsProperties[settingsKind]
}
