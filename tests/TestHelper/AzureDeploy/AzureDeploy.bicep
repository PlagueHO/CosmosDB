param AccountName string
param Location string = 'East US'
param principalId string
@allowed([
  '00000000-0000-0000-0000-000000000001'// Built-in role 'Azure Cosmos DB Built-in Data Reader'
  '00000000-0000-0000-0000-000000000002' // Built-in role 'Azure Cosmos DB Built-in Data Contributor'
])
param roleDefinitionId string = '00000000-0000-0000-0000-000000000002'

resource account 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  kind: 'GlobalDocumentDB'
  name: AccountName
  location: Location
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
        locationName: Location
        failoverPriority: 0
      }
    ]
  }
  dependsOn: []
}

var roleAssignmentId = guid(roleDefinitionId, principalId, account.id)

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: roleAssignmentId
  parent: account
  properties: {
    principalId: principalId
    roleDefinitionId: reference('/${subscription().id}/resourceGroups/${resourceGroup()}/providers/Microsoft.DocumentDB/databaseAccounts/${AccountName}/sqlRoleDefinitions/${roleDefinitionId}').id
    scope: account.id
  }
}
