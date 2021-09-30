// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param environment string

@description('The SL Project Code.')
param costCenter string

@description('The Azure Active Directory Tenant ID.')
param azureActiveDirectoryTenantID string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Service Principal Name ID of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityPrincipalID string

@description('The name of the Key Vault.')
param keyVaultName string

@description('The admin password secret value.')
@secure()
param adminPassword string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: environment
  function: 'key vault'
  costCenter: costCenter
}

// Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    tenantId: azureActiveDirectoryTenantID
    publicNetworkAccess: 'enabled'
    accessPolicies: [
      {
        objectId: applicationGatewayManagedIdentityPrincipalID
        tenantId: azureActiveDirectoryTenantID
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

// Resource - Key Vault - Diagnostic Settings
//////////////////////////////////////////////////
resource keyVaultDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: '${keyVault.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Key Vault - Secret - Admin Password
//////////////////////////////////////////////////
resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'adminPassword'
  properties: {
    value: adminPassword
  }
}
