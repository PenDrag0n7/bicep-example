targetScope = 'managementGroup'

// =========================
// Parameters
// =========================

param name string = 'set-azpolicy'

param allowedLocations array = [
  'australiacentral'
  'australiacentral2'
  'australiaeast'
  'australiasoutheast'
]

// =========================
// Resource Group(s)
// =========================

// Dependency resource group goes here

// =========================
// Dependencies
// =========================

// Dependency resources go here

// =========================
// Test - Minimum Params
// =========================

module patternTestMinimum '../main.bicep' = {
  name: '${deployment().name}-minimum'
  params: {
    name: name
    policies: [
      {
        name: 'allowedLocations'
        id: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c' // 'Allowed locations' built-in policy
        parameters: {
          listOfAllowedLocations: {
            value: allowedLocations
          }
        }
      }
      {
        name: 'allowedLocationsRg'
        id: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988' // 'Allowed locations for resource groups' built-in policy
        parameters: {
          listOfAllowedLocations: {
            value: allowedLocations
          }
        }
      }
    ]
    initiatives: [
      {
        name: 'msCloudSecBenchmark'
        id: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8' // 'Microsoft cloud security benchmark' built-in initiative
      }
      {
        name: 'ausGovIsmProtected'
        id: '/providers/Microsoft.Authorization/policySetDefinitions/27272c0b-c225-4cc3-b8b0-f2534b093077' // '[Preview]: Australian Government ISM PROTECTED' built-in initiative
        parameters: {
          membersToExclude: {
            value: 'admin@example.com' // list of users to be excluded from Windows VM Admins group
          }
          logAnalyticsWorkspaceId: {
            value: '00000000-0000-0000-0000-000000000003' // (need to update to ex LAW id in Security zone when deploying to ex tenant) LAW id for VM agent reporting
          }
          listOfResourceTypes: {
            value: [
              'dynatrace.observability/checknameavailability' // (dummy data for now) list of resource types that should have diag logging enabled
            ]
          }
        }
      }
    ]
  }
}
