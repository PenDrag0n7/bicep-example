using '../main.bicep'

param function = 'pki'

// Environment parameters
param environment = 'nonprod'
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
  name: 'exhubnprdaueabootstr-kv'
  resourceGroupName: 'ex-hub-nprd-auea-bootstrap-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000013' // ex-platform-nonproduction-hub-sub
}

param aksClusterExisting = {
  name: 'exmgtnprdaueaaks'
  resourceGroupName: 'ex-management-nprd-auea-aks-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000002' // ex-platform-nonproduction-management-sub
}

// PostgreSQL config
param postgresConfig = {
  administratorLogin: 'admlocal'
  administrators: [
    {
      objectId: '00000000-0000-0000-0000-000000000009'
      principalName: 'pag-azure-root_mg_owner'
      principalType: 'Group'
    }
  ]
  databases: [
    {
      charset: 'UTF8'
      collation: 'en_US.utf8'
      name: 'rsa-iss-ca'
    }
    {
      charset: 'UTF8'
      collation: 'en_US.utf8'
      name: 'ecdsa-iss-ca'
    }
    {
      charset: 'UTF8'
      collation: 'en_US.utf8'
      name: 'rsa-int-ca'
    }
    {
      charset: 'UTF8'
      collation: 'en_US.utf8'
      name: 'ecdsa-int-ca'
    }
  ]
  privateDnsZoneArmResourceId: '/subscriptions/00000000-0000-0000-0000-000000000013/resourceGroups/ex-hub-nprd-auea-private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com'
  delegatedSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/ex-management-nprd-auea-networking-rg/providers/Microsoft.Network/virtualNetworks/ex-mgt-nprd-auea-networking-vnet/subnets/sn-postgres'
  passwordAuth: 'Enabled'
}

// Key vault config
param deployRootCa = false

param keyVaultPrivateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000013/resourceGroups/ex-hub-nprd-auea-private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
    ]
    service: 'vault'
    subnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/ex-management-nprd-auea-networking-rg/providers/Microsoft.Network/virtualNetworks/ex-mgt-nprd-auea-networking-vnet/subnets/sn-pki-keyvaults'
  }
]

param keyVaultRoleAssignments = [
  {
    roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
    principalId: '00000000-0000-0000-0000-000000000030' // spn-ex-nonprod-sub-management-Platform-azp
  }
]
