using '../main.bicep'

param location = 'australiaeast'

param subscriptionHierarchy = [
  {
    displayName: 'ex Tenant Root'
    id: 'root-mg'
    parentId: 'root'
    subscriptionIds: []
  }
  {
    displayName: 'Security Zones'
    id: 'security-mg'
    parentId: 'root-mg'
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000016' // ex-platform-production-security-sub
    ]
  }
  {
    displayName: 'Platform Zones'
    id: 'platform-mg'
    parentId: 'root-mg'
    subscriptionIds: []
  }
  {
    displayName: 'Application Zones'
    id: 'apps-mg'
    parentId: 'root-mg'
    subscriptionIds: []
  }
  {
    displayName: 'Decommissioned'
    id: 'decommissioned-mg'
    parentId: 'root-mg'
    subscriptionIds: []
  }
  {
    displayName: 'Production Platform Zones'
    id: 'platform-prod-mg'
    parentId: 'platform-mg'
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000029' // ex-platform-production-hub-sub
      '00000000-0000-0000-0000-000000000031' // ex-platform-production-identity-sub
    ]
  }
  {
    displayName: 'Non-Production Platform Zones'
    id: 'platform-nonprod-mg'
    parentId: 'platform-mg'
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000013' // ex-platform-nonproduction-hub-sub
      '00000000-0000-0000-0000-000000000017' // ex-platform-nonproduction-identity-sub
    ]
  }
  {
    displayName: 'Production Application Zones'
    id: 'apps-prod-mg'
    parentId: 'apps-mg'
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000004' // ex-application-production-vdi-corp-sub
      '00000000-0000-0000-0000-000000000002' // ex-application-production-vdi-paw-sub
      '00000000-0000-0000-0000-000000000014' // ex-application-production-core-sub
    ]
  }
  {
    displayName: 'Non-Production Application Zones'
    id: 'apps-nonprod-mg'
    parentId: 'apps-mg'
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000026' // ex-application-nonproduction-core-sub
    ]
  }
]
