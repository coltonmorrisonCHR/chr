// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param environment string

@description('The SL Project Code.')
param costCenter string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

param virtualNetworkName string
param virtualnetworkPrefix string
param applicationSubnetName string
param applicationSubnetPrefix string
param rdsSubnetName string
param rdsSubnetPrefix string
param webSubnetName string
param webSubnetPrefix string
param dataSubnetName string
param dataSubnetPrefix string
param addsSubnetName string
param addsSubnetPrefix string
param wapSubnetName string
param wapSubnetPrefix string
param azureBastionSubnetName string
param azureBastionSubnetPrefix string
param applicationGatewaySubnetName string
param applicationGatewaySubnetPrefix string
param gatewaySubnetName string
param gatewaySubnetPrefix string
param applicationSubnetNSGId string
param rdsSubnetNSGId string
param webSubnetNSGId string
param dataSubnetNSGId string
param addsSubnetNSGId string
param wapSubnetNSGId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: environment
  function: 'networking'
  costCenter: costCenter
}

// Resource - Virtual Network
//////////////////////////////////////////////////
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualnetworkPrefix
      ]
    }
    subnets: [
      {
        name: applicationSubnetName
        properties: {
          addressPrefix: applicationSubnetPrefix
          networkSecurityGroup: {
            id: applicationSubnetNSGId
          }
        }
      }
      {
        name: rdsSubnetName
        properties: {
          addressPrefix: rdsSubnetPrefix
          networkSecurityGroup: {
            id: rdsSubnetNSGId
          }
        }
      }
      {
        name: webSubnetName
        properties: {
          addressPrefix: webSubnetPrefix
          networkSecurityGroup: {
            id: webSubnetNSGId
          }
        }
      }
      {
        name: dataSubnetName
        properties: {
          addressPrefix: dataSubnetPrefix
          networkSecurityGroup: {
            id: dataSubnetNSGId
          }
        }
      }
      {
        name: addsSubnetName
        properties: {
          addressPrefix: addsSubnetPrefix
          networkSecurityGroup: {
            id: addsSubnetNSGId
          }
        }
      }
      {
        name: wapSubnetName
        properties: {
          addressPrefix: wapSubnetPrefix
          networkSecurityGroup: {
            id: wapSubnetNSGId
          }
        }
      }
      {
        name: azureBastionSubnetName
        properties: {
          addressPrefix: azureBastionSubnetPrefix
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetPrefix
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

// Resource - Virtual Network - Diagnostic Settings
//////////////////////////////////////////////////
resource virtualNetwork001Diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: virtualNetwork
  name: '${virtualNetwork.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'VMProtectionAlerts'
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

// Outputs
//////////////////////////////////////////////////
output azureBastionSubnetId string = virtualNetwork.properties.subnets[6].id
