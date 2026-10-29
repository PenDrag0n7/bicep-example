// =========================
// Parameters
// =========================

// Common parameters
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

// Module specific parameters
@description('Required. Configuration object for the Fortigate resources.')
param fortiWebManagerConfig object

@description('Required. Existing Virtual Network that will host the networking resources.')
param vnetExisting object

@description('Required. Virtual Machine admin username, extracted from a zone-centric Key Vault.')
@secure()
param vmAdminUsername string

@description('Required. Virtual Machine admin password, extracted from a zone-centric Key Vault.')
@secure()
param vmAdminPassword string

@description('Required. Virtual Machine image reference Id.')
param virtualMachineImageReferenceId string

@description('Optional. Enable Diagnostic Settings for supported resources.')
param diagnosticSettings array = []

// =========================
// Virtual NIC
// =========================

module vmNetworkInterface 'br/public:avm/res/network/network-interface:0.2.4' =  {
  name: '${deployment().name}-nic'
  params: {
    name: '${fortiWebManagerConfig.name}-nic-mgmt-01'
    enableAcceleratedNetworking: fortiWebManagerConfig.?enableAcceleratedNetworking ?? true
    diagnosticSettings: [for diagnosticSetting in diagnosticSettings: {
        name: diagnosticSetting.name
        storageAccountResourceId: diagnosticSetting.?storageAccountResourceId
        workspaceResourceId: diagnosticSetting.?workspaceResourceId
      }
    ]
    ipConfigurations: [
      {
        name: 'mgmt-ipconfig-01'
        privateIPAllocationMethod: 'Static'
        privateIPAddress: fortiWebManagerConfig.ipAddress
        subnetResourceId: resourceId(subscription().subscriptionId, vnetExisting.resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetExisting.name, 'sn-mgmt')
      }
    ]
  }
}

// =========================
// Virtual Machine
// =========================

resource fortiWebManagerVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: fortiWebManagerConfig.name
  location: location
  tags: tags
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: fortiWebManagerConfig.vmSize
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        id: virtualMachineImageReferenceId
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        name: '${fortiWebManagerConfig.name}-disk-os-01'
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'FromImage'
          diskSizeGB: 50
          name: '${fortiWebManagerConfig.name}-disk-log-01'
        }
      ]
    }
    osProfile: {
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        enableVMAgentPlatformUpdates: false
      }
      allowExtensionOperations: true
      computerName: fortiWebManagerConfig.name
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.outputs.resourceId
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
