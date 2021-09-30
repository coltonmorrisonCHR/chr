// Parameters
//////////////////////////////////////////////////
@description('The solution customer identifier.')
param environment string

@description('The SL Project Code.')
param costCenter string

@description('The name of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: environment
  function: 'identity'
  costCenter: costCenter
}

// Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: applicationGatewayManagedIdentityName
  location: location
  tags: tags
}

// Outputs
//////////////////////////////////////////////////
output applicationGatewayManagedIdentityPrincipalID string = applicationGatewayManagedIdentity.properties.principalId
