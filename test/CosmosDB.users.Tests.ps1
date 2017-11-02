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
    $script:testUser = 'testUser'
    $script:testJson = @'
{
    "_rid": "2MFbAA==",
    "Users": [
        {
            "id": "daniel"
        }
    ],
    "_count": 1
}
'@

    Describe 'Get-CosmosDbUserResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbUserResourcePathParameters = @{
                    Database = $script:testDatabase
                    Id       = $script:testUser
                }

                { $script:result = Get-CosmosDbUserResourcePath @getCosmosDbUserResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/users/{1}' -f $script:testDatabase, $script:testUser)
            }
        }
    }

    Describe 'Get-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'users' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbUserParameters = @{
                    Connection = $script:testConnection
                }

                { $script:result = Get-CosmosDbUser @getCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'users' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbUserParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testUser
                }

                { $script:result = Get-CosmosDbUser @getCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'users' -and $Body -eq "{ `"id`": `"$($script:testUser)`" }" } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbUserParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testUser
                }

                { $script:result = New-CosmosDbUser @newCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'users' -and $Body -eq "{ `"id`": `"$($script:testUser)`" }" } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbUserParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testUser
                }

                { $script:result = Remove-CosmosDbUser @removeCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and Id and NewId' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) -and $Body -eq "{ `"id`": `"NewId`" }"} `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $setCosmosDbUserParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testUser
                    NewId      = 'NewId'
                }

                { $script:result = Set-CosmosDbUser @setCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'users' -and $ResourcePath -eq ('users/{0}' -f $script:testUser) -and $Body -eq "{ `"id`": `"NewId`" }"} `
                    -Exactly -Times 1
            }
        }
    }
}
