[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$moduleManifestName = 'CosmosDB.psd1'
$moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $moduleManifestPath -Force -Verbose:$false

InModuleScope CosmosDB {
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
    $script:testTrigger1 = 'testTrigger1'
    $script:testTrigger2 = 'testTrigger2'
    $script:testTriggerBody = 'testTriggerBody'
    $script:testJsonMulti = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "Triggers": [
            {
                "body": "testTriggerBody",
                "id": "testTrigger1",
                "triggerOperation": "All",
                "triggerType": "Post",
                "_rid": "Sl8fALN4sw4BAAAAAAAAcA==",
                "_ts": 1449689654,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/triggers\/Sl8fALN4sw4BAAAAAAAAcA==\/",
                "_etag": "\"060022e5-0000-0000-0000-566882360000\""
            },
            {
                "body": "testTriggerBody",
                "id": "testTrigger2",
                "triggerOperation": "All",
                "triggerType": "Post",
                "_rid": "Sl8fALN4sw4BAAAAAAAAcA==",
                "_ts": 1449689654,
                "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/triggers\/Sl8fALN4sw4BAAAAAAAAcA==\/",
                "_etag": "\"060022e5-0000-0000-0000-566882360000\""
            }
        ],
        "_count": 2
    }
'@
    $script:testGetTriggerResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "body": "testTriggerBody",
    "id": "testTrigger1",
    "triggerOperation": "All",
    "triggerType": "Post",
    "_rid": "Sl8fALN4sw4BAAAAAAAAcA==",
    "_ts": 1449689654,
    "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/triggers\/Sl8fALN4sw4BAAAAAAAAcA==\/",
    "_etag": "\"060022e5-0000-0000-0000-566882360000\""
}
'@
    $script:testGetTriggerResultSingle = @{
        Content = $script:testJsonSingle
    }

    Describe 'Assert-CosmosDbTriggerIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbTriggerIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbTriggerIdValid -Id 'This is a valid trigger ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.TriggerIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbTriggerIdValid -Id ('a' * 256)
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
                    -Message ($LocalizedData.TriggerIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbTriggerIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.TriggerIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbTriggerIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.TriggerIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbTriggerIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbTriggerResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbTriggerResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbTriggerResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger1
                }

                { $script:result = Get-CosmosDbTriggerResourcePath @getCosmosDbTriggerResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/triggers/{2}' -f $script:testDatabase, $script:testCollection, $script:testTrigger1)
            }
        }
    }

    Describe 'Get-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetTriggerResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbTriggerParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbTrigger @getCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testTrigger1
                $script:result[1].id | Should -Be $script:testTrigger2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'triggers'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetTriggerResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbTriggerParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger1
                }

                { $script:result = Get-CosmosDbTrigger @getCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testTrigger1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'triggers' -and `
                        $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetTriggerResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbTriggerParameters = @{
                    Context          = $script:testContext
                    CollectionId     = $script:testCollection
                    Id               = $script:testTrigger1
                    TriggerBody      = $script:testTriggerBody
                    TriggerOperation = 'All'
                    TriggerType      = 'Post'
                }

                { $script:result = New-CosmosDbTrigger @newCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testTrigger1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { `
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'triggers'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbTriggerParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger1
                }

                { $script:result = Remove-CosmosDbTrigger @removeCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'triggers' -and `
                        $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetTriggerResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbTriggerParameters = @{
                    Context          = $script:testContext
                    CollectionId     = $script:testCollection
                    Id               = $script:testTrigger1
                    TriggerBody      = $script:testTriggerBody
                    TriggerOperation = 'All'
                    TriggerType      = 'Post'
                }

                { $script:result = Set-CosmosDbTrigger @setCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testTrigger1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Put' -and `
                        $ResourceType -eq 'triggers'
                    } `
                    -Exactly -Times 1
            }
        }
    }
}
