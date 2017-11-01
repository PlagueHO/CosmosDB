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
    $script:testJson = @'
{
    "_rid": "",
    "Databases": [{
        "id": "testdatabase",
        "_rid": "vdoeAA==",
        "_ts": 1442511602,
        "_self": "dbs\/vdoeAA==\/",
        "_etag": "\"00000100-0000-0000-0000-55fafaf20000\"",
        "_colls": "colls\/",
        "_users": "users\/"
    }],
    "_count": 1
}
'@

    Describe 'Get-CosmosDbDatabaseResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDatabaseResourcePath } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
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
            { Get-Command -Name Get-CosmosDbDatabase } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbDatabaseParameters = @{
                    Connection = $script:testConnection
                }

                { $script:result = Get-CosmosDbDatabase @getCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbDatabaseParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testDatabase
                }

                { $script:result = Get-CosmosDbDatabase @getCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'dbs' -and $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase) } `
                    -Exactly -Times 1
            }
        }
    }
}
