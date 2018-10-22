[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoIdUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force

InModuleScope CosmosDB {
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
    $script:testDocument1 = 'testDocument1'
    $script:testDocument2 = 'testDocument2'
    $script:testDocumentBody = 'testDocumentBody'
    $script:testPartitionKey = 'testPartitionKey'
    $script:testHeaders = @{
        'x-ms-continuation' = 'test'
    }
    $script:testJsonMulti = @'
    {
        "_rId": "d9RzAJRFKgw=",
        "Documents": [
          {
            "Id": "testDocument1",
            "content": "testDocumentBody",
            "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
            "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
            "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
            "_ts": 1459216987,
            "_attachments": "attachments/"
          },
          {
            "Id": "testDocument2",
            "content": "testDocumentBody",
            "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
            "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
            "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
            "_ts": 1459216987,
            "_attachments": "attachments/"
          }
        ],
        "_count": 2
    }
'@
    $script:testGetDocumentResultMulti = @{
        Content = $script:testJsonMulti
        Headers = $script:testHeaders
    }
    $script:testJsonSingle = @'
      {
        "Id": "testDocument1",
        "content": "testDocumentBody",
        "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
        "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
        "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
        "_ts": 1459216987,
        "_attachments": "attachments/"
      }
'@
    $script:testGetDocumentResultSingle = @{
        Content = $script:testJsonSingle
        Headers = $script:testHeaders
    }

    Describe 'Get-CosmosDbDocumentResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocumentResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbDocumentResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                }

                { $script:result = Get-CosmosDbDocumentResourcePath @getCosmosDbDocumentResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/docs/{2}' -f $script:testDatabase, $script:testCollection, $script:testDocument1)
            }
        }
    }

    Describe 'Get-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no Id but with header parameters' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context             = $script:testContext
                    CollectionId        = $script:testCollection
                    MaxItemCount        = 5
                    ContinuationToken   = 'token'
                    ConsistencyLevel    = 'Strong'
                    SessionToken        = 'session'
                    PartitionKeyRangeId = 'partition'
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testDocument1
                $script:result[1].id | Should -Be $script:testDocument2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and no Id with headers returned' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                [ref] $script:resultHeaders = @{}
                $getCosmosDbDocumentParameters = @{
                    Context       = $script:testContext
                    CollectionId  = $script:testCollection
                    ResultHeaders = $script:resultHeaders
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testDocument1
                $script:result[1].id | Should -Be $script:testDocument2
                $script:resultHeaders.Value.'x-ms-continuation' | Should -Be 'test'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Key' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1) -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    PartitionKey = $script:testPartitionKey
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Encoding is UTF-8' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                $ResourceType -eq 'docs' -and `
                $Encoding -eq 'UTF-8'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                    Encoding     = 'UTF-8'
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Key' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                    PartitionKey = $script:testPartitionKey
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Delete' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                }

                { $script:result = Remove-CosmosDbDocument @removeCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Delete' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1) -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    PartitionKey = $script:testPartitionKey
                }

                { $script:result = Remove-CosmosDbDocument @removeCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    PartitionKey = $script:testPartitionKey
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Encoding is UTF-8' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                $ResourceType -eq 'docs' -and `
                $Encoding -eq 'UTF-8'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    Encoding     = 'UTF-8'
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }
}
