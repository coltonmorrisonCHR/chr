// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param customerId string = 'gil'

@description('The SL Project Code.')
param costCenter string = 'INTR-4741'

@description('The deployment environment (e.g. prod, dev, test).')
@allowed([
  'prod'
  'test'
  'stg'
])
param environment string = 'prod'

@description('The Azure region for deployment.')
param azureRegion string = 'centralus'

@description('The Azure region short code for naming convention.')
param azureRegionShortCode string = 'cus'

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var monitorResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-monitor'
var identityResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-identity'
// Resources
var logAnalyticsWorkspaceName = 'log-${customerId}o360-${environment}-${azureRegionShortCode}-001'
var applicationGatewayManagedIdentityName = 'id-${customerId}o360-${environment}-${azureRegionShortCode}-applicationgateway'
var nsgFlowLogsStorageAccountName = replace('${customerId}o360-${environment}-${azureRegionShortCode}nsgflow', '-', '')
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'

// Resource Group - Monitor
//////////////////////////////////////////////////
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: azureRegion
}

// Resource Group - Identity
//////////////////////////////////////////////////
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: azureRegion
}

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// module - indentity
//////////////////////////////////////////////////
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  dependsOn: [
    identityResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
  }
}

// Module - Storage Account Diagnostics
//////////////////////////////////////////////////
module storageAccountDiagnosticsModule './azure_storage_account_diagnostics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountDiagnosticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    nsgFlowLogsStorageAccountName: nsgFlowLogsStorageAccountName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Activity Log
//////////////////////////////////////////////////
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    activityLogDiagnosticSettingsName: activityLogDiagnosticSettingsName
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}
