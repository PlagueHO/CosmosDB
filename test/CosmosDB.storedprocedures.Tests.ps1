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
    $script:testStoredProcedure = 'testStoredProcedure'
    $script:testStoredProcedureBody = 'testStoredProcedureBody'
    $script:testJson = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "StoredProcedures": [{
            "body": "testStoredProcedureBody",
            "id": "testStoredProcedure",
            "_rid": "Sl8fALN4sw4CAAAAAAAAgA==",
            "_ts": 1449681197,
            "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/sprocs\/Sl8fALN4sw4CAAAAAAAAgA==\/",
            "_etag": "\"06003ce1-0000-0000-0000-5668612d0000\""
        }],
        "_count": 1
    }
'@

    Describe 'Get-CosmosDbStoredProcedureResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbStoredProcedureResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure
                }

                { $script:result = Get-CosmosDbStoredProcedureResourcePath @getCosmosDbStoredProcedureResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/sprocs/{2}' -f $script:testDatabase, $script:testCollection, $script:testStoredProcedure)
            }
        }
    }

    Describe 'Get-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'sprocs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbStoredProcedure @getCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'sprocs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'sprocs' -and $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure
                }

                { $script:result = Get-CosmosDbStoredProcedure @getCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'sprocs' -and $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Invoke-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Invoke-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'sprocs' -and $body -eq '["testParameter1","testParameter2"]'} `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $invokeCosmosDbStoredProcedureParameters = @{
                    Connection               = $script:testConnection
                    CollectionId             = $script:testCollection
                    Id                       = $script:testStoredProcedure
                    StoredProcedureParameter = @('testParameter1', 'testParameter2')
                }

                { $script:result = Invoke-CosmosDbStoredProcedure @invokeCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'sprocs' -and $body -eq '["testParameter1","testParameter2"]' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'sprocs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbStoredProcedureParameters = @{
                    Connection          = $script:testConnection
                    CollectionId        = $script:testCollection
                    Id                  = $script:testStoredProcedure
                    StoredProcedureBody = $script:testStoredProcedureBody
                }

                { $script:result = New-CosmosDbStoredProcedure @newCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'sprocs' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'sprocs' -and $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbStoredProcedureParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure
                }

                { $script:result = Remove-CosmosDbStoredProcedure @removeCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'sprocs' -and $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'sprocs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $setCosmosDbStoredProcedureParameters = @{
                    Connection          = $script:testConnection
                    CollectionId        = $script:testCollection
                    Id                  = $script:testStoredProcedure
                    StoredProcedureBody = $script:testStoredProcedureBody
                }

                { $script:result = Set-CosmosDbStoredProcedure @setCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'sprocs' } `
                    -Exactly -Times 1
            }
        }
    }
}
