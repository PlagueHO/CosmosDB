targetScope = 'subscription'

param resourceGroupName string
param accountName string
param location string = 'Australia East'
param principalId string
@allowed([
  '00000000-0000-0000-0000-000000000001'// Built-in role 'Azure Cosmos DB Built-in Data Reader'
  '00000000-0000-0000-0000-000000000002' // Built-in role 'Azure Cosmos DB Built-in Data Contributor'
])
param roleDefinitionId string = '00000000-0000-0000-0000-000000000002'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}


module cosmosDb './CosmosDb.bicep' = {
  name: '${resourceGroupName}-cosmosDb'
  scope: rg
  params: {
    accountName: accountName
    location: location
    principalId: principalId
    roleDefinitionId: roleDefinitionId
  }
}

output cosmosDbEndpoint string = cosmosDb.outputs.endpoint
output roleAssignmentId string = cosmosDb.outputs.roleAssignmentId
