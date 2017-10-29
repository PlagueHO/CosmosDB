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
    $script:testPermission = 'testPermission'

    Describe 'Get-CosmosDbPermissionResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbPermissionResourcePath } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            It 'Should not throw exception' {
                $getCosmosDbPermissionResourcePathParameters = @{
                    Database = $script:testDatabase
                    UserId   = $script:testUser
                    Id       = $script:testPermission
                }

                { $script:result = Get-CosmosDbPermissionResourcePath @getCosmosDbPermissionResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/users/{1}/permissions/{2}' -f $script:testDatabase, $script:testUser, $script:testPermission)
            }
        }
    }
}
