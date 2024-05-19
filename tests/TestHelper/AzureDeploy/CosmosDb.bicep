param accountName string
param location string = 'East US'
param principalId string
@allowed([
  '00000000-0000-0000-0000-000000000001'// Built-in role 'Azure Cosmos DB Built-in Data Reader'
  '00000000-0000-0000-0000-000000000002' // Built-in role 'Azure Cosmos DB Built-in Data Contributor'
])
param roleDefinitionId string = '00000000-0000-0000-0000-000000000002'

resource account 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  kind: 'GlobalDocumentDB'
  name: accountName
  location: location
  tags: {
    defaultExperience: 'DocumentDB'
  }
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'BoundedStaleness'
      maxIntervalInSeconds: 50
      maxStalenessPrefix: 50
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

var roleAssignmentId = guid(roleDefinitionId, principalId, account.id)

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-02-15-preview' = {
  name: roleAssignmentId
  parent: account
  properties: {
    principalId: principalId
    roleDefinitionId: '/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${account.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
    scope: account.id
  }
}

output endpoint string = account.properties.documentEndpoint
output roleAssignmentId string = roleAssignmentId
