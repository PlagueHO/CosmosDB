param AccountName string = ''
param Location string = 'East US'
param principalId string = ''

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

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  name: guid('00000000-0000-0000-0000-000000000002', principalId, account.id)
  parent: account
  properties: {
    roleDefinitionId: reference(resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', '2021-10-15', '00000000-0000-0000-0000-000000000002')).id
    principalId: principalId
    scope: account.id
  }
}
