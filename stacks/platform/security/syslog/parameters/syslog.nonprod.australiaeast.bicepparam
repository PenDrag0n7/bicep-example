using '../main.bicep'

param function = 'syslog'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

param ilbIpAddress = '10.65.24.4'
param keyVaultName = 'exsecnprdaueabootstr-kv'
param keyVaultResourceGroupName = 'ex-security-nprd-auea-bootstrap-rg'

param vnetExisting = {
  name: 'ex-sec-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-security-nprd-auea-networking-rg'
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
