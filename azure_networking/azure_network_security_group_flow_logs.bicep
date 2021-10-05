// Parameters
//////////////////////////////////////////////////
@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the NSG Flow Logs Storage Account.')
param nsgFlowLogsStorageAccountId string

@description('The output from Azure NSG creation Bicep.')
param nsgConfigurations array

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location

// Resource - Network Security Group Flow Logs
resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2020-11-01' = [for nsgConfiguration in nsgConfigurations: {
  name: 'NetworkWatcher_${location}/${nsgConfiguration.name}'
  location: location
  properties: {
    targetResourceId: nsgConfiguration.id
    storageId: nsgFlowLogsStorageAccountId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 10
      }
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
  }
}]
