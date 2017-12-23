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
    $script:testBaseUri = 'documents.contoso.com'
    $script:testDate = (Get-Date -Year 2017 -Month 11 -Day 29 -Hour 10 -Minute 45 -Second 10)
    $script:testUniversalDate = 'Tue, 28 Nov 2017 21:45:10 GMT'
    $script:testConnection = [CosmosDb.Connection] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testJson = @'
{
    "_rid": "2MFbAA==",
    "Users": [
        {
            "id": "testUser"
        }
    ],
    "_count": 1
}
'@
    $script:testResourceGroup = 'testResourceGroup'

    Describe 'New-CosmosDbConnection' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbConnection -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with Connection parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbConnectionParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    Key      = $script:testKeySecureString
                    KeyType  = 'master'
                }

                { $script:result = New-CosmosDbConnection @newCosmosDbConnectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'Called with Azure parameters and not connected to Azure' {
            $script:result = $null

            Mock -CommandName Get-AzureRmContext -MockWith { throw }
            Mock -CommandName Add-AzureRmAccount
            Mock `
                -CommandName Invoke-AzureRmResourceAction `
                -MockWith { @{
                    primaryMasterKey           = 'primaryMasterKey'
                    secondaryMasterKey         = 'secondaryMasterKey'
                    primaryReadonlyMasterKey   = 'primaryReadonlyMasterKey'
                    secondaryReadonlyMasterKey = 'secondaryReadonlyMasterKey'
                } }

            It 'Should not throw exception' {
                $newCosmosDbConnectionParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbConnection @newCosmosDbConnectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-AzureRmResourceAction -Exactly -Times 1
                Assert-MockCalled -CommandName Get-AzureRmContext -Exactly -Times 1
                Assert-MockCalled -CommandName Add-AzureRmAccount -Exactly -Times 1
            }
        }

        Context 'Called with Azure parameters and connected to Azure' {
            $script:result = $null

            Mock `
                -CommandName Invoke-AzureRmResourceAction `
                -MockWith { @{
                    primaryMasterKey           = 'primaryMasterKey'
                    secondaryMasterKey         = 'secondaryMasterKey'
                    primaryReadonlyMasterKey   = 'primaryReadonlyMasterKey'
                    secondaryReadonlyMasterKey = 'secondaryReadonlyMasterKey'
                } }

            Mock -CommandName Get-AzureRmContext -MockWith { $true  }
            Mock -CommandName Add-AzureRmAccount

            It 'Should not throw exception' {
                $newCosmosDbConnectionParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbConnection @newCosmosDbConnectionParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-AzureRmResourceAction -Exactly -Times 1
                Assert-MockCalled -CommandName Get-AzureRmContext -Exactly -Times 1
                Assert-MockCalled -CommandName Add-AzureRmAccount -Exactly -Times 0
            }
        }
    }

    Describe 'Get-CosmosDbUri' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUri -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with Account parameter only' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'Called with Account and BaseUri parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                    BaseUri = $script:testBaseUri
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseUri)
            }
        }
    }

    Describe 'ConvertTo-CosmosDbTokenDateString' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name ConvertTo-CosmosDbTokenDateString -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertToCosmosDBTokenDateStringParameters = @{
                    Date = $script:testDate
                }

                { $script:result = ConvertTo-CosmosDbTokenDateString @convertToCosmosDBTokenDateStringParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testDate.ToUniversalTime().ToString("r", [System.Globalization.CultureInfo]::InvariantCulture)
            }
        }
    }

    Describe 'New-CosmosDbAuthorizationToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbAuthorizationToken } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbAuthorizationTokenParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/testdb'
                    Date         = $script:testUniversalDate
                }

                { $script:result = New-CosmosDbAuthorizationToken @newCosmosDbAuthorizationTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dr3RhzxX7rv4ZHqo4aT1jDszfV7svQ7JFXoi7hz1Iwto%3d'
            }
        }
    }

    Describe 'Invoke-CosmosDbRequest' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Invoke-CosmosDbRequest -ErrorAction Stop } | Should -Not -Throw
        }

        BeforeEach {
            Mock -CommandName Invoke-RestMethod -MockWith { ConvertFrom-Json -InputObject $script:testJson }
            Mock -CommandName Get-Date -MockWith { $script:testDate }
        }

        Context 'Called with connection parameter and Get method' {
            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Connection   = $script:testConnection
                    Method       = 'Get'
                    ResourceType = 'users'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and Post method' {
            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Connection   = $script:testConnection
                    Method       = 'Post'
                    ResourceType = 'users'
                    Body         = '{ "id": "daniel" }'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }
    }
}
