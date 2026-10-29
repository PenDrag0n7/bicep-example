// =========================
// Parameters
// =========================

@description('Required. Log Analytics workspace name used by Sentinel.')
param logAnalyticsWorkspaceName string

@allowed([
  'AzureActiveDirectory'
  'AzureAdvancedThreatProtection'
  'AzureSecurityCenter'
  'MicrosoftCloudAppSecurity'
  'MicrosoftDefenderAdvancedThreatProtection'
  'MicrosoftPurviewInformationProtection'
  'Office365'
  'OfficeATP'
 ])
@description('Optional. Sentinel data connectors. Defaults to "Office365".')
param connector string = 'Office365'

// =========================
// Log Analytics Workspace
// =========================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

// =========================
// Sentinel Connectors
// =========================

resource connectorAzureActiveDirectory 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'AzureActiveDirectory') {
  name: 'AzureActiveDirectory'
  scope: logAnalyticsWorkspace
  kind: 'AzureActiveDirectory'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorAzureATP 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'AzureAdvancedThreatProtection') {
  name: 'AzureAdvancedThreatProtection'
  scope: logAnalyticsWorkspace
  kind: 'AzureAdvancedThreatProtection'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorAzureSecurityCenter 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'AzureSecurityCenter') {
  name: 'AzureSecurityCenter'
  scope: logAnalyticsWorkspace
  kind: 'AzureSecurityCenter'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    subscriptionId: subscription().subscriptionId
  }
}

resource connectorMicrosoftCloudAppSecurity 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'MicrosoftCloudAppSecurity') {
  name: 'MicrosoftCloudAppSecurity'
  scope: logAnalyticsWorkspace
  kind: 'MicrosoftCloudAppSecurity'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
      discoveryLogs: {
        state:  'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorMicrosoftDefenderATP 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'MicrosoftDefenderAdvancedThreatProtection') {
  name: 'MicrosoftDefenderAdvancedThreatProtection'
  scope: logAnalyticsWorkspace
  kind: 'MicrosoftDefenderAdvancedThreatProtection'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorMicrosoftPurviewIP 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'MicrosoftPurviewInformationProtection') {
  name: 'MicrosoftPurviewInformationProtection'
  scope: logAnalyticsWorkspace
  kind: 'MicrosoftPurviewInformationProtection'
  properties: {
    dataTypes:  {
      logs: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorOffice365 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'Office365') {
  name: 'Office365'
  scope: logAnalyticsWorkspace
  kind: 'Office365'
  properties: {
    dataTypes: {
      exchange: {
        state: 'Enabled'
      }
      sharePoint: {
        state: 'Enabled'
      }
      teams: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}

resource connectorOfficeATP 'Microsoft.SecurityInsights/dataConnectors@2023-11-01' = if (connector == 'OfficeATP') {
  name: 'OfficeATP'
  scope: logAnalyticsWorkspace
  kind: 'OfficeATP'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
    tenantId: tenant().tenantId
  }
}
