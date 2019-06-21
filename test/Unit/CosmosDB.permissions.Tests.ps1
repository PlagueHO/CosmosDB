[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $ModuleRootPath = ($PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src')
)

$moduleManifestName = 'CosmosDB.psd1'
$moduleManifestPath = Join-Path -Path $ModuleRootPath -ChildPath $moduleManifestName

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
    $script:testUser = 'testUser'
    $script:testPermission1 = 'testPermission1'
    $script:testPermission2 = 'testPermission2'
    $script:testJsonMulti = @'
{
    "_rid": "Sl8fAG8cXgA=",
    "Permissions": [
        {
            "id": "testPermission1",
            "permissionMode": "Read",
            "resource": "dbs/testDatabase/colls/testCollection",
            "_rid": "Sl8fAG8cXgBn6Ju2GqNsAA==",
            "_ts": 1449604760,
            "_self": "dbs\/Sl8fAA==\/users\/Sl8fAG8cXgA=\/permissions\/Sl8fAG8cXgBn6Ju2GqNsAA==\/",
            "_etag": "\"00000e00-0000-0000-0000-566736980000\"",
            "_token": "type=resource&ver=1&sig=lxKlPHeqlIx2\/J02rFs3jw==;20MwFhNUO9xNOuglK9gyL18Mt5xIhbN48pzSq6FaR\/7sKFtGd6GaxCooIoPP6rYxRHUeCabHOFkbIeT4ercXk\/F1FG70QkQTD9CxDqNJx3NImgZJWErK1NlEjxkpFDV5uslhpJ4Y3JBnc72\/vlmR95TibFS0rC\/cdND0uRvoOOWXZYvVAJFKEUKyy3GTlYOxY1nKT313ZCOSUQF7kldjo9DE3XEBf8cct1uNKMILImo=;"
        },
        {
            "id": "testPermission2",
            "permissionMode": "All",
            "resource": "dbs/testDatabase/colls/testCollection",
            "_rid": "Sl8fAG8cXgBn6Ju2GqNsAA==",
            "_ts": 1449604760,
            "_self": "dbs\/Sl8fAA==\/users\/Sl8fAG8cXgA=\/permissions\/Sl8fAG8cXgBn6Ju2GqNsAA==\/",
            "_etag": "\"00000e00-0000-0000-0000-566736980000\"",
            "_token": "type=resource&ver=1&sig=lxKlPHeqlIx2\/J02rFs3jw==;20MwFhNUO9xNOuglK9gyL18Mt5xIhbN48pzSq6FaR\/7sKFtGd6GaxCooIoPP6rYxRHUeCabHOFkbIeT4ercXk\/F1FG70QkQTD9CxDqNJx3NImgZJWErK1NlEjxkpFDV5uslhpJ4Y3JBnc72\/vlmR95TibFS0rC\/cdND0uRvoOOWXZYvVAJFKEUKyy3GTlYOxY1nKT313ZCOSUQF7kldjo9DE3XEBf8cct1uNKMILImo=;"
        }
        ],
    "_count": 2
}
'@
    $script:testGetPermissionResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "id": "testPermission1",
    "permissionMode": "Read",
    "resource": "dbs/testDatabase/colls/testCollection",
    "_rid": "Sl8fAG8cXgBn6Ju2GqNsAA==",
    "_ts": 1449604760,
    "_self": "dbs\/Sl8fAA==\/users\/Sl8fAG8cXgA=\/permissions\/Sl8fAG8cXgBn6Ju2GqNsAA==\/",
    "_etag": "\"00000e00-0000-0000-0000-566736980000\"",
    "_token": "type=resource&ver=1&sig=lxKlPHeqlIx2\/J02rFs3jw==;20MwFhNUO9xNOuglK9gyL18Mt5xIhbN48pzSq6FaR\/7sKFtGd6GaxCooIoPP6rYxRHUeCabHOFkbIeT4ercXk\/F1FG70QkQTD9CxDqNJx3NImgZJWErK1NlEjxkpFDV5uslhpJ4Y3JBnc72\/vlmR95TibFS0rC\/cdND0uRvoOOWXZYvVAJFKEUKyy3GTlYOxY1nKT313ZCOSUQF7kldjo9DE3XEBf8cct1uNKMILImo=;"
}
'@
    $script:testGetPermissionResultSingle = @{
        Content = $script:testJsonSingle
    }
    $script:testResource = 'dbs/testDatabase/colls/testCollection'

    Describe 'Assert-CosmosDbPermissionIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbPermissionIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbPermissionIdValid -Id 'This is a valid permission ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.PermissionIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbPermissionIdValid -Id ('a' * 256)
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
                    -Message ($LocalizedData.PermissionIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbPermissionIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.PermissionIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbPermissionIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.PermissionIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbPermissionIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbPermissionResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbPermissionResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbPermissionResourcePathParameters = @{
                    Database = $script:testDatabase
                    UserId   = $script:testUser
                    Id       = $script:testPermission1
                }

                { $script:result = Get-CosmosDbPermissionResourcePath @getCosmosDbPermissionResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/users/{1}/permissions/{2}' -f $script:testDatabase, $script:testUser, $script:testPermission1)
            }
        }
    }

    Describe 'Get-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbPermission -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetPermissionResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbPermissionParameters = @{
                    Context = $script:testContext
                    UserId  = $script:testUser
                }

                { $script:result = Get-CosmosDbPermission @getCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testPermission1
                $script:result[1].id | Should -Be $script:testPermission2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'permissions'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetPermissionResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbPermissionParameters = @{
                    Context = $script:testContext
                    UserId  = $script:testUser
                    Id      = $script:testPermission1
                }

                { $script:result = Get-CosmosDbPermission @getCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testPermission1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'permissions' -and `
                        $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission1)
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id and token expiry' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetPermissionResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbPermissionParameters = @{
                    Context     = $script:testContext
                    UserId      = $script:testUser
                    Id          = $script:testPermission1
                    TokenExpiry = 18000
                }

                { $script:result = Get-CosmosDbPermission @getCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testPermission1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'permissions' -and `
                        $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission1) -and `
                        $Headers.'x-ms-documentdb-expiry-seconds' -eq 18000
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbPermission -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetPermissionResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbPermissionParameters = @{
                    Context  = $script:testContext
                    UserId   = $script:testUser
                    Id       = $script:testPermission1
                    Resource = $script:testResource
                }

                { $script:result = New-CosmosDbPermission @newCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testPermission1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'permissions'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbPermission' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbPermission -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbPermissionParameters = @{
                    Context = $script:testContext
                    UserId  = $script:testUser
                    Id      = $script:testPermission1
                }

                { $script:result = Remove-CosmosDbPermission @removeCosmosDbPermissionParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'permissions' -and `
                        $ResourcePath -eq ('users/{0}/permissions/{1}' -f $script:testUser, $script:testPermission1)
                    } `
                    -Exactly -Times 1
            }
        }
    }
}
