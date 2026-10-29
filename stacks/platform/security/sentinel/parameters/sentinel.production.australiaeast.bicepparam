
using '../main.bicep'

param function = 'sentinel'

// Environment parameters
param environment = 'production'
param location = 'australiaeast'
param enableEntityAnalytics = false
param enableUeba = false

param logAnalyticsRoleAssignments = [
  {
    principalId: '00000000-0000-0000-0000-000000000009' // pag-azure-root_mg_owner
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000023' // spn-ex-nonprod-sub-core-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000007' // spn-ex-nonprod-sub-hub-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000027' // spn-ex-nonprod-sub-identity-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000030' // spn-ex-nonprod-sub-management-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000011' // spn-ex-prod-sub-core-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000036' // spn-ex-prod-sub-hub-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000035' // spn-ex-prod-sub-identity-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000015' // spn-ex-prod-sub-management-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
  {
    principalId: '00000000-0000-0000-0000-000000000012' // spn-ex-prod-sub-security-Platform-azp
    roleDefinitionIdOrName: 'Log Analytics Contributor'
  }
]
