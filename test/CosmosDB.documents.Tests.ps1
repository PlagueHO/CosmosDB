[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoIdUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force

InModuleScope CosmosDB {
    # Variables for use in tests
    $script:testAccount = 'testAccount'
    $script:testDatabase = 'testDatabase'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testConnection = [PSCustomObject] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testDocument = 'testDocument'
    $script:testDocumentBody = 'testDocumentBody'
    $script:testJson = @'
    {
        "_rId": "d9RzAJRFKgw=",
        "Documents": [
          {
            "Id": "testDocument",
            "content": "testDocumentBody",
            "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
            "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
            "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
            "_ts": 1459216987,
            "_attachments": "attachments/"
          }
        ],
        "_count": 1
    }
'@
    $script:testHeaders = @{
        'x-ms-continuation' = 'test'
    }

    Describe 'Get-CosmosDbDocumentResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocumentResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbDocumentResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument
                }

                { $script:result = Get-CosmosDbDocumentResourcePath @getCosmosDbDocumentResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/docs/{2}' -f $script:testDatabase, $script:testCollection, $script:testDocument)
            }
        }
    }

    Describe 'Get-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no Id but with header parameters' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' } `
                -MockWith {
                @{
                    Content = $script:testJson
                }
            }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Connection          = $script:testConnection
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
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and no Id with headers returned' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' } `
                -MockWith {
                @{
                    Content = $script:testJson
                    Headers = $script:testHeaders
                }
            }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
                $script:result.Headers.'x-ms-continuation' | Should -Be 'test'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' -and $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'docs' -and $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'docs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'docs' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'docs' -and $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbDocumentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument
                }

                { $script:result = Remove-CosmosDbDocument @removeCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'docs' -and $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'docs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument
                    DocumentBody = $script:testDocumentBody
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'docs' } `
                    -Exactly -Times 1
            }
        }
    }
}
