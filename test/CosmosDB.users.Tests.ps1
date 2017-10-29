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

    Describe 'Get-CosmosDbUserResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserResourcePath } | Should -Not -Throw
        }

        Context 'Called with connection parameter and Get method' {
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
}
