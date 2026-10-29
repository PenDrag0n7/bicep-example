targetScope = 'managementGroup'

// =========================
// Parameters
// =========================

// Common parameters

// Module specific parameters - parameters/managementGroups.bicepparam
@description('Required. Specifies the name of the policy assignment. Maximum length is 24 characters for management group scope.')
@maxLength(24)
param name string

@description('Required. Specifies the policy definition(s) or policy set definition being assigned.')
param policies array

@description('Required. Specifies the initiative definition(s) being assigned.')
param initiatives array

// =========================
// Policy Assignment
// =========================

// @batchSize(1) // Added to resolve the parent group dependency issue within loop iteration
module allowedLocationsPolicyAssignment 'br/public:avm/res/authorization/policy-assignment/mg-scope:0.1.0' = [for (policy, i) in policies: {
  name: '${deployment().name}-policies-${i}'
  params: {
    enableTelemetry: false // Disable Microsoft standard telemetry on the deployments
    name: policy.name
    policyDefinitionId: policy.id
    parameters: contains(policy, 'parameters') ? policy.parameters : null
      }
}]

module initiativesAssignment 'br/public:avm/res/authorization/policy-assignment/mg-scope:0.1.0' = [for (initiative, i) in initiatives: {
  name: '${deployment().name}-initiatives-${i}'
  params: {
    enableTelemetry: false // Disable Microsoft standard telemetry on the deployments
    name: initiative.name
    policyDefinitionId: initiative.id
    parameters: contains(initiative, 'parameters') ? initiative.parameters : null
    }
}]
