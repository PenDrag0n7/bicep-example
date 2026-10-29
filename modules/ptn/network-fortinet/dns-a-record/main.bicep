
@description('Required. The name of the private DNS Zone to create the record in.')
param privateDnsZone string

@description('Required. The hostname of the resource for the A record.')
param hostName string

@description('Required. The IPV4 address of the resource for the A record.')
param ipv4Address string

@description('Optional. The DNS TTL for the record.')
param aRecordTtl int = 3600

resource privateDNsZoneExisting 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZone
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: hostName
  parent: privateDNsZoneExisting
  properties: {
    aRecords: [
      {
        ipv4Address: ipv4Address
      }
    ]
    ttl: aRecordTtl
  }
}
