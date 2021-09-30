// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param environment string

@description('The SL Project Code.')
param costCenter string

param logAnalyticsWorkspaceId string
param applicationSubnetNSGName string
param rdsSubnetNSGName string
param webSubnetNSGName string
param dataSubnetNSGName string
param addsSubnetNSGName string
param wapSubnetNSGName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: environment
  function: 'networking'
  costCenter: costCenter
}

// Resource - Network Security Group - Application Subnet
//////////////////////////////////////////////////
resource applicationSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: applicationSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Application Subnet
//////////////////////////////////////////////////
resource applicationSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationSubnetNSG
  name: '${applicationSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Network Security Group - RDS Subnet
//////////////////////////////////////////////////
resource rdsSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: rdsSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - RDS Subnet
//////////////////////////////////////////////////
resource rdsSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: rdsSubnetNSG
  name: '${rdsSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Network Security Group - Web Subnet
//////////////////////////////////////////////////
resource webSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: webSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'HTTP_Inbound'
        properties: {
          description: 'Allow HTTP Inbound Over Port 9000'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9000'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Resource - Network Security Group - Diagnostic Settings - Web Subnet
//////////////////////////////////////////////////
resource webSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: webSubnetNSG
  name: '${webSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Network Security Group - Data Subnet
//////////////////////////////////////////////////
resource dataSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: dataSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Data Subnet
//////////////////////////////////////////////////
resource dataSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataSubnetNSG
  name: '${dataSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Network Security Group - ADDS Subnet
//////////////////////////////////////////////////
resource addsSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: addsSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - ADDS Subnet
//////////////////////////////////////////////////
resource addsSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: addsSubnetNSG
  name: '${addsSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Network Security Group - WAP Subnet
//////////////////////////////////////////////////
resource wapSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: wapSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - WAP Subnet
//////////////////////////////////////////////////
resource wapSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: wapSubnetNSG
  name: '${wapSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
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
output applicationSubnetNSGId string = applicationSubnetNSG.id
output rdsSubnetNSGId string = rdsSubnetNSG.id
output webSubnetNSGId string = webSubnetNSG.id
output dataSubnetNSGId string = dataSubnetNSG.id
output addsSubnetNSGId string = addsSubnetNSG.id
output wapSubnetNSGId string = wapSubnetNSG.id
output nsgConfigurations array = [
  {
    name: 'applicationSubnet'
    id: applicationSubnetNSG.id
  }
  {
    name: 'rdsSubnet'
    id: rdsSubnetNSG.id
  }
  {
    name: 'webSubnet'
    id: webSubnetNSG.id
  }
  {
    name: 'dataSubnet'
    id: dataSubnetNSG.id
  }
  {
    name: 'addsSubnet'
    id: addsSubnetNSG.id
  }
  {
    name: 'wapSubnet'
    id: wapSubnetNSG.id
  }
]
