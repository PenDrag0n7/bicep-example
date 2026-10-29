targetScope = 'resourceGroup'

metadata name = 'Data Collection Rule Associations'
metadata description = 'This module associates a Data Collection Resource with a resource.'
metadata owner = 'Platform team'
metadata reference = 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionruleassociations?pivots=deployment-language-bicep'

@description('Required. The resource ID of the data collection rule that is to be associated.')
param dataCollectionRuleId string

@description('Required. Name of the Virtual Machine Scale Set to associate with the Data Collection Rule.')
param vmssName string

// =========================
// Data Collection Rule Association
// =========================

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' existing = {
  name: vmssName
}

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: '${deployment().name}-syslog-dcra'
  scope: vmss
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}
