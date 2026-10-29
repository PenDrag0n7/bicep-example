using '../main.bicep'

param function = 'win365cpc'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'

// =========================
// VNet Prefixes
// =========================

param vnetExisting = {
  name: 'ex-mgt-prod-auea-networking-vnet'
  resourceGroupName: 'ex-management-prod-auea-networking-rg'
}

param win365PrincipalId = '00000000-0000-0000-0000-000000000019'
