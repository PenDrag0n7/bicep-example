metadata name = 'Subscription Assignments'
metadata description = 'This Example Internal module will assign an array of subscriptions to a Management Group.'
metadata owner = 'Platform team'

targetScope = 'managementGroup'

// =========================
// Parameters
// =========================

@description('The Management Group Id to assign the subscription to.')
param managementGroupId string

@description('A list of subscriptions to assign to the Management Group.')
param subscriptionIds array

// =========================
// Subscription Assignment
// =========================

resource managementGroup 'Microsoft.Management/managementGroups@2023-04-01' existing = {
  name: managementGroupId
  scope: tenant()
}

resource subscriptionAssignment 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = [for subscriptionId in subscriptionIds: {
  name: subscriptionId
  parent: managementGroup
}]

// asd
