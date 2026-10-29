using '../main.bicep'

param function = 'firewalls'

// Environment parameters
param environment = 'nonprod'
param location = 'australiaeast'

// Load common config
var common = loadYamlContent('../../../../common.yaml')

// =========================
// Existing Resources
// =========================

param vnetExisting = {
  name: 'ex-hub-nprd-auea-networking-vnet'
  resourceGroupName: 'ex-hub-nprd-auea-networking-rg'
}

param publicIpPrefixExisting = {
  name: 'ex-hub-nprd-auea-networking-pfx'
  resourceGroupName: 'ex-hub-nprd-auea-networking-rg'
}

param keyVaultExisting = {
  name: 'exhubnprdaueabootstr-kv'
  resourceGroupName: 'ex-hub-nprd-auea-bootstrap-rg'
}

param privateDnsZoneExisting =  {
  name: 'nprd.example.com'
  resourceGroupName: 'ex-hub-nprd-auea-private-dns-rg'
  subscriptionId: '00000000-0000-0000-0000-000000000013'
}

param diagnosticSettings = [
  {
    name: '${function}-diagnostics'
    workspaceResourceId: common.diagnosticSettings.workspaceResourceId
  }
]

// =========================
// Config - FortiGate
// =========================

param fortiGateConfig = {
  enabled: true
  // https://docs.fortinet.com/document/fortigate-public-cloud/7.4.0/azure-administration-guide/562841/instance-type-support
  vmSize: 'Standard_DS3_v2'
  storageAccountType: 'StandardSSD_LRS'
  osdiskSizeGB: 64
  datadiskSizeGB: 512
  enableAcceleratedNetworking: true
  instanceConfig: [
    {
      name: 'vmnpdauefgate01'
      availabilityZone: 1
      nicConfig: [
        {
          name: 'mgmt'
          ipConfig: [
            {
              subnet: 'sn-mgmt'
              IpAddress: '10.68.3.4'
            }
          ]
        }
        {
          name: 'untrust'
          ipConfig: [
            {
              subnet: 'sn-untrust-fw'
              IpAddress: '10.68.1.68'
              publicIp: true
            }
            {
              subnet: 'sn-untrust-fw'
              IpAddress: '10.68.1.69'
              publicIp: true
            }
          ]
        }
        {
          name: 'dmz'
          ipConfig: [
            {
              subnet: 'sn-dmz'
              IpAddress: '10.68.1.132'
              loadBalancerBackendPool: 'dmz-ilb-bp'
            }
          ]
        }
        {
          name: 'trust'
          ipConfig: [
            {
              subnet: 'sn-trust'
              IpAddress: '10.68.2.4'
              loadBalancerBackendPool: 'trust-ilb-bp'
            }
          ]
        }
      ]
    }
    {
      name: 'vmnpdauefgate02'
      availabilityZone: 2
      nicConfig: [
        {
          name: 'mgmt'
          ipConfig: [
            {
              subnet: 'sn-mgmt'
              IpAddress: '10.68.3.5'
            }
          ]
        }
        {
          name: 'untrust'
          ipConfig: [
            {
              subnet: 'sn-untrust-fw'
              IpAddress: '10.68.1.70'
              publicIp: true
            }
            {
              subnet: 'sn-untrust-fw'
              IpAddress: '10.68.1.71'
              publicIp: true
            }
          ]
        }
        {
          name: 'dmz'
          ipConfig: [
            {
              subnet: 'sn-dmz'
              IpAddress: '10.68.1.133'
              loadBalancerBackendPool: 'dmz-ilb-bp'
            }
          ]
        }
        {
          name: 'trust'
          ipConfig: [
            {
              subnet: 'sn-trust'
              IpAddress: '10.68.2.5'
              loadBalancerBackendPool: 'trust-ilb-bp'
            }
          ]
        }
      ]
    }
  ]
  loadBalancerZones: [
    {
      name: 'trust'
      subnet: 'sn-trust'
      ilbIpAddress: '10.68.2.62'
    }
    {
      name: 'dmz'
      subnet: 'sn-dmz'
      ilbIpAddress: '10.68.1.190'
    }
  ]
}

// =========================
// Config - FortiWeb
// =========================

param fortiWebConfig = {
  enabled: true
  vmSize: 'Standard_F4s'
  storageAccountType: 'StandardSSD_LRS'
  osdiskSizeGB: 64
  datadiskSizeGB: 30
  instanceConfig: [
    {
      name: 'vmnpdauefweb01'
      availabilityZone: 1
      nicConfig: [
        {
          name: 'mgmt'
          ipAddress: '10.68.3.6'
          subnet: 'sn-mgmt'
        }
        {
          name: 'untrust-waf'
          ipAddress: '10.68.1.4'
          subnet: 'sn-untrust-waf'
          loadBalancerBackendPool: 'fortiweb-elb-bp'
        }
        {
          name: 'dmz'
          ipAddress: '10.68.1.134'
          subnet: 'sn-dmz'
        }
      ]
    }
    {
      name: 'vmnpdauefweb02'
      availabilityZone: 2
      nicConfig: [
        {
          name: 'mgmt'
          ipAddress: '10.68.3.7'
          subnet: 'sn-mgmt'
        }
        {
          name: 'untrust-waf'
          ipAddress: '10.68.1.5'
          subnet: 'sn-untrust-waf'
          loadBalancerBackendPool: 'fortiweb-elb-bp'
        }
        {
          name: 'dmz'
          ipAddress: '10.68.1.135'
          subnet: 'sn-dmz'
        }
      ]
    }
  ]
}
