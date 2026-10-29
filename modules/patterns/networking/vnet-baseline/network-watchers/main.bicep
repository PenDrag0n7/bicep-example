targetScope = 'resourceGroup'

metadata name = 'Network Watcher and Flow Logs'
metadata description = 'This module deploys a Network Watcher into a given location.'
metadata owner = 'Platform team'
metadata reference = 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkwatchers?pivots=deployment-language-bicep'

@description('Required. Locations to create Network Watchers.')
param locations array = [
  'australiaeast'
  'australiasoutheast'
]

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

// =========================
// Network Watcher
// =========================

resource networkWatcher 'Microsoft.Network/networkWatchers@2023-09-01' = [for location in locations: {
  name: 'NetworkWatcher_${location}'
  location: location
  properties: {}
  tags: tags
}]
