@description('Required. The name of the private DNS Zone to create the record in.')
param privateDnsZone string

@description('Required. The alias prefix for the CNAME record.')
param cNameRecord string

@description('Required. The alias for the CNAME record.')
param cNameAlias string

@description('Optional. The DNS TTL for the record.')
param cNameTtl int = 3600

resource cnameRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  name: '${privateDnsZone}/${cNameRecord}'
  properties: {
    ttl: cNameTtl
    cnameRecord: {
      cname: cNameAlias
    }
  }
}
