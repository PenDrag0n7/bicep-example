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
param fortiGateConfig object

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

@description('Required. The resource ID of the Public IP prefix to consume the Public IP Addresses from.')
param publicIpPrefixResourceId string

// FortiGate Image Reference
var imageReference = {
  publisher: 'fortinet'
  offer: 'fortinet_fortigate-vm_v5'
  sku: 'fortinet_fg-vm'
  version: '7.4.2'
}

// =========================
// Public IPs
// =========================

// Pivoted to using discrete Public IP Address module due to issue with AVM compute/virtual-machine module around IP Forwarding
module publicIpAddress 'br/public:avm/res/network/public-ip-address:0.4.0' = [for (pip, i) in range(1, 2): {
  name: '${deployment().name}-pip-${i}'
  params: {
    name: '${instanceConfig.name}-untrust-pip-0${i+1}'
    location: location
    diagnosticSettings: [for diagnosticSetting in diagnosticSettings: {
        name: diagnosticSetting.name
        storageAccountResourceId: diagnosticSetting.?storageAccountResourceId
        workspaceResourceId: diagnosticSetting.?workspaceResourceId
      }
    ]
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    publicIpPrefixResourceId: publicIpPrefixResourceId
    tags: tags
    zones: [1, 2, 3]
  }
}]

// =========================
// Virtual NICs
// =========================

// Pivoted to using discrete NIC module due to issue with AVM compute/virtual-machine module around IP Forwarding
module vmNics 'br/public:avm/res/network/network-interface:0.2.4' = [for (nic, i) in instanceConfig.nicConfig: {
  name: '${deployment().name}-nic-${i}'
  params: {
    name: '${instanceConfig.name}-nic-${nic.name}-01'
    enableIPForwarding: nic.name == 'mgmt' ? false : true
    enableAcceleratedNetworking: fortiGateConfig.?enableAcceleratedNetworking ?? true
    diagnosticSettings: [for diagnosticSetting in diagnosticSettings: {
        name: diagnosticSetting.name
        storageAccountResourceId: diagnosticSetting.?storageAccountResourceId
        workspaceResourceId: diagnosticSetting.?workspaceResourceId
      }
    ]
    ipConfigurations: [for (ip, i) in nic.ipConfig: {
      name: '${nic.name}-ipconfig-0${i+1}'
      privateIPAllocationMethod: 'Static'
      privateIPAddressVersion: 'IPv4'
      privateIPAddress: ip.ipAddress
      publicIPAddressResourceId: contains(ip, 'publicIp') ? publicIpAddress[i].outputs.resourceId : null
      subnetResourceId: resourceId(subscription().subscriptionId, vnetExisting.resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetExisting.name, ip.subnet)
      loadBalancerBackendAddressPools: !contains(ip,'loadBalancerBackendPool') ? [] : [
        {
          id: resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.Network/loadBalancers/backendAddressPools', '${namePrefix}-fortigate-ilb', '${namePrefix}-${ip.loadBalancerBackendPool}')
        }
      ]
    }]
  }
}]

// =========================
// Virtual Machine
// =========================

// Pivoted to using virtual machine resource block due to issue with AVM compute/virtual-machine module around IP Forwarding
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
      vmSize: fortiGateConfig.vmSize
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
        name: '${instanceConfig.name}-disk-os-01'
        managedDisk: {
          storageAccountType: fortiGateConfig.storageAccountType
        }
      }
      dataDisks: [
        {
          lun: 0
          name: '${instanceConfig.name}-disk-data-01'
          diskSizeGB: fortiGateConfig.datadiskSizeGB
          createOption: 'Empty'
          deleteOption: 'Detach'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: fortiGateConfig.storageAccountType
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
