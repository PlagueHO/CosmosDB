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
    $script:testConnection = [PSCustomObject] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testUserDefinedFunction = 'testUserDefinedFunction'
    $script:testUserDefinedFunctionBody = 'testUserDefinedFunctionBody'
    $script:testJson = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "UserDefinedFunctions": [{
            "body": "testUserDefinedFunction",
            "id": "simpleTaxUDF",
            "_rid": "Sl8fALN4sw4BAAAAAAAAYA==",
            "_ts": 1449688293,
            "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/udfs\/Sl8fALN4sw4BAAAAAAAAYA==\/",
            "_etag": "\"060072e4-0000-0000-0000-56687ce50000\""
        }],
        "_count": 1
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
                    Id           = $script:testUserDefinedFunction
                }

                { $script:result = Get-CosmosDbUserDefinedFunctionResourcePath @getCosmosDbUserDefinedFunctionResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/udfs/{2}' -f $script:testDatabase, $script:testCollection, $script:testUserDefinedFunction)
            }
        }
    }

    Describe 'Get-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbUserDefinedFunctionParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbUserDefinedFunction @getCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbUserDefinedFunctionParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testUserDefinedFunction
                }

                { $script:result = Get-CosmosDbUserDefinedFunction @getCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbUserDefinedFunctionParameters = @{
                    Connection              = $script:testConnection
                    CollectionId            = $script:testCollection
                    Id                      = $script:testUserDefinedFunction
                    UserDefinedFunctionBody = $script:testUserDefinedFunctionBody
                }

                { $script:result = New-CosmosDbUserDefinedFunction @newCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
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

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbUserDefinedFunctionParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testUserDefinedFunction
                }

                { $script:result = Remove-CosmosDbUserDefinedFunction @removeCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'udfs' -and $ResourcePath -eq ('colls/{0}/udfs/{1}' -f $script:testCollection, $script:testUserDefinedFunction) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbUserDefinedFunction' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbUserDefinedFunction -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'udfs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $setCosmosDbUserDefinedFunctionParameters = @{
                    Connection              = $script:testConnection
                    CollectionId            = $script:testCollection
                    Id                      = $script:testUserDefinedFunction
                    UserDefinedFunctionBody = $script:testUserDefinedFunctionBody
                }

                { $script:result = Set-CosmosDbUserDefinedFunction @setCosmosDbUserDefinedFunctionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
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
