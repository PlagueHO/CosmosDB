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
    $script:testCollection = 'testCollection'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testEmulatorKey = 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=='
    $script:testBaseUri = 'documents.contoso.com'
    $script:testDate = (Get-Date -Year 2017 -Month 11 -Day 29 -Hour 10 -Minute 45 -Second 10)
    $script:testUniversalDate = 'Tue, 28 Nov 2017 21:45:10 GMT'
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testToken = 'type-resource&ver=1.0&sig=5mDuQBYA0kb70WDJoTUzSBMTG3owkC0/cEN4fqa18/s='
    $script:testTokenSecureString = ConvertTo-SecureString -String $script:testToken -AsPlainText -Force
    $script:testTokenResource = ('dbs/{0}/colls/{1}' -f $script:testDatabase, $script:testCollection)
    $script:testTokenExpiry = 7200
    $script:testContextToken = [CosmosDB.ContextToken] @{
        Resource  = $script:testTokenResource
        TimeStamp = $script:testDate
        Expires   = $script:testDate.AddSeconds($script:testTokenExpiry)
        Token     = $script:testTokenSecureString
    }
    $script:testResourceContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
        Token    = $script:testContextToken
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
    $script:testInvokeWebRequestResult = @{
        Content = $script:testJson
    }
    $script:testResourceGroup = 'testResourceGroup'

    Describe 'Custom types' -Tag 'Unit' {
        Context 'CosmosDB.Context' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.Context').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Policy' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Policy').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.Index' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.Index').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.IncludedPath' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.IncludedPath').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.ExcludedPath' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.ExcludedPath').Type | Should -Be $True
            }
        }
    }

    Describe 'New-CosmosDbContext' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbContext -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with Account parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    Key      = $script:testKeySecureString
                    KeyType  = 'master'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'When called with AzureAccount parameters and not connected to Azure' {
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
                $newCosmosDbContextParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
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

        Context 'When called with AzureAccount parameters and connected to Azure' {
            $script:result = $null

            Mock `
                -CommandName Invoke-AzureRmResourceAction `
                -MockWith { @{
                    primaryMasterKey           = 'primaryMasterKey'
                    secondaryMasterKey         = 'secondaryMasterKey'
                    primaryReadonlyMasterKey   = 'primaryReadonlyMasterKey'
                    secondaryReadonlyMasterKey = 'secondaryReadonlyMasterKey'
                } }

            Mock -CommandName Get-AzureRmContext -MockWith { $true }
            Mock -CommandName Add-AzureRmAccount

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
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

        Context 'When called with Emulator parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'localhost'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://localhost:8081/')
            }
        }

        Context 'When called with Token parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    Token    = $script:testContextToken
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
                $script:result.Token[0].Resource | Should -Be $script:testTokenResource
                $script:result.Token[0].TimeStamp | Should -Be $script:testDate
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($script:result.Token[0].Token)
                $decryptedToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                $decryptedToken | Should -Be $script:testToken
            }
        }
    }

    Describe 'New-CosmosDbContextToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbContextToken -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with paramters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextTokenParameters = @{
                    Resource    = $script:testTokenResource
                    TimeStamp   = $script:testDate
                    TokenExpiry = $script:testTokenExpiry
                    Token       = $script:testTokenSecureString
                    Verbose     = $true
                }

                { $script:result = New-CosmosDbContextToken @newCosmosDbContextTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Resource | Should -Be $script:testTokenResource
                $script:result.TimeStamp | Should -Be $script:testDate
                $script:result.Expires | Should -Be $script:testDate.AddSeconds($script:testTokenExpiry)
                $script:result.Token | Should -Be $script:testTokenSecureString
            }
        }
    }

    Describe 'Get-CosmosDbUri' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUri -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with Account parameter only' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                    Verbose = $true
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'When called with Account and BaseUri parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                    BaseUri = $script:testBaseUri
                    Verbose = $true
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

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertToCosmosDBTokenDateStringParameters = @{
                    Date    = $script:testDate
                    Verbose = $true
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

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbAuthorizationTokenParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/testdb'
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbAuthorizationToken @newCosmosDbAuthorizationTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dr3RhzxX7rv4ZHqo4aT1jDszfV7svQ7JFXoi7hz1Iwto%3d'
            }
        }

        Context 'When called with all parameters and mixed case ResourceId' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbAuthorizationTokenParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/Testdb'
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbAuthorizationToken @newCosmosDbAuthorizationTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dncZem2Awq%2b0LkrQ7mlwJePX%2f2qyEPG3bQDrnuedrjZU%3d'
            }
        }
    }

    Describe 'Invoke-CosmosDbRequest' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Invoke-CosmosDbRequest -ErrorAction Stop } | Should -Not -Throw
        }

        BeforeEach {
            Mock -CommandName Get-Date -MockWith { $script:testDate }
        }

        $InvokeWebRequest_mockwith = {
            $testInvokeWebRequestResult
        }

        Context 'When called with context parameter and Get method and ResourceType is ''users''' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                    $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, 'users')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'users'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Get method and ResourceType is ''dbs''' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                    $Uri -eq ('{0}{1}' -f $script:testContext.BaseUri, 'dbs')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'dbs'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Get method and ResourceType is ''offers''' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                    $Uri -eq ('{0}{1}' -f $script:testContext.BaseUri, 'offers')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'offers'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Get method and ResourceType is ''colls''' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                    $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, 'colls')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'colls'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with Get method and ResourceType is ''colls'' and a resource token context that matches the resource link' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                $ContentType -eq 'application/json' -and `
                $Uri -eq ('{0}dbs/{1}/colls/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, $script:testCollection)
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testResourceContext
                    Method       = 'Get'
                    ResourceType = 'colls'
                    ResourcePath = ('colls/{0}' -f $script:testCollection)
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with Get method and ResourceType is ''colls'' and a resource token context without matching token and no master key' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                $ContentType -eq 'application/json' -and `
                $Uri -eq ('{0}dbs/{1}/colls/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, 'anotherCollection')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testResourceContext
                    Method       = 'Get'
                    ResourceType = 'colls'
                    ResourcePath = ('colls/{0}' -f 'anotherCollection')
                    Verbose      = $true
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Throw ($LocalizedData.ErrorAuthorizationKeyEmpty)
            }

            It 'Should return expected result' {
                $script:result | Should -BeNullOrEmpty
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 0
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 0
            }
        }

        Context 'When called with context parameter and Post method' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ContentType -eq 'application/query+json' -and `
                    $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, 'users')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -ParameterFilter $InvokeWebRequest_parameterfilter `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Post'
                    ResourceType = 'users'
                    ContentType  = 'application/query+json'
                    Body         = '{ "id": "daniel" }'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-WebRequest `
                    -ParameterFilter $InvokeWebRequest_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }
    }
}
