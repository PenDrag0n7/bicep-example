using '../main.bicep'

param function = 'win365cpc'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// =========================
// VNet Prefixes
// =========================

param vnetExisting = {
  name: 'ex-mgt-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-management-nprd-auea-networking-rg'
}

param win365PrincipalId = '00000000-0000-0000-0000-000000000019'
