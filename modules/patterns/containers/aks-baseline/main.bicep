// Target scope is to deploy to subscription, as resources are deployed to a resource group.
targetScope = 'subscription'

// =========================
// Parameters test
// =========================


@description('Required. Name of resources that will be created to host the pattern resources.')
param namePrefix string

@description('Required. Azure location to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Required. The name of the resource group that will contain the AKS cluster.')
param resourceGroupName string

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

@description('Optional. ACR Configuration')
param containerRegistryExisting lookupType?

@description('Required. Virtual Network Configuration for AKS Cluster')
param vnetExisting vnetSubnetType

@description('Required. AKS Configuration')
param aksConfig aksConfigType

@description('Required. Deploy AKS KeyVault')
param keyVaultConfig keyVaultType?

@description('Required. Private DNS Zone Configuration')
param privateDnsZoneExisting privateDnsZoneExistingType?

@description('Required. Diagnostic settings for the AKS')
param diagnosticSettings diagnosticSettingsType?

//================================
// Resource Group
//================================

@description('Resource Group')
resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  tags: tags
  location: location
}

//================================
// Existing Resources
//================================

//DNS Zones
resource keyVaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (privateDnsZoneExisting != null) {
  scope: resourceGroup(
    privateDnsZoneExisting.?privateDnsSubscriptionId ?? subscription().subscriptionId,
    privateDnsZoneExisting.?resourceGroupName ?? ''
  )
  name: 'privatelink.vaultcore.azure.net'
}

resource aksDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (privateDnsZoneExisting != null) {
  scope: resourceGroup(
    privateDnsZoneExisting.?privateDnsSubscriptionId ?? subscription().subscriptionId,
    privateDnsZoneExisting.?resourceGroupName ?? ''
  )
  name: toLower('privatelink.${location}.azmk8s.io')
}

// Vnet Lookup
resource aksVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  scope: resourceGroup(vnetExisting.resourceGroup)
  name: vnetExisting.vnetName
}

var aksNodeSubnetId = '${aksVnet.id}/subnets/${vnetExisting.nodePoolSubnet}'
var aksPodSubnetId = '${aksVnet.id}/subnets/${vnetExisting.podSubnet}'
var aksKeyVaultSubnetId = '${aksVnet.id}/subnets/${vnetExisting.?keyVaultSubnet}'

//================================
// User Assigned Identity
//================================

@description('AKS User Managed Identity')
module aksUserManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  scope: aksResourceGroup
  name: '${deployment().name}-system-uai'
  params: {
    name: aksConfig.?userManagedIdentityName ?? '${namePrefix}-system-uai'
    location: location
    enableTelemetry: false
  }
}

//================================
// AKS RBAC Assignments
//================================

module rbac './rbac/main.bicep' = {
  name: '${deployment().name}-rbac-aks'
  scope: subscription()
  params: {
    userAssigedPrincipalId: aksUserManagedIdentity.outputs.principalId
    vnetResourceGroup: vnetExisting.resourceGroup

    // ACR
    containerRegistryName: containerRegistryExisting.?name ?? ''
    acrResourceGroup: containerRegistryExisting.?resourceGroup ?? ''
    acrSubscriptionId: containerRegistryExisting.?subscriptionId ?? subscription().subscriptionId

    // Private DNS
    aksPrivateDnsResourceGroup: privateDnsZoneExisting.?resourceGroupName ?? ''
    aksPrivateDnsName: aksDnsZone.?name ?? ''
    aksPrivateDnsSubscriptionId: privateDnsZoneExisting.?privateDnsSubscriptionId ?? subscription().subscriptionId
  }
}

//================================
// AKS Cluster
//================================

@description('AKS Cluster')
module aks 'br/public:avm/res/container-service/managed-cluster:0.1.6' = {
  name: '${deployment().name}-cluster'
  scope: aksResourceGroup
  params: {
    name: replace(namePrefix, '-', '')
    location: location
    nodeResourceGroup: '${resourceGroupName}-nodes'

    kubernetesVersion: aksConfig.kubernetesVersion
    autoUpgradeProfileUpgradeChannel: aksConfig.?autoUpgradeProfileUpgradeChannel == 'stable' ? 'stable' : 'none'

    // Managed Identity for Kubernetes
    managedIdentities: {
      userAssignedResourcesIds: [
        aksUserManagedIdentity.outputs.resourceId
      ]
    }

    // Enable Azure RBAC
    enableRBAC: true
    aadProfileAdminGroupObjectIDs: aksConfig.?aadProfileAdminGroupObjectIDs ?? []
    roleAssignments: aksConfig.?roleAssignments

    // Provider Config
    enableOidcIssuerProfile: true
    enableWorkloadIdentity: true
    enableKeyvaultSecretsProvider: true

    omsAgentEnabled: true
    monitoringWorkspaceId: diagnosticSettings.?workspaceResourceId
    disableLocalAccounts: true
    enableAzureDefender: diagnosticSettings.?workspaceResourceId == null ? false : true

    //Enable Storage CSI
    enableStorageProfileBlobCSIDriver: true
    enableStorageProfileDiskCSIDriver: true
    enableStorageProfileFileCSIDriver: true
    enableStorageProfileSnapshotController: true

    //Private Cluster Config
    authorizedIPRanges: aksConfig.?authorizedIPRanges ?? []
    enablePrivateCluster: aksConfig.?enablePrivateCluster ?? false
    privateDNSZone: aksConfig.?enablePrivateCluster == true ? aksDnsZone.id : null
    disableRunCommand: false

    networkPlugin: 'azure'
    networkPolicy: aksConfig.?networkPolicy == 'calico' ? 'calico' : 'azure'
    skuTier: aksConfig.?skuTier == 'Premium' ? 'Premium' : 'Standard'
    serviceCidr: aksConfig.?serviceCidr ?? '172.16.0.0/16'
    dnsServiceIP: aksConfig.?dnsServiceIP ?? '172.16.0.128'
    outboundType: aksConfig.?outboundType ?? 'loadBalancer'

    diagnosticSettings: empty(diagnosticSettings) ? [] : [
          {
            name: diagnosticSettings.?name ?? 'aks-diagnostics'
            workspaceResourceId: diagnosticSettings.?workspaceResourceId
            logAnalyticsDestinationType: 'AzureDiagnostics'
            logCategoriesAndGroups: [
              {
                category: 'kube-apiserver'
              }
              {
                category: 'kube-controller-manager'
              }
              {
                category: 'kube-scheduler'
              }
              {
                category: 'cluster-autoscaler'
              }
            ]
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
          }
        ]

    agentPools: [
      for (pool, i) in aksConfig.?userNodePools ?? []: {
        availabilityZones: pool.?availabilityZones ?? []
        vnetSubnetID: aksNodeSubnetId
        podSubnetId: aksPodSubnetId
        type: 'VirtualMachineScaleSets'
        vmSize: pool.?vmSize ?? 'Standard_DS2_v2'

        // AutoScaling
        enableAutoScaling: pool.?enableAutoScaling ?? false
        count: pool.?enableAutoScaling == true ? pool.?count : null
        maxCount: pool.?enableAutoScaling == true ? pool.?maxCount : null
        minCount: pool.?enableAutoScaling == true ? pool.?minCount : null
        maxPods: pool.?maxPods ?? 60

        name: pool.name
        nodeLabels: pool.?nodeLabels ?? {}
        osDiskType: 'Ephemeral'
        osDiskSizeGB: pool.?osDiskSizeGB ?? 60
        osType: pool.?osType ?? 'Linux'
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        enableFIPS: pool.?enableFIPS ?? true
      }
    ]

    primaryAgentPoolProfile: [
      {
        availabilityZones: aksConfig.?systemNodePool.?availabilityZones ?? []
        vnetSubnetID: aksNodeSubnetId
        podSubnetId: aksPodSubnetId
        type: 'VirtualMachineScaleSets'
        vmSize: aksConfig.?systemNodePool.?vmSize ?? 'Standard_DS2_v2'

        // AutoScaling
        count: 2
        enableAutoScaling: false
        maxPods: aksConfig.?systemNodePool.?maxPods ?? 60

        mode: 'System'
        name: 'system'
        nodeLabels: {
          nodelabel: 'system'
        }
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
        osDiskType: 'Ephemeral'
        osDiskSizeGB: aksConfig.?systemNodePool.?osDiskSizeGB ?? 60
        osType: 'Linux'
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        enableFIPS: aksConfig.?systemNodePool.?enableFIPS ?? true
      }
    ]
    enableTelemetry: false
    tags: tags
  }
  dependsOn: [
    rbac
  ]
}

//===========================
// AKS Key Vault
//===========================

module keyVault 'br/public:avm/res/key-vault/vault:0.4.0' = if (keyVaultConfig.?enable == true) {
  name: '${deployment().name}-aks-kv'
  scope: aksResourceGroup
  params: {
    name: '${replace(namePrefix,'-','')}-kv'
    tags: tags
    enableTelemetry: false
    enableRbacAuthorization: true
    enablePurgeProtection: keyVaultConfig.?enablePurgeProtection ?? false
    sku: keyVaultConfig.?sku ?? 'standard'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
        principalId: aksUserManagedIdentity.outputs.principalId
      }
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
        principalId: aks.outputs.kubeletIdentityObjectId
      }
    ]
    privateEndpoints: [
      {
        name: '${replace(namePrefix,'-','')}-kv-pep'
        subnetResourceId: aksKeyVaultSubnetId
        service: 'vault'
        privateDnsZoneResourceIds: [
          keyVaultDnsZone.id
        ]
      }
    ]
  }
}

//=============================
// RBAC for ACR Pull
//=============================

module acrPullRBAC './rbac/container-registry/main.bicep' = if (containerRegistryExisting != null) {
  name: '${deployment().name}-rbac-acr'
  scope: resourceGroup(
    containerRegistryExisting.?subscriptionId ?? subscription().subscriptionId,
    containerRegistryExisting.?resourceGroup ?? ''
  )
  params: {
    containerRegistryName: containerRegistryExisting.?name ?? ''
    principalId: aks.outputs.kubeletIdentityObjectId
    roleId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // ACR Pull
  }
}

//=============================
// External DNS Federated User
//=============================

@description('External DNS Federated User')
module aksExternalDNS 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = if (privateDnsZoneExisting != null) {
  scope: aksResourceGroup
  name: '${namePrefix}-external-dns-uai'
  params: {
    name: '${namePrefix}-external-dns-uai'
    location: location
    federatedIdentityCredentials: [
      {
        name: '${namePrefix}-external-dns'
        issuer: aks.outputs.oidcIssuerUrl
        subject: 'system:serviceaccount:external-dns:external-dns'
        audiences: ['api://AzureADTokenExchange']
      }
    ]
  }
}

//=============================
// RBAC for External DNS
//=============================

@description('RBAC for External DNS')
module externalDnsRBAC '../../../resources/authorization/role-assignments/main.bicep' = if (privateDnsZoneExisting != null) {
  name: '${deployment().name}-rbac-dnsZoneContributor'
  scope: resourceGroup(
    privateDnsZoneExisting.?privateDnsSubscriptionId ?? subscription().subscriptionId,
    privateDnsZoneExisting.?resourceGroupName ?? ''
  )
  params: {
    roleAssignment: {
      principalId: aksExternalDNS.outputs.principalId
      roleDefinitionName: 'Private DNS Zone Contributor'
    }
  }
}

//======================
// Type Definitions
//======================

type vnetSubnetType = {
  @description('Required. Name of the virtual network for AKS.')
  vnetName: string

  @description('Required. Resource Group of the virtual network for AKS.')
  resourceGroup: string

  @description('Required. Name of the subnet for system nodes.')
  nodePoolSubnet: string

  @description('Required. Name of the subnet for pods.')
  podSubnet: string

  @description('Optinal. Name of the subnet for key vault.')
  keyVaultSubnet: string?
}

type lookupType = {
  @description('Name of the resource.')
  name: string

  @description('Resource Group of the resource.')
  resourceGroup: string

  @description('Optional. Subscription ID of the resource.')
  subscriptionId: string?
}

type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?
}

type aksConfigType = {
  @description('Optional. Name of the AKS cluster.')
  name: string?

  @description('Optional. Role Assignments for the AKS Cluster.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. AAD Profile Admin Group Object IDs')
  aadProfileAdminGroupObjectIDs: string[]?

  @description('Optional. Service CIDR of the AKS cluster.')
  serviceCidr: string?

  @description('Optional. DNS Service IP of the AKS cluster.')
  dnsServiceIP: string?

  @description('Optional. User Managed Identity Name')
  userManagedIdentityName: string?

  @description('Optional. Specifies outbound (egress) routing method.')
  outboundType: ('loadBalancer' | 'userDefinedRouting' | 'managedNATGateway' | 'userAssignedNATGateway')?

  @description('Optional. Resource Group of the AKS cluster.')
  resourceGroup: string?

  @description('Kubernetes version to use for the AKS cluster.')
  kubernetesVersion: string

  @description('Optional. Kubernetes API server authorized IP ranges')
  authorizedIPRanges: array?

  @description('Optional. Network policy to use for the AKS cluster.')
  networkPolicy: string?

  @description('Optional. SKU tier of the AKS cluster.')
  skuTier: string?

  @description('Optional. Auto upgrade profile upgrade channel of the AKS cluster.')
  autoUpgradeProfileUpgradeChannel: string?

  @description('Optional. Enable Private Cluster')
  enablePrivateCluster: bool?

  @description('Optional. AKS Node User Pool Configuration')
  userNodePools: userNodePool[]?

  @description('Optional. AKS Node System Pool Configuration')
  systemNodePool: systemNodePool?
}

type keyVaultType = {
  @description('Optional. Whether the key vault is enabled.')
  enable: bool?

  @description('Optional. The resource group of the key vault.')
  resourceGroup: string?

  @description('Optional. The SKU of the key vault.')
  sku: ('standard' | 'premium')?

  @description('Optional. Enable purge protection for the key vault.')
  enablePurgeProtection: bool?
}

type diagnosticSettingsType = {
  @description('Optinal. The name of the diagnostic setting.')
  name: string?

  @description('Required. The resource ID of the Log Analytics workspace to send diagnostic data to.')
  workspaceResourceId: string
}

type privateDnsZoneExistingType = {
  @description('Required. The name of the private DNS zone.')
  resourceGroupName: string
  @description('Optional. The subscription ID of the private DNS zone.')
  privateDnsSubscriptionId: string?
}

type systemNodePool = {
  @description('Required. The name of the agent pool.')
  name: string?

  @description('Optional. Whether to enable FIPS for the agent pool.')
  enableFIPS: bool?

  @description('Optional. The availability zones of the agent pool.')
  availabilityZones: string[]?

  @description('Optional. The maximum number of pods that can run on a node.')
  maxPods: int?

  @description('Optional. The OS disk size in GB of the agent pool.')
  osDiskSizeGB: int?

  @description('Optional. The VM size of the agent pool.')
  vmSize: string?
}

type userNodePool = {
  @description('Required. The name of the agent pool.')
  name: string

  @description('Optional. The availability zones of the agent pool.')
  availabilityZones: string[]?

  @description('Optional. The number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  count: int?

  @description('Optional. Whether to enable auto-scaling for the agent pool.')
  enableAutoScaling: bool?

  @description('Optional. Whether to enable FIPS for the agent pool.')
  enableFIPS: bool?

  @description('Optional. The maximum number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  maxCount: int?

  @description('Optional. The minimum number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  minCount: int?

  @description('Optional. The maximum number of pods that can run on a node.')
  maxPods: int?

  @description('Optional. The minimum number of pods that can run on a node.')
  minPods: int?

  @description('Optional. The node labels of the agent pool.')
  nodeLabels: object?

  @description('Optional. The node taints of the agent pool.')
  nodeTaints: string[]?

  @description('Optional. The Kubernetes version of the agent pool.')
  orchestratorVersion: string?

  @description('Optional. The OS disk size in GB of the agent pool.')
  osDiskSizeGB: int?

  @description('Optional. The OS disk type of the agent pool.')
  osDiskType: string?

  @description('Optional. The OS SKU of the agent pool.')
  osSku: string?

  @description('Optional. The OS type of the agent pool.')
  osType: ('Linux' | 'Windows')?

  @description('Optional. The VM size of the agent pool.')
  vmSize: string?
}
