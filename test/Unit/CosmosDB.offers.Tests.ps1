[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force -Verbose:$false

InModuleScope CosmosDB {
    $TestHelperPath = "$PSScriptRoot\..\TestHelper"
    Import-Module -Name $TestHelperPath -Force

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
    $script:testOfferId1 = 'QH8O'
    $script:testOfferId2 = 'Z2sl'
    $script:testQuery = 'SELECT * FROM root WHERE (root["id"] = "lyiu")'
    $script:testJsonMulti = @'
{
    "_rid": "",
    "Offers": [
        {
            "offerVersion": "V2",
            "offerType": "Invalid",
            "content": {
                "offerThroughput": 400
            },
            "resource": "dbs/PaYSAA==/colls/PaYSAPH7qAo=/",
            "offerResourceId": "PaYSAPH7qAo=",
            "id": "QH8O",
            "_rid": "QH8O",
            "_self": "offers/QH8O/",
            "_etag": "\"00001400-0000-0000-0000-56f9897f0000\"",
            "_ts": 1459194239
        },
        {
            "offerType": "S3",
            "resource": "dbs/hPJRAA==/colls/hPJRAJQcIQg=/",
            "offerResourceId": "hPJRAJQcIQg=",
            "id": "Z2sl",
            "_rid": "Z2sl",
            "_self": "offers/Z2sl/",
            "_etag": "\"00000200-0000-0000-0000-56b281730000\"",
            "_ts": 1454539123
        }
    ],
    "_count": 2
    }
'@
    $script:testGetOfferResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "offerVersion": "V2",
    "offerType": "Invalid",
    "content": {
        "offerThroughput": 400
    },
    "resource": "dbs/PaYSAA==/colls/PaYSAPH7qAo=/",
    "offerResourceId": "PaYSAPH7qAo=",
    "id": "QH8O",
    "_rid": "QH8O",
    "_self": "offers/QH8O/",
    "_etag": "\"00001400-0000-0000-0000-56f9897f0000\"",
    "_ts": 1459194239
}
'@
    $script:testGetOfferResultSingle = @{
        Content = $script:testJsonSingle
    }

    Describe 'Get-CosmosDbOfferResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbOfferResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbOfferResourcePathParameters = @{
                    Id = $script:testOfferId1
                }

                { $script:result = Get-CosmosDbOfferResourcePath @getCosmosDbOfferResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('offers/{0}' -f $script:testOfferId1)
            }
        }
    }

    Describe 'Get-CosmosDbOffer' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbOffer -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'offers'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetOfferResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbOfferParameters = @{
                    Context = $script:testContext
                }

                { $script:result = Get-CosmosDbOffer @getCosmosDbOfferParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testOfferId1
                $script:result[1].id | Should -Be $script:testOfferId2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'offers' -and `
                    $ResourcePath -eq ('offers/{0}' -f $script:testOfferId1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetOfferResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbOfferParameters = @{
                    Context = $script:testContext
                    Id      = $script:testOfferId1
                }

                { $script:result = Get-CosmosDbOffer @getCosmosDbOfferParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testOfferId1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and a Query' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'offers' -and `
                    $Headers['x-ms-documentdb-isquery'] -eq $True -and `
                    $Body -eq (ConvertTo-Json -InputObject @{ query = $script:testQuery }) -and `
                    $ContentType -eq 'application/query+json'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetOfferResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbOfferParameters = @{
                    Context = $script:testContext
                    Query   = $script:testQuery
                }

                { $script:result = Get-CosmosDbOffer @getCosmosDbOfferParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result[0].id | Should -Be $script:testOfferId1
                $script:result[1].id | Should -Be $script:testOfferId2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }
    Describe 'Set-CosmosDbOffer' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbOffer -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and a V2 InputObject' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'offers' -and `
                (ConvertFrom-Json -InputObject $Body).content.offerThroughput -eq 10000
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetOfferResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbOfferParameters = @{
                    Context         = $script:testContext
                    InputObject     = (ConvertFrom-Json -InputObject $script:testJsonSingle)
                    OfferThroughput = 10000
                }

                { $script:result = Set-CosmosDbOffer @setCosmosDbOfferParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testOfferId1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and V2 InputObject with two objects' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'offers' -and `
                (ConvertFrom-Json -InputObject $Body).content.offerThroughput -eq 10000
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetOfferResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbOfferParameters = @{
                    Context         = $script:testContext
                    InputObject     = @(
                        (ConvertFrom-Json -InputObject $script:testJsonSingle)
                        (ConvertFrom-Json -InputObject $script:testJsonSingle)
                    )
                    OfferThroughput = 10000
                }

                { $script:result = Set-CosmosDbOffer @setCosmosDbOfferParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result[0].id | Should -Be $script:testOfferId1
                $script:result[1].id | Should -Be $script:testOfferId1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 2
            }
        }
    }
}
