[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module -Name $ProjectName -Force

InModuleScope $ProjectName {
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
    $script:testUser1 = 'testUser1'
    $script:testUser2 = 'testUser2'
    $script:testJsonMulti = @'
{
    "_rid": "2MFbAA==",
    "Users": [
        {
            "id": "testUser1"
        },
        {
            "id": "testUser2"
        }
    ],
    "_count": 2
}
'@
    $script:testGetUserResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "id": "testUser1"
}
'@
    $script:testGetUserResultSingle = @{
        Content = $script:testJsonSingle
    }

    Describe 'Assert-CosmosDbUserIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbUserIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbUserIdValid -Id 'This is a valid user ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.UserIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbUserIdValid -Id ('a' * 256)
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
                    -Message ($LocalizedData.UserIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbUserIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.UserIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbUserIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.UserIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbUserIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbUserResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUserResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbUserResourcePathParameters = @{
                    Database = $script:testDatabase
                    Id       = $script:testUser1
                }

                { $script:result = Get-CosmosDbUserResourcePath @getCosmosDbUserResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/users/{1}' -f $script:testDatabase, $script:testUser1)
            }
        }
    }

    Describe 'Get-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetUserResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbUserParameters = @{
                    Context = $script:testContext
                }

                { $script:result = Get-CosmosDbUser @getCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testUser1
                $script:result[1].id | Should -Be $script:testUser2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'users'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetUserResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbUserParameters = @{
                    Context = $script:testContext
                    Id      = $script:testUser1
                }

                { $script:result = Get-CosmosDbUser @getCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUser1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'users' -and `
                        $ResourcePath -eq ('users/{0}' -f $script:testUser1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetUserResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbUserParameters = @{
                    Context = $script:testContext
                    Id      = $script:testUser1
                }

                { $script:result = New-CosmosDbUser @newCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUser1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'users' -and `
                        $Body -eq "{ `"id`": `"$($script:testUser1)`" }"
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbUserParameters = @{
                    Context = $script:testContext
                    Id      = $script:testUser1
                }

                { $script:result = Remove-CosmosDbUser @removeCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'users' -and `
                        $ResourcePath -eq ('users/{0}' -f $script:testUser1)
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbUser' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbUser -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and Id and NewId' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetUserResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbUserParameters = @{
                    Context = $script:testContext
                    Id      = $script:testUser1
                    NewId   = 'NewId'
                }

                { $script:result = Set-CosmosDbUser @setCosmosDbUserParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testUser1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Put' -and `
                        $ResourceType -eq 'users' -and `
                        $ResourcePath -eq ('users/{0}' -f $script:testUser1) -and `
                        $Body -eq "{ `"id`": `"NewId`" }"
                    } `
                    -Exactly -Times 1
            }
        }
    }
}
