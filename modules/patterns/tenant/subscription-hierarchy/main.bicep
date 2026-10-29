targetScope = 'managementGroup'

// =========================
// Parameters
// =========================

// Common parameters
@description('Required. Azure region to deploy the resources into. E.g. "australiaeast".')
param location string

@description('Required. Four (4) character client prefix used for naming conventions, tagging, etc.')
param tenant string

// Module specific parameters - parameters/managementGroups.bicepparam
// @description('Required. The target (root) scope for the parent Management Groups.')
// param rootManagementGroup string

@description('''Required. List of arrays of management group objects. Requires "displayName", "id", "parentId" and "subscriptionIds".
Example:
```
  [{
    displayName: 'Platform'
    id: 'mg-platform'
    parentId: 'root'
    subscriptionIds: ['00000000-0000-0000-0000-000000000018']
  }]
''')
param subscriptionHierarchy array

// =========================
// Management Groups
// =========================

// @batchSize(1) // Added to resolve the parent group dependency issue within loop iteration
// module managementGroups 'br/public:avm/res/management/management-group:0.1.1' = [for managementGroup in subscriptionHierarchy: {
//   name: '${deployment().name}-${managementGroup.id}'
//   params: {
//     enableTelemetry: false // Disable Microsoft standard telemetry on the deployments
//     name: '${tenant}-${managementGroup.id}'
//     displayName: managementGroup.displayName
//     // parentId: managementGroup.parentId == 'root' ? rootManagementGroup : '${tenant}-${managementGroup.parentId}'
//     location: location // Required for linting on the Management Group module
//   }
// }]

// module managementGroups 'br/public:avm/res/management/management-group:0.1.1' = {
//   name: '${deployment().name}-test'
//   params: {
//     enableTelemetry: false // Disable Microsoft standard telemetry on the deployments
//     name: 'test-root-mg'
//     displayName: 'Example Test MG'
//     // parentId: managementGroup.parentId == 'root' ? rootManagementGroup : '${tenant}-${managementGroup.parentId}'
//     location: location // Required for linting on the Management Group module
//   }
// }

module mgTesting 'br/public:avm/res/management/management-group:0.1.1' = {
  name: '${deployment().name}-test'
  params: {
    enableTelemetry: false // Disable Microsoft standard telemetry on the deployments
    name: 'test-root-mg'
    displayName: 'Example Test MG'
  }
}

// =========================
// Subscription Assignments
// =========================

// module subscriptionAssignment '../../../resources/management/subscription-assignments/main.bicep' = [for (managementGroup, i) in subscriptionHierarchy: {
//   name: '${deployment().name}-${managementGroup.id}-subs'
//   params: {
//     managementGroupId: '${tenant}-${managementGroup.id}'
//     subscriptionIds: managementGroup.subscriptionIds
//   }
//   dependsOn: [
//     managementGroups[i]
//   ]
// }]
