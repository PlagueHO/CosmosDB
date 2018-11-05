[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force


InModuleScope CosmosDB {
    $TestHelperPath = "$PSScriptRoot\..\TestHelper"
    Import-Module -Name $TestHelperPath -Force

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
    $script:testStoredProcedure1 = 'testStoredProcedure1'
    $script:testStoredProcedure2 = 'testStoredProcedure2'
    $script:testStoredProcedureBody = 'testStoredProcedureBody'
    $script:testJsonMulti = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "StoredProcedures": [
            {
                "body": "testStoredProcedureBody",
                "id": "testStoredProcedure1",
                "_rid": "Sl8fALN4sw4CAAAAAAAAgA==",
                "_ts": 1449681197,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/sprocs\/Sl8fALN4sw4CAAAAAAAAgA==\/",
                "_etag": "\"06003ce1-0000-0000-0000-5668612d0000\""
            },
            {
                "body": "testStoredProcedureBody",
                "id": "testStoredProcedure2",
                "_rid": "Sl8fALN4sw4CAAAAAAAAgA==",
                "_ts": 1449681197,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/sprocs\/Sl8fALN4sw4CAAAAAAAAgA==\/",
                "_etag": "\"06003ce1-0000-0000-0000-5668612d0000\""
            }
        ],
        "_count": 2
    }
'@
    $script:testGetStoredProcedureResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "body": "testStoredProcedureBody",
    "id": "testStoredProcedure1",
    "_rid": "Sl8fALN4sw4CAAAAAAAAgA==",
    "_ts": 1449681197,
    "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/sprocs\/Sl8fALN4sw4CAAAAAAAAgA==\/",
    "_etag": "\"06003ce1-0000-0000-0000-5668612d0000\""
}
'@
    $script:testGetStoredProcedureResultSingle = @{
        Content = $script:testJsonSingle
    }

    Describe 'Assert-CosmosDbStoredProcedureIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbStoredProcedureIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbStoredProcedureIdValid -Id 'This is a valid stored procedure ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.StoredProcedureIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbStoredProcedureIdValid -Id ('a' * 256)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id containing invalid characters' {
            $testCases = @{ Id = 'a\b' }, @{ Id = 'a/b' }, @{ Id = 'a#b' }, @{ Id = 'a?b' }

            It 'Should throw expected exception when called with "<Id>"' -TestCases $testCases {
                param
                (
                    [System.String]
                    $Id
                )

                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.StoredProcedureIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbStoredProcedureIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.StoredProcedureIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbStoredProcedureIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.StoredProcedureIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbStoredProcedureIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbStoredProcedureResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbStoredProcedureResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure1
                }

                { $script:result = Get-CosmosDbStoredProcedureResourcePath @getCosmosDbStoredProcedureResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/sprocs/{2}' -f $script:testDatabase, $script:testCollection, $script:testStoredProcedure1)
            }
        }
    }

    Describe 'Get-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetStoredProcedureResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbStoredProcedure @getCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testStoredProcedure1
                $script:result[1].id | Should -Be $script:testStoredProcedure2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'sprocs'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetStoredProcedureResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbStoredProcedureParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure1
                }

                { $script:result = Get-CosmosDbStoredProcedure @getCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testStoredProcedure1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'sprocs' -and `
                        $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Invoke-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Invoke-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetStoredProcedureResultSingle }

            It 'Should not throw exception' {
                $invokeCosmosDbStoredProcedureParameters = @{
                    Context                  = $script:testContext
                    CollectionId             = $script:testCollection
                    Id                       = $script:testStoredProcedure1
                    StoredProcedureParameter = @('testParameter1', 'testParameter2')
                }

                { $script:result = Invoke-CosmosDbStoredProcedure @invokeCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testStoredProcedure1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'sprocs' -and `
                        $body -eq '["testParameter1","testParameter2"]'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetStoredProcedureResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbStoredProcedureParameters = @{
                    Context             = $script:testContext
                    CollectionId        = $script:testCollection
                    Id                  = $script:testStoredProcedure1
                    StoredProcedureBody = $script:testStoredProcedureBody
                }

                { $script:result = New-CosmosDbStoredProcedure @newCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testStoredProcedure1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'sprocs'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbStoredProcedureParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testStoredProcedure1
                }

                { $script:result = Remove-CosmosDbStoredProcedure @removeCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'sprocs' -and `
                        $ResourcePath -eq ('colls/{0}/sprocs/{1}' -f $script:testCollection, $script:testStoredProcedure1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbStoredProcedure' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbStoredProcedure -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetStoredProcedureResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbStoredProcedureParameters = @{
                    Context             = $script:testContext
                    CollectionId        = $script:testCollection
                    Id                  = $script:testStoredProcedure1
                    StoredProcedureBody = $script:testStoredProcedureBody
                }

                { $script:result = Set-CosmosDbStoredProcedure @setCosmosDbStoredProcedureParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testStoredProcedure1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Put' -and `
                        $ResourceType -eq 'sprocs'
                    } `
                    -Exactly -Times 1
            }
        }
    }
}
