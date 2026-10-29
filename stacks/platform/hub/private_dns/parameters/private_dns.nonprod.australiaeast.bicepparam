using '../main.bicep'

param function = 'private-dns'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Private DNS resolver config
param dnsResolverInboundEndpointIPAddress = '10.68.2.68'

// Private DNS zone config
param customDnsZoneNames = [
  {
    name: 'nprd.example.com'
    registrationEnabled: true
  }
]
param privateEndpointDnsZoneNames = [
  'privatelink.australiaeast.azmk8s.io'
  'privatelink.australiasoutheast.azmk8s.io'
  'privatelink.azurecr.io'
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.postgres.database.azure.com'
  'privatelink.vaultcore.azure.net'
]

// Hub virtual network configuration
param vnetExisting = {
  name: 'ex-hub-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-hub-nprd-auea-networking-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000013'
}
