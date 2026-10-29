targetScope = 'subscription'

@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string = deployment().location

@description('Required. A Name for the Resource Group that will contain the ACR.')
param resourceGroupName string

@description('Required. A Name for the Azure Container Registry.')
param containerRegistryName string

@description('Optional. An array of Entra ID Object ID to Azure Role mappings for RBAC. Defaults to none.')
param registryRoleAssignments array = []

@description('Optional. A list of tags to apply to each deployed resource. Defaults to none.')
param tags object = {}

// =========================
// Resource Group(s)
// =========================

resource registryResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// =========================
// Azure Container Registry
// =========================

module privateRegistry 'br/public:avm/res/container-registry/registry:0.1.0' = {
  scope: registryResourceGroup
  name: '${deployment().name}-acr'
  params: {
    name: containerRegistryName
    enableTelemetry: false
    location: location
    acrAdminUserEnabled: true
    roleAssignments: registryRoleAssignments
    tags: tags
  }
}
