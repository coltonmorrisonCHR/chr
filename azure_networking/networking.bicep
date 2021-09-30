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

// Existing Resources
//////////////////////////////////////////////////
// Variables
var monitorResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-monitor'
var logAnalyticsWorkspaceName = 'log-${customerId}o360-${environment}-${azureRegionShortCode}-001'
var nsgFlowLogsStorageAccountName = replace('${customerId}o360-${environment}-${azureRegionShortCode}nsgflow', '-', '')
// Resource - Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// Resource - Storage Account - Nsg Flow Logs
resource nsgFlowLogsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: nsgFlowLogsStorageAccountName
}

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var networkingResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-networking'
// Resources
var applicationSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-app'
var rdsSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-rds'
var webSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-web'
var dataSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-data'
var addsSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-adds'
var wapSubnetNSGName = 'nsg-${customerId}o360-${environment}-${azureRegionShortCode}-wap'
var virtualNetworkName = 'vnet-${customerId}o360-${environment}-${azureRegionShortCode}-001'
var virtualnetworkPrefix = '10.100.2.0/24'
var applicationSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-app'
var applicationSubnetPrefix = '10.100.2.0/27'
var rdsSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-rds'
var rdsSubnetPrefix = '10.100.2.32/27'
var webSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-web'
var webSubnetPrefix = '10.100.2.64/28'
var dataSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-data'
var dataSubnetPrefix = '10.100.2.80/28'
var addsSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-adds'
var addsSubnetPrefix = '10.100.2.96/28'
var wapSubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-wap'
var wapSubnetPrefix = '10.100.2.112/28'
var azureBastionSubnetName = 'AzureBastionSubnet'
var azureBastionSubnetPrefix = '10.100.2.128/27'
var applicationGatewaySubnetName = 'snet-${customerId}o360-${environment}-${azureRegionShortCode}-appgw'
var applicationGatewaySubnetPrefix = '10.100.2.232/29'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.100.2.248/29'

// Resource Group - Networking
//////////////////////////////////////////////////
resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: azureRegion
}

// Module - Network Security Groups
//////////////////////////////////////////////////
module networkSecurityGroupsModule './azure_network_security_group.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'networkSecurityGroupsDeployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    applicationSubnetNSGName: applicationSubnetNSGName
    rdsSubnetNSGName: rdsSubnetNSGName
    webSubnetNSGName: webSubnetNSGName
    dataSubnetNSGName: dataSubnetNSGName
    addsSubnetNSGName: addsSubnetNSGName
    wapSubnetNSGName: wapSubnetNSGName
  }
}

// Module - Virtual Network
//////////////////////////////////////////////////
module virtualNetworkModule './azure_virtual_network.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'virtualNetwork001Deployment'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    environment: environment
    costCenter: costCenter
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    virtualNetworkName: virtualNetworkName
    virtualnetworkPrefix: virtualnetworkPrefix
    applicationSubnetName: applicationSubnetName
    applicationSubnetPrefix: applicationSubnetPrefix
    rdsSubnetName: rdsSubnetName
    rdsSubnetPrefix: rdsSubnetPrefix
    webSubnetName: webSubnetName
    webSubnetPrefix: webSubnetPrefix
    dataSubnetName: dataSubnetName
    dataSubnetPrefix: dataSubnetPrefix
    addsSubnetName: addsSubnetName
    addsSubnetPrefix: addsSubnetPrefix
    wapSubnetName: wapSubnetName
    wapSubnetPrefix: wapSubnetPrefix
    azureBastionSubnetName: azureBastionSubnetName
    azureBastionSubnetPrefix: azureBastionSubnetPrefix
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
    applicationSubnetNSGId: networkSecurityGroupsModule.outputs.applicationSubnetNSGId
    rdsSubnetNSGId: networkSecurityGroupsModule.outputs.rdsSubnetNSGId
    webSubnetNSGId: networkSecurityGroupsModule.outputs.webSubnetNSGId
    dataSubnetNSGId: networkSecurityGroupsModule.outputs.dataSubnetNSGId
    addsSubnetNSGId: networkSecurityGroupsModule.outputs.addsSubnetNSGId
    wapSubnetNSGId: networkSecurityGroupsModule.outputs.wapSubnetNSGId
  }
}
