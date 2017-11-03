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
    $script:testTrigger = 'testTrigger'
    $script:testTriggerBody = 'testTriggerBody'
    $script:testJson = @'
    {
        "_rid": "Sl8fALN4sw4=",
        "Triggers": [{
            "body": "testTriggerBody",
            "id": "testTrigger",
            "triggerOperation": "All",
            "triggerType": "Post",
            "_rid": "Sl8fALN4sw4BAAAAAAAAcA==",
            "_ts": 1449689654,
            "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/triggers\/Sl8fALN4sw4BAAAAAAAAcA==\/",
            "_etag": "\"060022e5-0000-0000-0000-566882360000\""
        }],
        "_count": 1
    }
'@

    Describe 'Get-CosmosDbTriggerResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbTriggerResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbTriggerResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger
                }

                { $script:result = Get-CosmosDbTriggerResourcePath @getCosmosDbTriggerResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/triggers/{2}' -f $script:testDatabase, $script:testCollection, $script:testTrigger)
            }
        }
    }

    Describe 'Get-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'triggers' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbTriggerParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                }

                { $script:result = Get-CosmosDbTrigger @getCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'triggers' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'triggers' -and $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbTriggerParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger
                }

                { $script:result = Get-CosmosDbTrigger @getCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'triggers' -and $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'triggers' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbTriggerParameters = @{
                    Connection       = $script:testConnection
                    CollectionId     = $script:testCollection
                    Id               = $script:testTrigger
                    TriggerBody      = $script:testTriggerBody
                    TriggerOperation = 'All'
                    TriggerType      = 'Post'
                }

                { $script:result = New-CosmosDbTrigger @newCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'triggers' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'triggers' -and $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbTriggerParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    Id           = $script:testTrigger
                }

                { $script:result = Remove-CosmosDbTrigger @removeCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'triggers' -and $ResourcePath -eq ('colls/{0}/triggers/{1}' -f $script:testCollection, $script:testTrigger) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbTrigger' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbTrigger -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'triggers' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $setCosmosDbTriggerParameters = @{
                    Connection       = $script:testConnection
                    CollectionId     = $script:testCollection
                    Id               = $script:testTrigger
                    TriggerBody      = $script:testTriggerBody
                    TriggerOperation = 'All'
                    TriggerType      = 'Post'
                }

                { $script:result = Set-CosmosDbTrigger @setCosmosDbTriggerParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'triggers' } `
                    -Exactly -Times 1
            }
        }
    }
}
