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
    $script:testJson = @'
{
    "_rid": "Sl8fAG8cXgA=",
    "Permissions": [{
        "id": "a_permission",
        "permissionMode": "Read",
        "resource": "dbs/testDatabase/colls/testCollection",
        "_rid": "Sl8fAG8cXgBn6Ju2GqNsAA==",
        "_ts": 1449604760,
        "_self": "dbs\/Sl8fAA==\/users\/Sl8fAG8cXgA=\/permissions\/Sl8fAG8cXgBn6Ju2GqNsAA==\/",
        "_etag": "\"00000e00-0000-0000-0000-566736980000\"",
        "_token": "type=resource&ver=1&sig=lxKlPHeqlIx2\/J02rFs3jw==;20MwFhNUO9xNOuglK9gyL18Mt5xIhbN48pzSq6FaR\/7sKFtGd6GaxCooIoPP6rYxRHUeCabHOFkbIeT4ercXk\/F1FG70QkQTD9CxDqNJx3NImgZJWErK1NlEjxkpFDV5uslhpJ4Y3JBnc72\/vlmR95TibFS0rC\/cdND0uRvoOOWXZYvVAJFKEUKyy3GTlYOxY1nKT313ZCOSUQF7kldjo9DE3XEBf8cct1uNKMILImo=;"
    }],
    "_count": 1
}
'@
    $script:testResource = 'dbs/testDatabase/colls/testCollection'

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

    Describe 'Get-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbPermission } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'permissions' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbPermissionParameters = @{
                    Connection = $script:testConnection
                    UserId     = $script:testUser
                }

                { $script:result = Get-CosmosDbPermission @getCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'permissions' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and no id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'permissions' -and $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbPermissionParameters = @{
                    Connection = $script:testConnection
                    UserId     = $script:testUser
                    Id         = $script:testPermission
                }

                { $script:result = Get-CosmosDbPermission @getCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'permissions' -and $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbPermission } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'permissions' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbPermissionParameters = @{
                    Connection = $script:testConnection
                    UserId     = $script:testUser
                    Id         = $script:testPermission
                    Resource   = $script:testResource
                }

                { $script:result = New-CosmosDbPermission @newCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'permissions' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbPermission } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'permissions' -and $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbPermissionParameters = @{
                    Connection = $script:testConnection
                    UserId     = $script:testUser
                    Id         = $script:testPermission
                }

                { $script:result = Remove-CosmosDbPermission @removeCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'permissions' -and $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission) } `
                    -Exactly -Times 1
            }
        }
    }
}
