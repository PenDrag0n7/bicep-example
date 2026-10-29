metadata name = 'Network Flow Logs'
metadata description = 'This module creates the NSG Flow Logs for the nsg name passed into the module.'
metadata owner = 'Platform team'
metadata reference = 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkwatchers?pivots=deployment-language-bicep'

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

@description('Optional. Retention period in days. Default is zero which stands for permanent retention. Can be any Integer from 0 to 365')
@minValue(0)
@maxValue(365)
param retentionDays int = 0

@description('Optional. FlowLogs Version. Correct values are 1 or 2 (default)')
@allowed([
  1
  2
])
param flowLogsVersion int = 2

param nsgName string
param namePrefix string

@description('Optional. An array of diagnostic settings to apply to applicable resources.')
param flowLogSettings object

// =========================
// Flow Logs
// =========================

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-09-01' = {
  name: 'NetworkWatcher_${location}/FlowLogs_${nsgName}'
  location: location
  properties: {
    targetResourceId: resourceId('Microsoft.Network/networkSecurityGroups', '${namePrefix}-${nsgName}-nsg')
    storageId: flowLogSettings.storageAccountResourceId
    enabled: true
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: flowLogsVersion
    }
  }
  tags: tags
}
