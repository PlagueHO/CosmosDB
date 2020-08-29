[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            { Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            { $false
            } )
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
    $script:testDatabase1 = 'testDatabase1'
    $script:testDatabase2 = 'testDatabase2'
    $script:testOfferThroughput = 2000
    $script:testAutoscaleThroughput = 4000
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
    $script:testGetDatabaseResultMulti = @{
        Content = $script:testJsonMulti
    }
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
    $script:testGetDatabaseResultSingle = @{
        Content = $script:testJsonSingle
    }

    Describe 'Assert-CosmosDbDatabaseIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbDatabaseIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbDatabaseIdValid -Id 'This is a valid database ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DatabaseIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDatabaseIdValid -Id ('a' * 256)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id containing invalid characters' {
            $testCases = @{ Id = 'a\b' }, @{ Id = 'a/b' }, @{ Id = 'a#b' }, @{ Id = 'a?b' }, @{ Id = 'a=b' }

            It 'Should throw expected exception when called with "<Id>"' -TestCases $testCases {
                param
                (
                    [System.String]
                    $Id
                )

                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DatabaseIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDatabaseIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DatabaseIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDatabaseIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DatabaseIdInvalid -f 'a ') `
                    -ArgumentName 'TEst'

                {
                    Assert-CosmosDbDatabaseIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbDatabaseResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDatabaseResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
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

        Context 'When called with context parameter and no Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultMulti }

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
                    -ParameterFilter {
                    $Method -eq 'Get' -and `
                        $ResourceType -eq 'dbs'
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultSingle }

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
                    -ParameterFilter {
                    $Method -eq 'Get' -and `
                        $ResourceType -eq 'dbs' -and `
                        $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase)
                } `
                    -Exactly -Times 1
            }
        }
    }
    Describe 'New-CosmosDbDatabase' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbDatabase -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultSingle }

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
                    -ParameterFilter {
                    $Method -eq 'Post' -and `
                        $ResourceType -eq 'dbs' -and `
                        $Body -eq "{ `"id`": `"$($script:testDatabase)`" }"
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter, an Id and an OfferThroughput' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDatabaseParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testDatabase
                    OfferThroughput = $script:testOfferThroughput
                }

                { $script:result = New-CosmosDbDatabase @newCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDatabase1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'dbs' -and `
                        $Headers.'x-ms-offer-throughput' -eq $script:testOfferThroughput -and `
                        $Body -eq "{ `"id`": `"$($script:testDatabase)`" }"
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter, an Id and an AutoscaleThroughput' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDatabaseParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testDatabase
                    AutoscaleThroughput = $script:testAutoscaleThroughput
                }

                { $script:result = New-CosmosDbDatabase @newCosmosDbDatabaseParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDatabase1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'dbs' -and `
                        $Headers.'x-ms-cosmos-offer-autopilot-settings' -eq "{`"maxThroughput`":$($script:testAutoscaleThroughput)}" -and `
                        $Body -eq "{ `"id`": `"$($script:testDatabase)`" }"
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter, an Id and OfferThroughput and AutoscaleThroughput' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $testGetDatabaseResultSingle }

            It 'Should throw expected exception' {
                $newCosmosDbDatabaseParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testDatabase
                    OfferThroughput = $script:testOfferThroughput
                    AutoscaleThroughput = $script:testAutoscaleThroughput
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewDatabaseThroughputParameterConflict

                {
                    $script:result = New-CosmosDbDatabase @newCosmosDbDatabaseParameters
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Remove-CosmosDbDatabase' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbDatabase -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

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
                    -ParameterFilter {
                    $Method -eq 'Delete' -and `
                        $ResourceType -eq 'dbs' -and `
                        $ResourcePath -eq ('dbs/{0}' -f $script:testDatabase)
                } `
                    -Exactly -Times 1
            }
        }
    }
}
