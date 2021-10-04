// Parameters
//////////////////////////////////////////////////
@description('The customer environment type.')
param environment string

@description('The SL Project Code.')
param costCenter string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the virtual network.')
param virtualNetworkName string

@description('The Subnet Prefix (/NN) for the Virtual Network.')
param virtualnetworkPrefix string

@description('The Subnet Name for the App Subnet.')
param applicationSubnetName string

@description('The Subnet Prefix (/NN) for the App Subnet.')
param applicationSubnetPrefix string

@description('The Subnet Name for the RDS Subnet.')
param rdsSubnetName string

@description('The Subnet Prefix (/NN) for the RDS Subnet.')
param rdsSubnetPrefix string

@description('The Subnet Name for the Web Subnet.')
param webSubnetName string

@description('The Subnet Prefix (/NN) for the Web Subnet.')
param webSubnetPrefix string

@description('The Subnet Name for the Data Subnet.')
param dataSubnetName string

@description('The Subnet Prefix (/NN) for the Data Subnet.')
param dataSubnetPrefix string

@description('The Subnet Name for the ADDS Subnet.')
param addsSubnetName string

@description('The Subnet Prefix (/NN) for the ADDS Subnet.')
param addsSubnetPrefix string

@description('The Subnet Name for the WAP Subnet.')
param wapSubnetName string

@description('The Subnet Prefix (/NN) for the WAP Subnet.')
param wapSubnetPrefix string

@description('The Subnet Name for the AzureBastionSubnet.')
param azureBastionSubnetName string

@description('The Resource ID for the AzureBastionSubnet.')
param azureBastionSubnetPrefix string

@description('The Subnet Name for the AppGw Subnet.')
param applicationGatewaySubnetName string

@description('The Subnet Prefix (/NN) for the AppGw Subnet.')
param applicationGatewaySubnetPrefix string

@description('The Subnet Name for the VPN Gateway Subnet.')
param gatewaySubnetName string

@description('The Resource ID for the VPN Gateway Subnet.')
param gatewaySubnetPrefix string

@description('The Resource ID for the App Subnet.')
param applicationSubnetNSGId string

@description('The Resource ID for the RDS Subnet.')
param rdsSubnetNSGId string

@description('The Resource ID for the Web Subnet.')
param webSubnetNSGId string

@description('The Resource ID for the Data Subnet.')
param dataSubnetNSGId string

@description('The Resource ID for the ADDS Subnet.')
param addsSubnetNSGId string

@description('The Resource ID for the WAP Subnet.')
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
output gatewaySubnetId string = virtualNetwork.properties.subnets[8].id
