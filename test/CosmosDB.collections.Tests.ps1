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
    $script:testJson = @'
{
    "_rid": "PaYSAA==",
    "DocumentCollections": [
        {
            "id": "testcollection"
        }
    ],
    "_count": 1
}
'@

    Describe 'Get-CosmosDbCollectionResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbCollectionResourcePath } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            It 'Should not throw exception' {
                $getCosmosDbCollectionResourcePathParameters = @{
                    Database = $script:testDatabase
                    Id       = $script:testCollection
                }

                { $script:result = Get-CosmosDbCollectionResourcePath @getCosmosDbCollectionResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}' -f $script:testDatabase, $script:testCollection)
            }
        }
    }

    Describe 'Get-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbCollection } | Should -Not -Throw
        }

        Context 'Called with connection parameter and no Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbCollectionParameters = @{
                    Connection = $script:testConnection
                }

                { $script:result = Get-CosmosDbCollection @getCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $getCosmosDbCollectionParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testCollection
                }

                { $script:result = Get-CosmosDbCollection @getCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbCollection } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbCollectionParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testCollection
                }

                { $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id and OfferThroughput parameter' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" -and $Headers['x-ms-offer-throughput'] -eq 400 } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbCollectionParameters = @{
                    Connection      = $script:testConnection
                    Id              = $script:testCollection
                    OfferThroughput = 400
                }

                { $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" -and $Headers['x-ms-offer-throughput'] -eq 400 } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id and OfferType parameter' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" -and $Headers['x-ms-offer-type'] -eq 'S2' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbCollectionParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testCollection
                    OfferType  = 'S2'
                }

                { $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`" }" -and $Headers['x-ms-offer-type'] -eq 'S2' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id and PartitionKey parameter' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`", `"partitionKey`": { `"paths`": [ `"/partitionkey`" ], `"kind`": `"Hash`" } }" } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbCollectionParameters = @{
                    Connection   = $script:testConnection
                    Id           = $script:testCollection
                    PartitionKey = 'partitionkey'
                }

                { $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'colls' -and $Body -eq "{ `"id`": `"$($script:testCollection)`", `"partitionKey`": { `"paths`": [ `"/partitionkey`" ], `"kind`": `"Hash`" } }" } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an Id and OfferType and OfferThrougput' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $newCosmosDbCollectionParameters = @{
                    Connection      = $script:testConnection
                    Id              = $script:testCollection
                    OfferThroughput = 400
                    OfferType       = 'S1'
                }

                { $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters } | Should -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -Exactly -Times 0
            }
        }

    }

    Describe 'Remove-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbCollection } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJson }

            It 'Should not throw exception' {
                $removeCosmosDbCollectionParameters = @{
                    Connection = $script:testConnection
                    Id         = $script:testCollection
                }

                { $script:result = Remove-CosmosDbCollection @removeCosmosDbCollectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection) } `
                    -Exactly -Times 1
            }
        }
    }
}
