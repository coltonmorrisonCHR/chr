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
  'dev'
  'test'
  'prod'
])
param environment string = 'prod'

@description('The Azure region for deployment.')
param azureRegion string = 'centralus'

@description('The Azure region short code for naming convention.')
param azureRegionShortCode string = 'cus'

@description('Deploy Azure VPN Gateway if value is set to true.')
param deployVpnGateway bool = true

@description('The Public IP Address of the customer router.')
param customerNetworkRouterIpAddress string = ''

@description('The IP Address Prefiex of the customer network. e.g. 192.168.0.0/24')
param customerNetworkIpAddressPrefix string = ''

@description('The VPN Connection Shared Key.')
@secure()
param connectionSharedKey string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var networkingResourceGroupName = 'rg-${customerId}o360-${environment}-${azureRegionShortCode}-networking'
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
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
var azureBastionPublicIpAddressName = 'pip-${customerId}o360-${environment}-${azureRegionShortCode}-bastion001'
var azureBastionName = 'bastion-${customerId}o360-${environment}-${azureRegionShortCode}-001'
var vpnGatewayPublicIpAddressName = 'pip-${customerId}o360-${environment}-${azureRegionShortCode}-vpng001'
var localNetworkGatewayName = 'lgw-${customerId}o360-${environment}-${azureRegionShortCode}-vpng001'
var vpnGatewayName = 'vpng-${customerId}o360-${environment}-${azureRegionShortCode}-vpng001'
var connectionName = 'cn-${customerId}o360-${environment}-${azureRegionShortCode}-vpng001'

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
  name: 'virtualNetworkDeployment'
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

// Module - Azure Bastion
//////////////////////////////////////////////////
module azureBastionModule './azure_bastion.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'azureBastionDeployment'
  params: {
    environment: environment
    costCenter: costCenter
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    azureBastionPublicIpAddressName: azureBastionPublicIpAddressName
    azureBastionName: azureBastionName
    azureBastionSubnetId: virtualNetworkModule.outputs.azureBastionSubnetId
  }
}

// Module - Azure Vpn Gateway
//////////////////////////////////////////////////
module azureVpnGatewayModule './azure_vpn_gateway.bicep' = if (deployVpnGateway == true) {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vpnGatewayDeployment'
  params: {
    environment: environment
    costCenter: costCenter
    customerNetworkRouterIpAddress: customerNetworkRouterIpAddress
    customerNetworkIpAddressPrefix: customerNetworkIpAddressPrefix
    connectionSharedKey: connectionSharedKey
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    vpnGatewayPublicIpAddressName: vpnGatewayPublicIpAddressName
    localNetworkGatewayName: localNetworkGatewayName
    vpnGatewayName: vpnGatewayName
    connectionName: connectionName
    gatewaySubnetId: virtualNetworkModule.outputs.gatewaySubnetId
  }
}

// Module - Network Security Group Flow Logs
//////////////////////////////////////////////////
module nsgFlowLogsModule 'azure_network_security_group_flow_logs.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'nsgFlowLogsDeployment'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    nsgFlowLogsStorageAccountId: nsgFlowLogsStorageAccount.id
    nsgConfigurations: networkSecurityGroupsModule.outputs.nsgConfigurations
  }
}
