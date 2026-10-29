using '../main.bicep'

param function = 'syslog'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

param ilbIpAddress = '10.64.24.4'
param keyVaultName = 'exsecprodaueabootstr-kv'
param keyVaultResourceGroupName = 'ex-security-prod-auea-bootstrap-rg'

param vnetExisting = {
  name: 'ex-sec-prod-auea-networking-vnet'
  resourceGroupName: 'ex-security-prod-auea-networking-rg'
}

param diagnosticSettings = {
  workspaceResourceId: common.diagnosticSettings.workspaceResourceId
}

param dataSources = {
  syslog: [
    {
      facilityNames: [
        '*'
      ]
      logLevels: [
        'Warning'
        'Error'
        'Critical'
        'Alert'
        'Emergency'
      ]
      name: 'syslogDataSource'
      streams: [
        'Microsoft-Syslog'
      ]
    }
  ]
}

param dataFlows = [
  {
    streams: [
      'Microsoft-Syslog'
    ]
    destinations: [
      'syslogWorkspace'
    ]
  }
]

param destinations = {
  logAnalytics: [
    {
      workspaceResourceId: common.diagnosticSettings.workspaceResourceId
      name: 'syslogWorkspace'
    }
  ]
}
