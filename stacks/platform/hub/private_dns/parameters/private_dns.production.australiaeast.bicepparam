using '../main.bicep'

param function = 'private-dns'

// Environment Parameters
param environment = 'production'
param location = 'australiaeast'

// Private DNS resolver config
param dnsResolverInboundEndpointIPAddress = '10.64.2.68'

// Private DNS zone config
param customDnsZoneNames = [
  {
    name: 'example.com'
    registrationEnabled: false
  }
  {
    name: 'prod.example.com'
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
  name: 'ex-hub-prod-auea-networking-vnet'
  resourceGroupName: 'ex-hub-prod-auea-networking-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000029'
}

// DNS forwarding rules
param forwardingRules = [
  {
    name: 'nonproduction'
    domainName: 'nprd.example.com.'
    targetDnsServers: [
      {
        ipAddress: '10.68.2.68'
        port: '53'
      }
    ]
  }
]
