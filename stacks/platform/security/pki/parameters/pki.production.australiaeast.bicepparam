using '../main.bicep'

param function = 'pki'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// Diagnostic settings config
param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    logCategoriesAndGroups: [
      {
        categoryGroup: 'allLogs'
      }
    ]
    metricCategories: []
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

// Existing resources config
param keyVaultExisting = {
  name: 'exhubprodaueabootstr-kv'
  resourceGroupName: 'ex-hub-prod-auea-bootstrap-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000029' // ex-platform-production-hub-sub
}

param aksClusterExisting = {
  name: 'exmgtprodaueaaks'
  resourceGroupName: 'ex-management-prod-auea-aks-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000004' // ex-platform-production-management-sub
}

// Key vault config
param deployRootCa = true
