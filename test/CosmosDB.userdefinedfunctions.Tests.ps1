[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
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
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testUserDefinedFunction1 = 'testUserDefinedFunction1'
    $script:testUserDefinedFunction2 = 'testUserDefinedFunction2'
    $script:testUserDefinedFunction1Body = 'testUserDefinedFunctionBody'
    $script:testJsonMulti = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "UserDefinedFunctions": [
            {
                "body": "testUserDefinedFunctionBody",
                "id": "testUserDefinedFunction1",
                "_rid": "Sl8fALN4sw4BAAAAAAAAYA==",
                "_ts": 1449688293,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/udfs\/Sl8fALN4sw4BAAAAAAAAYA==\/",
                "_etag": "\"060072e4-0000-0000-0000-56687ce50000\""
            },
            {
                "body": "testUserDefinedFunctionBody",
                "id": "testUserDefinedFunction2",
                "_rid": "Sl8fALN4sw4BAAAAAAAAYA==",
                "_ts": 1449688293,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/udfs\/Sl8fALN4sw4BAAAAAAAAYA==\/",
                "_etag": "\"060072e4-0000-0000-0000-56687ce50000\""
            }
        ],
        "_count": 2
    }
'@
    $script:testJsonSingle = @'
{
    "body": "testUserDefinedFunctionBody",
    "id": "testUserDefinedFunction1",
    "_rid": "Sl8fALN4sw4BAAAAAAAAYA==",
    "_ts": 1449688293,
    "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/udfs\/Sl8fALN4sw4BAAAAAAAAYA==\/",
    "_etag": "\"060072e4-0000-0000-0000-56687ce50000\""
}
'@

    Describe 'Get-CosmosDbUserDefinedFunctionResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserDefinedFunctionResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbUserDefinedFunctionResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testUserDefinedFunction1
                }

                { $script:result = Get-CosmosDbUserDefinedFunctionResourcePath @getCosmosDbUserDefinedFunctionResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/udfs/{2}' -f $script:testDatabase, $script:testCollection, $script:testUserDefinedFunction1)
            }
        }
    }

    Describe 'Get-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonMulti }

            It 'Should not throw exception' {
                $getCosmosDbUserDefinedFunctionParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbUserDefinedFunction @getCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testUserDefinedFunction1
                $script:result[1].id | Should -Be $script:testUserDefinedFunction2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction1) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $getCosmosDbUserDefinedFunctionParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testUserDefinedFunction1
                }

                { $script:result = Get-CosmosDbUserDefinedFunction @getCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUserDefinedFunction1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction1) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $newCosmosDbUserDefinedFunctionParameters = @{
                    Context                 = $script:testContext
                    CollectionId            = $script:testCollection
                    Id                      = $script:testUserDefinedFunction1
                    UserDefinedFunctionBody = $script:testUserDefinedFunction1Body
                }

                { $script:result = New-CosmosDbUserDefinedFunction @newCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUserDefinedFunction1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'udfs' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction1) }

            It 'Should not throw exception' {
                $removeCosmosDbUserDefinedFunctionParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testUserDefinedFunction1
                }

                { $script:result = Remove-CosmosDbUserDefinedFunction @removeCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction1) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $setCosmosDbUserDefinedFunctionParameters = @{
                    Context                 = $script:testContext
                    CollectionId            = $script:testCollection
                    Id                      = $script:testUserDefinedFunction1
                    UserDefinedFunctionBody = $script:testUserDefinedFunction1Body
                }

                { $script:result = Set-CosmosDbUserDefinedFunction @setCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUserDefinedFunction1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'udfs' } `
                    -Exactly -Times 1
            }
        }
    }
}
