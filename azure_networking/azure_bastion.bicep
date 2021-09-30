// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param environment string

@description('The SL Project Code.')
param costCenter string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Azure Bastion Public IP Address.')
param azureBastionPublicIpAddressName string

@description('The name of the Azure Bastion.')
param azureBastionName string

@description('The resource ID of the Azure Bastion Subnet.')
param azureBastionSubnetId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: environment
  function: 'networking'
  costCenter: costCenter
}

// Resource - Public Ip Address - Azure Bastion
//////////////////////////////////////////////////
resource azureBastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: azureBastionPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Public Ip Address - Diagnostic Settings - Azure Bastion
//////////////////////////////////////////////////
resource azureBastionPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastionPublicIpAddress
  name: '${azureBastionPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationReports'
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

// Resource - Azure Bastion
//////////////////////////////////////////////////
resource azureBastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: azureBastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          publicIPAddress: {
            id: azureBastionPublicIpAddress.id
          }
          subnet: {
            id: azureBastionSubnetId
          }
        }
      }
    ]
  }
}

// Resource - Azure Bastion - Diagnostic Settings
//////////////////////////////////////////////////
resource azureBastionDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: azureBastion
  name: '${azureBastion.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'BastionAuditLogs'
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
