targetScope = 'subscription'

// =========================
// Parameters
// =========================

param location string = deployment().location
param namePrefix string = 'test-${take(uniqueString(deployment().name, location), 6)}-firewalls'

// =========================
// Deps Resource Group(s)
// =========================

// =========================
// Test - Minimum Params
// =========================

module fortinetStack '../main.bicep' = {
  name: '${namePrefix}-pattern'
  params: {
    location: location
    namePrefix: namePrefix
    tags: {
      Stuff: 'More stuff!'
    }
    vnetExisting: {
      name: 'ex-hub-prod-auea-networking-vnet'
      resourceGroupName: 'ex-hub-prod-auea-networking-rg'
    }
    publicIpPrefixExisting: {
      name: 'ex-hub-prod-auea-networking-pfx'
      resourceGroupName: 'ex-hub-prod-auea-networking-rg'
    }
    keyVaultExisting: {
      name: 'test7tp4s3shared-kv'
      resourceGroupName: 'test-7tp4s3-shared-rg'
    }
    privateDnsZoneExisting: {
      name: 'prod.example.com'
      resourceGroupName: 'ex-hub-prod-auea-private-dns-rg'
      subscriptionId: '00000000-0000-0000-0000-000000000005'
    }
    diagnosticSettings: [
      {
        name: 'fortinet-diagnostics'
        workspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000022/resourceGroups/ex-rg-sec-prd-auea-security-001/providers/Microsoft.OperationalInsights/workspaces/ex-law-sec-prd-auea-sentinel-001'
      }
    ]
    fortiAnalyzerConfig: {
      enabled: true
      vmSize: 'Standard_D8as_v4'
      storageAccountType: 'StandardSSD_LRS'
      osdiskSizeGB: 64
      datadiskSizeGB: 512
      loadBalancerConfig: {
        subnet: 'sn-mgmt'
        IpAddress: '10.64.3.62'
      }
      instanceConfig: [
        {
          name: 'vmprdauefana01'
          availabilityZone: 1
          ipAddresses: {
            mgmt: '10.64.3.11'
          }
        }
        {
          name: 'vmprdauefana02'
          availabilityZone: 2
          ipAddresses: {
            mgmt: '10.64.3.12'
          }
        }
      ]
    }
    fortiAuthenticatorConfig: {
      enabled: true
      vmSize: 'Standard_D8as_v4'
      storageAccountType: 'StandardSSD_LRS'
      osdiskSizeGB: 64
      datadiskSizeGB: 512
      loadBalancerConfig: {
        subnet: 'sn-mgmt'
        IpAddress: '10.64.3.61'
      }
      instanceConfig: [
        {
          name: 'vmprdauefauth01'
          availabilityZone: 1
          ipAddresses: {
            mgmt: '10.64.3.13'
          }
        }
        {
          name: 'vmprdauefauth02'
          availabilityZone: 2
          ipAddresses: {
            mgmt: '10.64.3.14'
          }
        }
      ]
    }
    fortiGateConfig: {
      enabled: true
      // https://docs.fortinet.com/document/fortigate-public-cloud/7.4.0/azure-administration-guide/562841/instance-type-support
      vmSize: 'Standard_DS3_v2'
      storageAccountType: 'StandardSSD_LRS'
      osdiskSizeGB: 64
      datadiskSizeGB: 512
      enableAcceleratedNetworking: true
      instanceConfig: [
        {
          name: 'vmprdauefgate01'
          availabilityZone: 1
          nicConfig: [
            {
              name: 'mgmt'
              ipConfig: [
                {
                  subnet: 'sn-mgmt'
                  IpAddress: '10.64.3.4'
                }
              ]
            }
            {
              name: 'untrust'
              ipConfig: [
                {
                  subnet: 'sn-untrust-fw'
                  IpAddress: '10.64.1.68'
                  publicIp: true
                }
                {
                  subnet: 'sn-untrust-fw'
                  IpAddress: '10.64.1.69'
                  publicIp: true
                }
              ]
            }
            {
              name: 'dmz'
              ipConfig: [
                {
                  subnet: 'sn-dmz'
                  IpAddress: '10.64.1.132'
                  loadBalancerBackendPool: 'dmz-ilb-bp'
                }
              ]
            }
            {
              name: 'trust'
              ipConfig: [
                {
                  subnet: 'sn-trust'
                  IpAddress: '10.64.2.4'
                  loadBalancerBackendPool: 'trust-ilb-bp'
                }
              ]
            }
          ]
        }
        {
          name: 'vmprdauefgate02'
          availabilityZone: 2
          nicConfig: [
            {
              name: 'mgmt'
              ipConfig: [
                {
                  subnet: 'sn-mgmt'
                  IpAddress: '10.64.3.5'
                }
              ]
            }
            {
              name: 'untrust'
              ipConfig: [
                {
                  subnet: 'sn-untrust-fw'
                  IpAddress: '10.64.1.70'
                  publicIp: true
                }
                {
                  subnet: 'sn-untrust-fw'
                  IpAddress: '10.64.1.71'
                  publicIp: true
                }
              ]
            }
            {
              name: 'dmz'
              ipConfig: [
                {
                  subnet: 'sn-dmz'
                  IpAddress: '10.64.1.133'
                  loadBalancerBackendPool: 'dmz-ilb-bp'
                }
              ]
            }
            {
              name: 'trust'
              ipConfig: [
                {
                  subnet: 'sn-trust'
                  IpAddress: '10.64.2.5'
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
          ilbIpAddress: '10.64.2.62'
        }
        {
          name: 'dmz'
          subnet: 'sn-dmz'
          ilbIpAddress: '10.64.1.190'
        }
      ]
    }
    fortiManagerConfig: {
      enabled: true
      vmSize: 'Standard_D4as_v4' // Prod Standard_D8as_v4
      storageAccountType: 'StandardSSD_LRS'
      osdiskSizeGB: 64
      datadiskSizeGB: 512
      instanceConfig: [
        {
          name: 'vmprdauefmgr01'
          availabilityZone: 1
          ipAddresses: {
            mgmt: '10.64.3.8'
          }
        }
        {
          name: 'vmprdauefmgr02'
          availabilityZone: 2
          ipAddresses: {
            mgmt: '10.64.3.9'
          }
        }
      ]
    }
    fortiWebConfig: {
      enabled: true
      vmSize: 'Standard_F4s'
      storageAccountType: 'StandardSSD_LRS'
      osdiskSizeGB: 64
      datadiskSizeGB: 30
      instanceConfig: [
        {
          name: 'vmprdauefweb01'
          availabilityZone: 1
          nicConfig: [
            {
              name: 'mgmt'
              ipAddress: '10.64.3.6'
              subnet: 'sn-mgmt'
            }
            {
              name: 'untrust-waf'
              ipAddress: '10.64.1.4'
              subnet: 'sn-untrust-waf'
              loadBalancerBackendPool: 'fortiweb-elb-bp'
            }
            {
              name: 'dmz'
              ipAddress: '10.64.1.134'
              subnet: 'sn-dmz'
            }
          ]
        }
        {
          name: 'vmprdauefweb02'
          availabilityZone: 2
          nicConfig: [
            {
              name: 'mgmt'
              ipAddress: '10.64.3.7'
              subnet: 'sn-mgmt'
            }
            {
              name: 'untrust-waf'
              ipAddress: '10.64.1.5'
              subnet: 'sn-untrust-waf'
              loadBalancerBackendPool: 'fortiweb-elb-bp'
            }
            {
              name: 'dmz'
              ipAddress: '10.64.1.135'
              subnet: 'sn-dmz'
            }
          ]
        }
      ]
    }
    fortiWebManagerConfig: {
      enabled: true
      name: 'vmprdauefwebmgr01'
      vmSize: 'Standard_D4as_v4'
      storageAccountType: 'StandardSSD_LRS'
      ipAddress: '10.64.3.10'
      vhdBlobUris: {
        osDisk: 'https://examplestorage.blob.core.windows.net/images/boot.vhd'
        dataDisk: 'https://examplestorage.blob.core.windows.net/images/log.vhd'
      }
    }
  }
}
