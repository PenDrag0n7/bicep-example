metadata name = 'Virtual Network Subnets'
metadata description = 'This module deploys a Virtual Network Subnet.'
metadata owner = 'Platform team'

@description('Optional. The Name of the subnet resource.')
param name string

@description('Conditional. The name of the parent virtual network. Required if the template is used in a standalone deployment.')
param virtualNetworkName string

@description('Required. The address prefix for the subnet.')
param addressPrefix string

@description('Optional. The resource ID of the network security group to assign to the subnet.')
param networkSecurityGroupResourceId string = ''

@description('Optional. The resource ID of the route table to assign to the subnet.')
param routeTableResourceId string = ''

@description('Optional. The service endpoints to enable on the subnet.')
param serviceEndpoints array = []

@description('Optional. The delegations to enable on the subnet.')
param delegations array = []

@description('Optional. The resource ID of the NAT Gateway to use for the subnet.')
param natGatewayResourceId string = ''

@description('Optional. enable or disable apply network policies on private endpoint in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
  ''
])
param privateEndpointNetworkPolicies string = ''

@description('Optional. enable or disable apply network policies on private link service in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
  ''
])
param privateLinkServiceNetworkPolicies string = ''

@description('Optional. List of address prefixes for the subnet.')
param addressPrefixes array = []

@description('Optional. Application gateway IP configurations of virtual network resource.')
param applicationGatewayIPConfigurations array = []

@description('Optional. Array of IpAllocation which reference this subnet.')
param ipAllocations array = []

@description('Optional. An array of service endpoint policies.')
param serviceEndpointPolicies array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: name
  parent: virtualNetwork
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: !empty(networkSecurityGroupResourceId) ? {
      id: networkSecurityGroupResourceId
    } : null
    routeTable: !empty(routeTableResourceId) ? {
      id: routeTableResourceId
    } : null
    natGateway: !empty(natGatewayResourceId) ? {
      id: natGatewayResourceId
    } : null
    serviceEndpoints: serviceEndpoints
    delegations: delegations
    privateEndpointNetworkPolicies: !empty(privateEndpointNetworkPolicies) ? any(privateEndpointNetworkPolicies) : null
    privateLinkServiceNetworkPolicies: !empty(privateLinkServiceNetworkPolicies) ? any(privateLinkServiceNetworkPolicies) : null
    addressPrefixes: addressPrefixes
    applicationGatewayIPConfigurations: applicationGatewayIPConfigurations
    ipAllocations: ipAllocations
    serviceEndpointPolicies: serviceEndpointPolicies
  }
}
