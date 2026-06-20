[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try {
                Test-ModuleManifest $_.FullName -ErrorAction Stop 
            }
            catch {
                $false 
            } )
    }).BaseName

Import-Module -Name $ProjectName -Force

InModuleScope $ProjectName {
    $testHelperPath = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'TestHelper'
    Import-Module -Name $testHelperPath -Force

    # Variables for use in tests
    $script:testAccount = 'testAccount'
    $script:testDatabase = 'testDatabase'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testPartitionKey = 'testPartitionKey'
    $script:testDocuments = @(
        @{ id = 'doc1'; name = 'Test Document 1'; customerId = $script:testPartitionKey },
        @{ id = 'doc2'; name = 'Test Document 2'; customerId = $script:testPartitionKey }
    )
    $script:testBatchResponseJson = @'
[
  {
    "statusCode": 201,
    "requestCharge": 7.25,
    "eTag": "\"0600fc83-0000-0700-0000-5d9b3f520000\"",
    "resourceBody": {
      "id": "doc1",
      "name": "Test Document 1",
      "customerId": "testPartitionKey",
      "_rid": "d9RzAJRFKgwBAAAAAAAAAA==",
      "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
      "_etag": "\"0600fc83-0000-0700-0000-5d9b3f520000\"",
      "_ts": 1459216987,
      "_attachments": "attachments/"
    }
  },
  {
    "statusCode": 201,
    "requestCharge": 7.25,
    "eTag": "\"0600fc84-0000-0700-0000-5d9b3f530000\"",
    "resourceBody": {
      "id": "doc2",
      "name": "Test Document 2", 
      "customerId": "testPartitionKey",
      "_rid": "d9RzAJRFKgwCAAAAAAAAAA==",
      "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwCAAAAAAAAAA==/",
      "_etag": "\"0600fc84-0000-0700-0000-5d9b3f530000\"",
      "_ts": 1459216988,
      "_attachments": "attachments/"
    }
  }
]
'@
    $script:testBatchResult = @{
        Content = $script:testBatchResponseJson
        Headers = @{ 'x-ms-request-charge' = '14.50' }
    }

    Describe 'New-CosmosDbTransactionalBatch' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbTransactionalBatch -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and documents for Create operation' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq "colls/$script:testCollection/docs" -and `
                    $Headers.'x-ms-cosmos-is-batch-request' -eq $true -and `
                    $Headers.'x-ms-cosmos-batch-atomic' -eq $true -and `
                    $Headers.'x-ms-documentdb-partitionkey' -eq "[`"$script:testPartitionKey`"]"
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context       = $script:testContext
                    CollectionId  = $script:testCollection
                    PartitionKey  = $script:testPartitionKey
                    Documents     = $script:testDocuments
                    OperationType = 'Create'
                    NoAtomic      = $false
                    Verbose       = $true
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result -is [array] | Should -BeTrue
                $script:result.Count | Should -Be 2
                $script:result[0].statusCode | Should -Be 201
                $script:result[1].statusCode | Should -Be 201
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and documents for Upsert operation' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Body -like '*"operationType":"Upsert"*'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context       = $script:testContext
                    CollectionId  = $script:testCollection
                    PartitionKey  = $script:testPartitionKey
                    Documents     = $script:testDocuments
                    OperationType = 'Upsert'
                    NoAtomic      = $false
                    Verbose       = $true
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with Read operation type' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Body -like '*"operationType":"Read"*'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context       = $script:testContext
                    CollectionId  = $script:testCollection
                    PartitionKey  = $script:testPartitionKey
                    Documents     = $script:testDocuments
                    OperationType = 'Read'
                    Verbose       = $true
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks with Read operation' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When NoAtomic is set' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $Headers.'x-ms-cosmos-batch-atomic' -eq $false
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                    NoAtomic     = $true
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks with atomic set to false' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with ReturnJson parameter' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                    ReturnJson   = $true
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should return raw JSON string' {
                $script:result | Should -Be $script:testBatchResponseJson
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with invalid collection id' {
            It 'Should throw exception for invalid collection id' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = 'invalid collection id'
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                }

                { New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Throw
            }
        }

        Context 'When Invoke-CosmosDbRequest throws exception' {
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { throw 'Simulated request exception' }

            It 'Should throw exception when request fails' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                }

                { New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Throw 'Simulated request exception'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When response contains invalid JSON' {
            $script:result = $null
            $testBadJsonResult = @{
                Content = '{ invalid json }'
                Headers = @{ 'x-ms-request-charge' = '1.0' }
            }

            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testBadJsonResult }

            Mock `
                -CommandName New-CosmosDbInvalidOperationException `
                -MockWith { throw 'Invalid JSON conversion' }

            It 'Should throw exception for invalid JSON' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Throw 'Invalid JSON conversion'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName New-CosmosDbInvalidOperationException `
                    -Exactly -Times 1
            }
        }

        Context 'When called with WhatIf parameter' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            $newCosmosDbTransactionalBatchParameters = @{
                Context      = $script:testContext
                CollectionId = $script:testCollection
                PartitionKey = $script:testPartitionKey
                Documents    = $script:testDocuments
                WhatIf       = $true
            }

            It 'Should not throw exception' {
                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should return null when WhatIf is specified' {
                $script:result | Should -BeNullOrEmpty
            }

            It 'Should not call Invoke-CosmosDbRequest when WhatIf is specified' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -Exactly -Times 0
            }
        }

        Context 'When called with default OperationType (no explicit OperationType specified)' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Body -like '*"operationType":"Create"*'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            It 'Should not throw exception with default OperationType' {
                $newCosmosDbTransactionalBatchParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    PartitionKey = $script:testPartitionKey
                    Documents    = $script:testDocuments
                    # No OperationType specified - should default to 'Create'
                }

                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should default to Create operation type when not specified' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with Confirm parameter set to false' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testBatchResult }

            $newCosmosDbTransactionalBatchParameters = @{
                Context      = $script:testContext
                CollectionId = $script:testCollection
                PartitionKey = $script:testPartitionKey
                Documents    = $script:testDocuments
                Confirm      = $false
            }

            It 'Should not throw exception' {
                { $script:result = New-CosmosDbTransactionalBatch @newCosmosDbTransactionalBatchParameters } | Should -Not -Throw
            }

            It 'Should return expected result when Confirm is false' {
                $script:result | Should -HaveCount 2
                $script:result[0].statusCode | Should -Be 201
                $script:result[1].statusCode | Should -Be 201
            }

            It 'Should call Invoke-CosmosDbRequest when Confirm is false' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbTransactionalBatchOperationType' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbTransactionalBatchOperationType -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with batch operations array' {
            $script:result = $null
            $testOperations = @(
                @{ statusCode = 201; resourceBody = @{ id = 'doc1' } },
                @{ statusCode = 201; resourceBody = @{ id = 'doc2' } }
            )

            It 'Should not throw exception' {
                { $script:result = Set-CosmosDbTransactionalBatchOperationType -BatchOperations $testOperations } | Should -Not -Throw
            }

            It 'Should return objects with correct type names' {
                $script:result | Should -HaveCount 2
                $script:result[0].PSObject.TypeNames[0] | Should -Be 'CosmosDB.TransactionalBatchOperation'
                $script:result[1].PSObject.TypeNames[0] | Should -Be 'CosmosDB.TransactionalBatchOperation'
            }

            It 'Should preserve original object data' {
                $script:result[0].statusCode | Should -Be 201
                $script:result[0].resourceBody.id | Should -Be 'doc1'
                $script:result[1].statusCode | Should -Be 201
                $script:result[1].resourceBody.id | Should -Be 'doc2'
            }
        }

        Context 'When called with WhatIf parameter' {
            $script:result = $null
            $testOperations = @(
                @{ statusCode = 201; resourceBody = @{ id = 'doc1' } }
            )

            It 'Should not throw exception' {
                { $script:result = Set-CosmosDbTransactionalBatchOperationType -BatchOperations $testOperations -WhatIf } | Should -Not -Throw
            }

            It 'Should not return null when WhatIf is specified' {
                $script:result | Should -Not -BeNullOrEmpty
            }

            It 'Should not modify objects when WhatIf is specified' {
                $testOperations[0].PSObject.TypeNames[0] | Should -Not -Be 'CosmosDB.TransactionalBatchOperation'
            }
        }
    }
}
