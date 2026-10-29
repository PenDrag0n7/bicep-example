// =========================
// Parameters
// =========================

// Common parameters
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Optional. A list of tags to be associated with each resource for traceability.')
param tags object = {}

param namePrefix string

// Module specific parameters
@description('Required. Common configuration for the FortiAuthenticator resources.')
param fortiWebConfig object

@description('Required. Instance configuration object.')
param instanceConfig object

@description('Required. Existing Virtual Network that will host the networking resources.')
param vnetExisting object

@description('Required. Virtual Machine admin username, extracted from a zone-centric Key Vault.')
@secure()
param vmAdminUsername string

@description('Required. Virtual Machine admin password, extracted from a zone-centric Key Vault.')
@secure()
param vmAdminPassword string

@description('Optional. Enable Diagnostic Settings for supported resources.')
param diagnosticSettings array = []

// FortiAuthenticator Image Reference
var imageReference = {
  publisher: 'fortinet'
  offer: 'fortinet_fortiweb-vm_v5'
  sku: 'fortinet_fw-vm'
  version: '7.4.0'
}

// =========================
// Virtual NICs
// =========================

module vmNics 'br/public:avm/res/network/network-interface:0.2.4' = [for (nic, i) in instanceConfig.nicConfig: {
  name: '${deployment().name}-nic-${i}'
  params: {
    name: '${instanceConfig.name}-nic-${nic.name}-01'
    enableIPForwarding: i == 0 ? false : true
    enableAcceleratedNetworking: fortiWebConfig.?enableAcceleratedNetworking ?? true
    diagnosticSettings: [for diagnosticSetting in diagnosticSettings: {
        name: diagnosticSetting.name
        storageAccountResourceId: diagnosticSetting.?storageAccountResourceId
        workspaceResourceId: diagnosticSetting.?workspaceResourceId
      }
    ]
    ipConfigurations: [
      {
        name: '${nic.name}-ipconfig-01'
        privateIPAllocationMethod: 'Static'
        privateIPAddressVersion: 'IPv4'
        privateIPAddress: nic.ipAddress
        subnetResourceId: resourceId(subscription().subscriptionId, vnetExisting.resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetExisting.name, nic.subnet)
        loadBalancerBackendAddressPools: !contains(nic,'loadBalancerBackendPool') ? [] : [
          {
            id: resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.Network/loadBalancers/backendAddressPools', '${namePrefix}-fortiweb-elb', '${namePrefix}-${nic.loadBalancerBackendPool}')
          }
        ]
      }
    ]
  }
}]

// =========================
// Virtual Machine
// =========================

resource fortiWebVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: instanceConfig.name
  location: location
  tags: tags
  zones: [
    instanceConfig.availabilityZone
  ]
  plan: {
    name: imageReference.sku
    publisher: imageReference.publisher
    product: imageReference.offer
  }
  properties: {
    hardwareProfile: {
      vmSize: fortiWebConfig.vmSize
    }
    networkProfile: {
      networkInterfaces: [for (nic, i) in instanceConfig.nicConfig: {
          id: vmNics[i].outputs.resourceId
          properties: {
            deleteOption: 'Delete'
            primary: i == 0 ? true : false
          }
        }
      ]
    }
    osProfile: {
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
      computerName: instanceConfig.name
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Detach'
        name: '${instanceConfig.name}-disk-os-01'
        managedDisk: {
          storageAccountType: fortiWebConfig.storageAccountType
        }
      }
      dataDisks: [
        {
          lun: 0
          name: '${instanceConfig.name}-disk-data-01'
          diskSizeGB: fortiWebConfig.datadiskSizeGB
          createOption: 'Empty'
          caching: 'ReadWrite'
          deleteOption: 'Detach'
          managedDisk: {
            storageAccountType: fortiWebConfig.storageAccountType
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
