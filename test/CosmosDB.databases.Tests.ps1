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
    $script:testDatabase1 = 'testDatabase1'
    $script:testDatabase2 = 'testDatabase2'
    $script:testJsonMulti = @'
{
    "_rid": "",
    "Databases": [
        {
            "id": "testdatabase1",
            "_rid": "vdoeAA==",
            "_ts": 1442511602,
            "_self": "dbs\/vdoeAA==\/",
            "_etag": "\"00000100-0000-0000-0000-55fafaf20000\"",
            "_colls": "colls\/",
            "_users": "users\/"
        },
        {
            "id": "testdatabase2",
            "_rid": "vdoeAA==",
            "_ts": 1442511602,
            "_self": "dbs\/vdoeAA==\/",
            "_etag": "\"00000100-0000-0000-0000-55fafaf20000\"",
            "_colls": "colls\/",
            "_users": "users\/"
        }
    ],
    "_count": 2
}
'@
    $script:testJsonSingle = @'
{
    "id": "testdatabase1",
    "_rid": "vdoeAA==",
    "_ts": 1442511602,
    "_self": "dbs\/vdoeAA==\/",
    "_etag": "\"00000100-0000-0000-0000-55fafaf20000\"",
    "_colls": "colls\/",
    "_users": "users\/"
}
'@

    Describe 'Get-CosmosDbDatabaseResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDatabaseResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbDatabaseResourcePathParameters = @{
                    Id = $script:testDatabase
                }

                { $script:result = Get-CosmosDbDatabaseResourcePath @getCosmosDbDatabaseResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}' -f $script:testDatabase)
            }
        }
    }

    Describe 'Get-CosmosDbDatabase' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDatabase -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and no Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonMulti }

            It 'Should not throw exception' {
                $getCosmosDbDatabaseParameters = @{
                    Context = $script:testContext
                }

                { $script:result = Get-CosmosDbDatabase @getCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testDatabase1
                $script:result[1].id | Should -Be $script:testDatabase2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $getCosmosDbDatabaseParameters = @{
                    Context = $script:testContext
                    Id      = $script:testDatabase
                }

                { $script:result = Get-CosmosDbDatabase @getCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDatabase1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) } `
                    -Exactly -Times 1
            }
        }
    }
    Describe 'New-CosmosDbDatabase' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbDatabase -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'dbs' -and $Body -eq "{ `"id`": `"$($script:testDatabase)`" }" } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $newCosmosDbDatabaseParameters = @{
                    Context = $script:testContext
                    Id      = $script:testDatabase
                }

                { $script:result = New-CosmosDbDatabase @newCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDatabase1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'dbs' -and $Body -eq "{ `"id`": `"$($script:testDatabase)`" }" } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbDatabase' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbDatabase -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) }

            It 'Should not throw exception' {
                $removeCosmosDbDatabaseParameters = @{
                    Context = $script:testContext
                    Id      = $script:testDatabase
                }

                { $script:result = Remove-CosmosDbDatabase @removeCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) } `
                    -Exactly -Times 1
            }
        }
    }
}
