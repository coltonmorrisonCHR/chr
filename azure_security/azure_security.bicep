// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param customerId string = 'jmw'

@description('The SL Project Code.')
param costCenter string = 'INTR-4741'

@description('The deployment environment (e.g. prod, dev, test).')
@allowed([
  'prod'
  'test'
])
param environment string = 'prod'

@description('The Azure region for deployment.')
param azureRegion string = 'eastus'

@description('The Azure region short code for naming convention.')
param azureRegionShortCode string = 'eus'

@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string = '0a08721b-47a1-4712-90cb-c5cb5c314093'

@description('The admin password secret value.')
@secure()
param adminPassword string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var identityResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-identity'
var keyVaultResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-keyvault'
// Resources
var applicationGatewayManagedIdentityName = 'id-${customerId}o360-${environment}-${azureRegionShortCode}-applicationgateway'
var keyVaultName = 'kv-${customerId}o360-${environment}-${azureRegionShortCode}-001'

// Existing Resources
//////////////////////////////////////////////////
// Variables
var monitorResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-monitor'
var logAnalyticsWorkspaceName = 'log-${customerId}o360-${environment}-${azureRegionShortCode}-001'
// Resource - Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Resource Group - Identity
//////////////////////////////////////////////////
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: azureRegion
}

// Resource Group - Key Vault
//////////////////////////////////////////////////
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: azureRegion
}

// Module - Indentity
//////////////////////////////////////////////////
module identityModule './azure_identity.bicep' = {
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

// Module - Key Vault
//////////////////////////////////////////////////
module keyVaultModule './azure_key_vault.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: 'logAnalyticsDeployment'
  dependsOn: [
    keyVaultResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    azureActiveDirectoryTenantID: azureActiveDirectoryTenantID
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    applicationGatewayManagedIdentityPrincipalID: identityModule.outputs.applicationGatewayManagedIdentityPrincipalID
    keyVaultName: keyVaultName
  }
}
