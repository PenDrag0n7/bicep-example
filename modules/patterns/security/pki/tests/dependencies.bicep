// General Parameters
@description('Required. The location to deploy to.')
param location string = resourceGroup().location

// Key Vault Parameters
@description('Required. The name of the Key Vault to store SQL credentials. (Globally Unique)')
param sqlKeyVaultName string

// Log Analytics Workspace Parameters
@description('Required. The name of the Log Analytics Workspace to create.')
param logAnalyticsWorkspaceName string

// Virtual Network Parameters
@description('Required. The name of the Virtual Network to create.')
param virtualNetworkName string

@description('Required. The name of the Virtual Network to create.')
param virtualNetworkPrefix string

@description('Required. The name of the Subnet to create in the Virtual Network for use with Key Vault.')
param keyVaultSubnetName string

@description('Required. The name of the Subnet to create in the Virtual Network for use with SQL.')
param sqlSubnetName string

@description('Required. The name of the Subnet to create in the Virtual Network for use with Container App Environment.')
param appSubnetName string

@description('Required. The name of the Subnet to create in the Virtual Network for use with Container App Environment.')
param storageSubnetName string

@description('Required. The name of the Azure Kubernetes Service (AKS) Managed Cluster.')
param aksName string

@description('Required. The name of the Azure Kubernetes Service (AKS) Managed Cluster.')
param uaiName string

// =========================
// Key Vault
// =========================

// Used to store shared secrets used outside of the bicep modules
module sqlVault 'br/public:avm/res/key-vault/vault:0.4.0' = {
  name: sqlKeyVaultName
  params: {
    location: location
    enableTelemetry: false
    name: sqlKeyVaultName
    sku: 'standard'
    enableRbacAuthorization: true
    secrets: {
      secureList: [
        {
          name: 'postgreSqlAdminPassword-Common'
          value: 'Welcome@12345'
        }
      ]
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
    }
    privateEndpoints: [
      {
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
        service: 'vault'
        privateDnsZoneResourceIds: [
          privateDnsZone[1].outputs.resourceId
        ]
      }
    ]
  }
}

// =========================
// Virtual Network
// =========================

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.5' = {
  name: '${deployment().name}-vnet'
  params: {
    location: location
    name: virtualNetworkName
    enableTelemetry: false
    addressPrefixes: [virtualNetworkPrefix]
    subnets: [
      {
        name: sqlSubnetName
        addressPrefix: cidrSubnet(virtualNetworkPrefix, 24, 0)
        privateEndpointNetworkPolicies: 'Disabled'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
        ]
        delegations: [
          {
            name: 'Microsoft.DBforPostgreSQL.flexibleServers'
            properties: {
              serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
            }
          }
        ]
      }
      {
        name: keyVaultSubnetName
        addressPrefix: cidrSubnet(virtualNetworkPrefix, 24, 1)
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: appSubnetName
        addressPrefix: cidrSubnet(virtualNetworkPrefix, 24, 2)
        privateEndpointNetworkPolicies: 'Disabled'
        delegations: [
          {
            name: 'Microsoft.App.environments'
            properties: {
              serviceName: 'Microsoft.App/environments'
            }
          }
        ]
      }
      {
        name: storageSubnetName
        addressPrefix: cidrSubnet(virtualNetworkPrefix, 24, 3)
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}

// =========================
// Private DNS Zones
// =========================

var privateDNSZones = [
  'privatelink.postgres.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.file.core.windows.net'
  'auea.prod.example.com'
  'prod.example.com'
]

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.5' = [
  for (zone, index) in privateDNSZones: {
    name: '${deployment().name}-prvDns-${index}'
    params: {
      location: 'global'
      name: zone
      enableTelemetry: false
      virtualNetworkLinks: [
        {
          name: '${virtualNetwork.name}-vnetlink'
          virtualNetworkResourceId: virtualNetwork.outputs.resourceId
          registrationEnabled: false
          location: 'global'
        }
      ]
    }
  }
]

// =========================
// Log Analytics
// =========================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

// =========================
// AKS
// =========================

module aks 'br/public:avm/res/container-service/managed-cluster:0.1.7' = {
  name: '${deployment().name}-aks'
  params: {
    location: location
    name: aksName
    enableTelemetry: false
    enableOidcIssuerProfile: true
    managedIdentities: {
      systemAssigned: true
    }
    primaryAgentPoolProfile: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        mode: 'System'
      }
    ]
  }
}

// =========================
// User Assigned Identities
// =========================

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uaiName
  location: location
}

// =========================
// Outputs
// =========================

@description('The resource ID of the created Virtual Network Subnet for SQL.')
output sqlSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[0]

@description('The resource ID of the created Virtual Network Subnet for Key Vaults.')
output keyVaultSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[1]

@description('The resource ID of the created Virtual Network Subnet for App Container Environment.')
output appSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[2]

@description('The resource ID of the created Virtual Network Subnet for Storage Account.')
output storageSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[3]

@description('The resource ID of the created Private DNS Zone for PG.')
output sqlPrivateDNSZoneResourceId string = privateDnsZone[0].outputs.resourceId //sqlPrivateDNSZone.id

@description('The resource ID of the created Key Vault.')
output sqlVaultName string = sqlVault.name

@description('The resource ID of the created Private DNS Zone for Key Vault.')
output keyVaultPrivateDNSZoneResourceId string = privateDnsZone[1].outputs.resourceId //keyVaultPrivateDNSZone.id

@description('The resource ID of the created Private DNS Zone for Storage Account.')
output storagePrivateDNSZoneResourceId string = privateDnsZone[2].outputs.resourceId //StoragePrivateDNSZone.id

@description('The resource ID of the created Log Analytcis Workspace.')
output logAnalyticsResourceID string = logAnalyticsWorkspace.id

@description('The principal ID of the User Assigned Identity.')
output uaiPrincipalId string = uai.properties.principalId
