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
    $script:testCollection = 'testCollection'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testEmulatorKey = 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=='
    $script:testBaseHostname = 'documents.contoso.com'
    $script:testBaseHostnameAzureCloud = 'documents.azure.com'
    $script:testBaseHostnameAzureUsGov = 'documents.azure.us'
    $script:testBaseHostnameAzureChinaCloud = 'documents.azure.cn'
    $script:testBaseHostnameAzureCustomEndpoint = 'documents.somecloud.zzz'
    $script:testDate = (Get-Date -Year 2017 -Month 11 -Day 29 -Hour 10 -Minute 45 -Second 10)
    $script:testUniversalDate = 'Tue, 28 Nov 2017 21:45:10 GMT'
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testAuthorizationHeaderResourceToken = 'type=resource&ver=1.0&sig=5mDuQBYA0kb70WDJoTUzSBMTG3owkC0/cEN4fqa18/s='
    $script:testAuthorizationHeaderResourceTokenSecureString = ConvertTo-SecureString -String $script:testAuthorizationHeaderResourceToken -AsPlainText -Force
    $script:testAuthorizationContextResource = ('dbs/{0}/colls/{1}' -f $script:testDatabase, $script:testCollection)
    $script:testAuthorizationContextResourceExpiry = 7200
    $script:testTokenExpirationDate = (Get-Date).AddSeconds($script:testAuthorizationContextResourceExpiry)
    $script:testTokenExpirationUniversalDate = $script:testTokenExpirationDate.ToUniversalTime().ToString("r", [System.Globalization.CultureInfo]::InvariantCulture)
    $script:testContextToken = [CosmosDB.ContextToken] @{
        Resource  = $script:testAuthorizationContextResource
        TimeStamp = $script:testDate
        Expires   = $script:testTokenExpirationDate
        Token     = $script:testAuthorizationHeaderResourceTokenSecureString
    }
    $script:testContextTokenExpired = [CosmosDB.ContextToken] @{
        Resource  = $script:testAuthorizationContextResource
        TimeStamp = $script:testDate
        Expires   = Get-Date
        Token     = $script:testAuthorizationHeaderResourceTokenSecureString
    }
    $script:testResourceContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
        Token    = $script:testContextToken
    }
    $script:testResourceContextExpired = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
        Token    = $script:testContextTokenExpired
    }
    # Not a real token, just a test token
    $script:testEntraIdToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ikwx...t7XeB7XeDn1xsdXS3FbgGDPsYeB-0utkCJndu3ixHuDK_gTKWoQ'
    $script:testEntraIdTokenSecureString = ConvertTo-SecureString -String $script:testEntraIdToken -AsPlainText -Force
    $script:testAuthorizationHeaderEntraIdToken = "type=aad&ver=1.0&sig=$testEntraIdToken"
    $script:testEntraIdContext = [CosmosDB.Context] @{
        Account  = $script:testAccount
        EntraIdToken = $script:testEntraIdTokenSecureString
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
    $script:testInvokeWebRequestResult = @{
        Content = $script:testJson
        Headers = @{ 'x-ms-request-charge' = '5' }
    }
    $script:testResourceGroupName = 'testResourceGroup'
    $script:testMaxRetries = 20
    $script:testMethod = 'Default'
    $script:testDelay = 1
    $script:testRequestString = @'
if (entityAlreadyExists)
    throw new Error(`root entity # ${entity.id} already created`);
console.log(`new entity "${entity.id}" is about to be created...`);
let a = 'some value';
console.log("done");
'@
    $script:testRequestObject = @{
        "Tricky Body" = $script:testRequestString
    }

    $script:testRequestBodyJson = '{"Tricky Body":"if (entityAlreadyExists)\r\n    throw new Error(`root entity # ${entity.id} already created`);\r\nconsole.log(`new entity \"${entity.id}\" is about to be created...`);\r\nlet a = \u0027some value\u0027;\r\nconsole.log(\"done\");"}'
    $script:testConnectionString = "AccountEndpoint=https://{0}.documents.azure.com:443/;AccountKey={1};" -f $script:testAccount, $script:testKey


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

        Context 'CosmosDB.UniqueKeyPolicy.UniqueKey' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.UniqueKeyPolicy.UniqueKey').Type | Should -Be $True
            }
        }

        Context 'CosmosDB.UniqueKeyPolicy.Policy' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.UniqueKeyPolicy.Policy').Type | Should -Be $True
            }
        }
    }

    Describe 'Convert-CosmosDbSecureStringToString' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Convert-CosmosDbSecureStringToString -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with valid SecureString' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertCosmosDbSecureStringToStringParameters = @{
                    SecureString = $script:testKeySecureString
                }

                { $script:result = Convert-CosmosDbSecureStringToString @convertCosmosDbSecureStringToStringParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result = $script:testKey
            }
        }

        Context 'When called with a valid SecureString via pipeline variable' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertCosmosDbSecureStringToStringParameters = @{
                    SecureString = $script:testKeySecureString
                }
                Write-Verbose -Message "Type: $($script:testKeySecureString.GetType().FullName)" -Verbose
                { $script:result = $convertCosmosDbSecureStringToStringParameters.SecureString | Convert-CosmosDbSecureStringToString } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result = $script:testKey
            }
        }
    }

    Describe 'New-CosmosDbBackoffPolicy' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbBackoffPolicy -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with paramters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextBackoffPolicyParameters = @{
                    MaxRetries = $script:testMaxRetries
                    Method     = $script:testMethod
                    Delay      = $script:testDelay
                }

                { $script:result = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.MaxRetries = $script:testMaxRetries
                $script:result.Method = $script:testMethod
                $script:result.Delay = $script:testDelay
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
                    Resource    = $script:testAuthorizationContextResource
                    TimeStamp   = $script:testDate
                    TokenExpiry = $script:testAuthorizationContextResourceExpiry
                    Token       = $script:testAuthorizationHeaderResourceTokenSecureString
                    Verbose     = $true
                }

                { $script:result = New-CosmosDbContextToken @newCosmosDbContextTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Resource | Should -Be $script:testAuthorizationContextResource
                $script:result.TimeStamp | Should -Be $script:testDate
                $script:result.Expires | Should -Be $script:testDate.AddSeconds($script:testAuthorizationContextResourceExpiry)
                $script:result.Token | Should -Be $script:testAuthorizationHeaderResourceTokenSecureString
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
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCloud)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Account and Environment AzureUSGovernment parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account     = $script:testAccount
                    Database    = $script:testDatabase
                    Key         = $script:testKeySecureString
                    KeyType     = 'master'
                    Environment = 'AzureUSGovernment'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureUsGov)
                $script:result.Environment | Should -BeExactly 'AzureUSGovernment'
            }
        }

        Context 'When called with Account and Environment AzureChinaCloud parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account     = $script:testAccount
                    Database    = $script:testDatabase
                    Key         = $script:testKeySecureString
                    KeyType     = 'master'
                    Environment = 'AzureChinaCloud'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureChinaCloud)
                $script:result.Environment | Should -BeExactly 'AzureChinaCloud'
            }
        }

        Context 'When called with Account and custom endpoint Cloud parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account          = $script:testAccount
                    Database         = $script:testDatabase
                    Key              = $script:testKeySecureString
                    KeyType          = 'master'
                    EndpointHostname = $script:testBaseHostnameAzureCustomEndpoint
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Account parameters and Back-off Policy' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextBackoffPolicyParameters = @{
                    MaxRetries = $script:testMaxRetries
                    Method     = $script:testMethod
                    Delay      = $script:testDelay
                }

                $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                $newCosmosDbContextParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    Key           = $script:testKeySecureString
                    KeyType       = 'master'
                    BackoffPolicy = $script:backoffPolicy
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCloud)
                $script:result.BackoffPolicy.MaxRetries | Should -Be $script:testMaxRetries
                $script:result.BackoffPolicy.Method | Should -Be $script:testMethod
                $script:result.BackoffPolicy.Delay | Should -Be $script:testDelay
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with AzureAccount parameters and not connected to Azure and PrimaryMasterKey requested' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { throw }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'PrimaryMasterKey'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.Key | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCloud)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzContext -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-AzAccount `
                    -ParameterFilter { $Environment -eq 'AzureCloud' } `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CosmosDbAccountMasterKey `
                    -ParameterFilter { $MasterKeyType -eq 'PrimaryMasterKey' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with CustomAzureAccount parameters and not connected to Azure and PrimaryMasterKey requested' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { throw }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should throw expected exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                    EndpointHostname  = $script:testBaseHostnameAzureCustomEndpoint
                    MasterKeyType     = 'PrimaryMasterKey'
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message ($LocalizedData.NotLoggedInToCustomCloudException)

                {
                    $script:result = New-CosmosDbContext @newCosmosDbContextParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with AzureAccount and Environment AzureUSGovernment parameters and not connected to Azure and PrimaryMasterKey requested' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { throw }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'PrimaryMasterKey'
                    Environment       = 'AzureUSGovernment'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.Key | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureUsGov)
                $script:result.Environment | Should -BeExactly 'AzureUSGovernment'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzContext -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-AzAccount `
                    -ParameterFilter { $Environment -eq 'AzureUSGovernment' } `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CosmosDbAccountMasterKey `
                    -ParameterFilter { $MasterKeyType -eq 'PrimaryMasterKey' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with AzureAccount and Environment AzureChinaCloud parameters and not connected to Azure and PrimaryMasterKey requested' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { throw }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'PrimaryMasterKey'
                    Environment       = 'AzureChinaCloud'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.Key | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureChinaCloud)
                $script:result.Environment | Should -BeExactly 'AzureChinaCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzContext -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-AzAccount `
                    -ParameterFilter { $Environment -eq 'AzureChinaCloud' } `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CosmosDbAccountMasterKey `
                    -ParameterFilter { $MasterKeyType -eq 'PrimaryMasterKey' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with AzureAccount parameters and connected to Azure' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { $true }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.Key | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCloud)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzContext -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-AzAccount -Exactly -Times 0
                Assert-MockCalled -CommandName Get-CosmosDbAccountMasterKey `
                    -ParameterFilter { $MasterKeyType -eq 'PrimaryMasterKey' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with CustomAzureAccount parameters and connected to Custom Azure' {
            $script:result = $null

            Mock -CommandName Get-AzContext -MockWith { $true }
            Mock -CommandName Connect-AzAccount
            Mock `
                -CommandName Get-CosmosDbAccountMasterKey `
                -MockWith { $script:testKeySecureString }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account           = $script:testAccount
                    Database          = $script:testDatabase
                    ResourceGroupName = $script:testResourceGroupName
                    EndpointHostname  = $script:testBaseHostnameAzureCustomEndpoint
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.Key | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzContext -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-AzAccount -Exactly -Times 0
                Assert-MockCalled -CommandName Get-CosmosDbAccountMasterKey `
                    -ParameterFilter { $MasterKeyType -eq 'PrimaryMasterKey' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with Emulator switch' {
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
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -BeExactly 'master'
                $script:result.BaseUri | Should -BeExactly 'https://localhost:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with no protocol and port and Port parameter passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    Port     = '9999'
                    URI      = 'mycosmosdb.contoso.local'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:9999/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with no protocol and port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'mycosmosdb.contoso.local'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol but no port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'http://mycosmosdb.contoso.local'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'http://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with no protocol with port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'mycosmosdb.contoso.local:9999'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:9999/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol but no port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'https://mycosmosdb.contoso.local'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with no protocol with port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'mycosmosdb.contoso.local:9999'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:9999/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol but no port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'https://mycosmosdb.contoso.local'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with no protocol with port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'mycosmosdb.contoso.local:9999'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:9999/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol but no port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'https://mycosmosdb.contoso.local:8081'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol and port and Port parameter not passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'https://mycosmosdb.contoso.local:9999'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:9999/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI with protocol and port and Port parameter passed' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    Port     = '9999'
                    URI      = 'https://mycosmosdb.contoso.local:8081'
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://mycosmosdb.contoso.local:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with Emulator switch and URI and Key specified' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                    URI      = 'localhost'
                    Key      = $script:testKeySecureString
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'emulator'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be 'https://localhost:8081/'
                $script:result.Environment | Should -BeExactly 'AzureCloud'
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
                $script:result.Token[0].Resource | Should -Be $script:testAuthorizationContextResource
                $script:result.Token[0].TimeStamp | Should -Be $script:testDate
                $script:result.Token[0].Token | Convert-CosmosDbSecureStringToString | Should -Be $script:testAuthorizationHeaderResourceToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with CustomToken parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    Token    = $script:testContextToken
                    EndpointHostname = $script:testBaseHostnameAzureCustomEndpoint
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                $script:result.Token[0].Resource | Should -Be $script:testAuthorizationContextResource
                $script:result.Token[0].TimeStamp | Should -Be $script:testDate
                $script:result.Token[0].Token | Convert-CosmosDbSecureStringToString | Should -Be $script:testAuthorizationHeaderResourceToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with EntraIdToken parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    EntraIdToken = $script:testEntraIdTokenSecureString
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
                $script:result.Token | Should -BeNullOrEmpty
                $script:result.EntraIdToken | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with CustomEntraIdToken parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    EndpointHostname = $script:testBaseHostnameAzureCustomEndpoint
                    EntraIdToken = $script:testEntraIdTokenSecureString
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                $script:result.Token | Should -BeNullOrEmpty
                $script:result.EntraIdToken | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }
        }

        Context 'When called with EntraIdTokenAutoGen parameters' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    EndpointHostname = $script:testBaseHostnameAzureCustomEndpoint
                    AutoGenerateEntraIdToken = $true
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                $script:result.Token | Should -BeNullOrEmpty
                $script:result.EntraIdToken | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter {
                        $AsSecureString -and `
                        $ResourceUrl -eq ('https://{0}.{1}' -f $script:testAccount, $script:testBaseHostnameAzureCustomEndpoint)
                    }
            }
        }

        Context 'When called with CustomEntraIdTokenAutoGen parameters' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    AutoGenerateEntraIdToken = $true
                    Verbose  = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
                $script:result.Token | Should -BeNullOrEmpty
                $script:result.EntraIdToken | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
                $script:result.Environment | Should -BeExactly 'AzureCloud'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter {
                        $AsSecureString -and `
                        $ResourceUrl -eq ('https://{0}.documents.azure.com' -f $script:testAccount)
                    }
            }
        }

        Context 'When called with Connection String parameter' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    ConnectionString = ($script:testConnectionString | ConvertTo-SecureString -AsPlainText -Force)
                    Database = $script:testDatabase
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
                $script:result.Environment | Should -BeExactly 'AzureCloud'
                $script:result.Key | Should -BeOfType [System.Security.SecureString]
                $decryptedConnectionString = $script:result.Key | Convert-CosmosDbSecureStringToString
                $decryptedConnectionString | Should -BeExactly $script:testKey
                $script:result.KeyType | Should -BeExactly 'master'
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
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureCloud)
            }
        }

        Context 'When called with Account and BaseUri parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                    BaseHostname = $script:testBaseHostname
                    Verbose = $true
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostname)
            }
        }

        Context 'When called with Account and AzureUSGovernment Environment parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account     = $script:testAccount
                    Environment = [CosmosDb.Environment]::AzureUSGovernment
                    Verbose     = $true
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureUsGov)
            }
        }

        Context 'When called with Account and AzureChinaCloud Environment parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account     = $script:testAccount
                    Environment = [CosmosDb.Environment]::AzureChinaCloud
                    Verbose     = $true
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseHostnameAzureChinaCloud)
            }
        }
    }

    Describe 'Get-CosmosDbRequestExceptionString' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbRequestExceptionString -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called in PowerShell Core with ErrorDetails' {
            Mock -CommandName Get-Variable -MockWith {
                return @{
                    Name = 'PSEdition'
                    Value = 'Core'
                }
            }
            $script:result = $null

            It 'Should not throw exception' {
                $exception = [System.Exception]::new('PowerShell Core Exception')
                $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'CoreErrorId', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)
                $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('Core Error Details')

                {
                    $script:result = Get-CosmosDbRequestExceptionString -ErrorRecord $errorRecord
                } | Should -Not -Throw
            }

            It 'Should return ErrorDetails' {
                $script:result | Should -Be 'Core Error Details'
            }
        }

        Context 'When called with ErrorRecord missing Response in Windows PowerShell' {
            Mock -CommandName Get-Variable -MockWith {
                return @{
                    Name = 'PSEdition'
                    Value = 'Core'
                }
            }
            $script:result = $null

            It 'Should not throw exception' {
                $webException = [System.Net.WebException]::new('Windows PowerShell Exception')
                $errorRecord = [System.Management.Automation.ErrorRecord]::new($webException, 'WindowsErrorId', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)

                {
                    $script:result = Get-CosmosDbRequestExceptionString -ErrorRecord $errorRecord
                } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
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

    Describe 'Get-CosmosDbAuthorizationHeaderFromContext' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAuthorizationHeaderFromContext } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/testdb'
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContext @getCosmosDbAuthorizationHeaderFromContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result.authorization | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dr3RhzxX7rv4ZHqo4aT1jDszfV7svQ7JFXoi7hz1Iwto%3d'
                $script:result.'x-ms-date' | Should -Be $script:testUniversalDate
            }
        }

        Context 'When called with all parameters and mixed case ResourceId' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/Testdb'
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContext @getCosmosDbAuthorizationHeaderFromContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result.authorization | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dncZem2Awq%2b0LkrQ7mlwJePX%2f2qyEPG3bQDrnuedrjZU%3d'
                $script:result.'x-ms-date' | Should -Be $script:testUniversalDate
            }
        }
    }

    Describe 'Get-CosmosDbAuthorizationHeaderFromContextResourceToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAuthorizationHeaderFromContextResourceToken } | Should -Not -Throw
        }

        Context 'When called with a context without any resource tokens' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters = @{
                    Context      = $script:testEntraIdContext
                    ResourceLink = $script:testAuthorizationContextResource
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContextResourceToken @getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }
        }

        Context 'When called with a context that contains a resource token that matches the resource link and is not expired' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters = @{
                    Context      = $script:testResourceContext
                    ResourceLink = $script:testAuthorizationContextResource
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContextResourceToken @getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result.authorization | Should -Be ([System.Web.HttpUtility]::UrlEncode($script:testAuthorizationHeaderResourceToken))
                # The date is not the same as the test date because the date format ends up being different on Azure DevOps pipelines vs. Local
                # $script:result.'x-ms-date' | Should -Be $script:testUniversalDate
            }
        }

        Context 'When called with a context that contains a resource token that matches the resource link but has expired' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters = @{
                    Context      = $script:testResourceContextExpired
                    ResourceLink = $script:testAuthorizationContextResource
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContextResourceToken @getCosmosDbAuthorizationHeaderFromContextResourceTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -BeNullOrEmpty
            }
        }
    }

    Describe 'Get-CosmosDbAuthorizationHeaderFromContextEntraId' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAuthorizationHeaderFromContextEntraId } | Should -Not -Throw
        }

        Context 'When called with a context containing an EntraIdToken' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextEntraIdParameters = @{
                    Context      = $script:testEntraIdContext
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContextEntraId @getCosmosDbAuthorizationHeaderFromContextEntraIdParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result.authorization | Should -Be ([System.Web.HttpUtility]::UrlEncode($script:testAuthorizationHeaderEntraIdToken))
                $script:result.'x-ms-date' | Should -Be $script:testUniversalDate
            }
        }

        Context 'When called with a context that does not contain an EntraIdToken' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAuthorizationHeaderFromContextEntraIdParameters = @{
                    Context      = $script:testResourceContext
                    Date         = $script:testUniversalDate
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbAuthorizationHeaderFromContextEntraId @getCosmosDbAuthorizationHeaderFromContextEntraIdParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -BeNullOrEmpty
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

        Context 'When called with context parameter with Entra ID Token and Get method and ResourceType is ''dbs''' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                    $Uri -eq ('{0}{1}' -f $script:testContext.BaseUri, 'dbs')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testEntraIdContext
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

        Context 'When called with context parameter and Post method and Encoding set to UTF-8' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ContentType -eq 'application/json; charset=UTF-8' -and `
                    $Uri -eq ('{0}dbs/{1}/colls/{2}/docs' -f $script:testContext.BaseUri, $script:testContext.Database, 'anotherCollection')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -MockWith $InvokeWebRequest_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Post'
                    ResourceType = 'docs'
                    ResourcePath = ('colls/{0}/docs' -f 'anotherCollection')
                    ContentType  = 'application/json'
                    Body         = "{ `"id`": `"daniel`", `"content`": `"我能吞下玻璃而不伤身`" }"
                    Encoding     = 'UTF-8'
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

        Context 'When called with context parameter and Get method but System.Net.WebException exception is thrown' {
            $InvokeWebRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ContentType -eq 'application/json' -and `
                                       $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri, $script:testContext.Database, 'users')
            }

            Mock `
                -CommandName Invoke-WebRequest `
                -MockWith { throw [System.Net.WebException] 'Test Exception' }

            $script:result = $null

            It 'Should throw exception expected exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'users'
                    Verbose      = $true
                }

                { $script:result = (Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters).Content | ConvertFrom-Json } | Should -Throw 'Test Exception'
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

    Describe 'Get-CosmosDbBackoffDelay' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbBackoffDelay -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with unspecified back-off policy' {
            Context 'Retry number 1 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $script:backoffPolicy = New-CosmosDbBackoffPolicy

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 1
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 100ms' {
                    $script:result | Should -Be 100
                }
            }

            Context 'Retry number 11 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $script:backoffPolicy = New-CosmosDbBackoffPolicy

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 11
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:result | Should -BeNull
                }
            }
        }

        Context 'When called with Default back-off policy and delay 500ms' {
            Context 'Retry number 1 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Delay = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 1
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 500ms' {
                    $script:result | Should -Be 500
                }
            }

            Context 'Retry number 1 and RequestedDelay is 2000ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Delay = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 1
                        RequestedDelay = 2000
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 2000ms' {
                    $script:result | Should -Be 2000
                }
            }
        }

        Context 'When called with Additive back-off policy and delay 500ms' {
            Context 'Retry number 1 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Method = 'Additive'
                        Delay  = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 1
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 600ms' {
                    $script:result | Should -Be 600
                }
            }
        }

        Context 'When called with Linear back-off policy and delay 500ms' {
            Context 'Retry number 0 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Method = 'Linear'
                        Delay  = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 0
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 500ms' {
                    $script:result | Should -Be 500
                }
            }

            Context 'Retry number 1 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Method = 'Linear'
                        Delay  = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 1
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 1000ms' {
                    $script:result | Should -Be 1000
                }
            }
        }

        Context 'When called with Exponential back-off policy and delay 500ms' {
            Context 'Retry number 0 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Method = 'Exponential'
                        Delay  = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 0
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 500ms' {
                    $script:result | Should -Be 500
                }
            }

            Context 'Retry number 4 and RequestedDelay is 100ms' {
                $script:result = $null

                It 'Should not throw exception' {
                    $newCosmosDbContextBackoffPolicyParameters = @{
                        Method = 'Exponential'
                        Delay  = 500
                    }

                    $script:backoffPolicy = New-CosmosDbBackoffPolicy @newCosmosDbContextBackoffPolicyParameters

                    $getCosmosDbBackoffDelayParameters = @{
                        BackoffPolicy  = $script:backoffPolicy
                        Retry          = 4
                        RequestedDelay = 100
                        Verbose        = $true
                    }

                    { $script:result = Get-CosmosDbBackoffDelay @getCosmosDbBackoffDelayParameters } | Should -Not -Throw
                }

                It 'Should return 12500msms' {
                    $script:result | Should -Be 12500
                }
            }
        }
    }

    Describe 'Convert-CosmosDbRequestBody' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Convert-CosmosDbRequestBody -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with paramters' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertCosmosDbRequestBodyParameters = @{
                    RequestBodyObject = $script:testRequestObject
                    Verbose           = $true
                }

                { $script:result = Convert-CosmosDbRequestBody @convertCosmosDbRequestBodyParameters } | Should -Not -Throw
            }

            <#
                This test will only pass on PowerShell 5.x because of
                a difference in PowerShell Core 6.0.x.

                See https://github.com/PowerShell/PowerShell/issues/7693
            #>
            $skip = ($PSVersionTable.PSEdition -eq 'Core')

            It 'Should return expected result' -Skip:$skip {
                $script:result | Should -Be $script:testRequestBodyJson
            }
        }
    }

    Describe 'Repair-CosmosDbDocumentEncoding' -Tag 'Unit' {
        Context 'When an ASCII string is passed' {
            It 'Should return the correct string' {
                Repair-CosmosDbDocumentEncoding -Content 'AsciiString' | Should -Be 'AsciiString'
            }
        }
    }

    Describe 'Get-CosmosDbResponseHeaderAttribute' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbResponseHeaderAttribute -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a response header that contains a header-value attribute with value result' {
            It 'Should not throw exception' {
                $getCosmosDbResponseHeaderAttirbuteParameters = @{
                    ResponseHeader = @{
                        'header-value' = 'result'
                    }
                    HeaderName     = 'header-value'
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbResponseHeaderAttribute @getCosmosDbResponseHeaderAttirbuteParameters } | Should -Not -Throw
            }

            It 'Should return result' {
                $script:result | Should -Be 'result'
            }
        }

        Context 'When called with a response header that contains a header-value attribute with a blank value' {
            It 'Should not throw exception' {
                $getCosmosDbResponseHeaderAttirbuteParameters = @{
                    ResponseHeader = @{
                        'header-value' = ''
                    }
                    HeaderName     = 'header-value'
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbResponseHeaderAttribute @getCosmosDbResponseHeaderAttirbuteParameters } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }
        }

        Context 'When called with a response header that does not contain a header-value attribute' {
            It 'Should not throw exception' {
                $getCosmosDbResponseHeaderAttirbuteParameters = @{
                    ResponseHeader = @{
                        'not-value' = 'value does not matter'
                    }
                    HeaderName     = 'header-value'
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbResponseHeaderAttribute @getCosmosDbResponseHeaderAttirbuteParameters } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }
        }
    }

    Describe 'Get-CosmosDbContinuationToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbContinuationToken -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a response header that contains an x-ms-continuation attribute with a valid token' {
            It 'Should not throw exception' {
                $getCosmosDbContinuationTokenParameters = @{
                    ResponseHeader = @{
                        'x-ms-continuation' = 'token'
                    }
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbContinuationToken @getCosmosDbContinuationTokenParameters } | Should -Not -Throw
            }

            It 'Should return token' {
                $script:result | Should -Be 'token'
            }
        }

        Context 'When called with a response header that contains an x-ms-continuation attribute with a blank token' {
            It 'Should not throw exception' {
                $getCosmosDbContinuationTokenParameters = @{
                    ResponseHeader = @{
                        'x-ms-continuation' = ''
                    }
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbContinuationToken @getCosmosDbContinuationTokenParameters } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }
        }

        Context 'When called with a response header that does not contain an x-ms-continuation attribute' {
            It 'Should not throw exception' {
                $getCosmosDbContinuationTokenParameters = @{
                    ResponseHeader = @{
                        'not-continuation' = 'not a token'
                    }
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbContinuationToken @getCosmosDbContinuationTokenParameters } | Should -Not -Throw
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }
        }
    }

    Describe 'Get-CosmosDbEntraIdToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbEntraIdToken -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called without endpoint specified' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                { $script:result = Get-CosmosDbEntraIdToken } | Should -Not -Throw
            }

            It 'Should return a secure string' {
                $script:result | Should -BeOfType [System.Security.SecureString]
            }

            It 'Should return secure string containing the expected token' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter {
                        $AsSecureString -and
                        $ResourceUrl -eq 'https://cosmos.azure.com'
                    }
            }
        }

        Context 'When called with endpoint specified' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                $getCosmosDbEntraIdTokenParameters = @{
                    Endpoint = 'https://cdbtest1pzqjjk3jfe.documents.azure.com'
                }
                { $script:result = Get-CosmosDbEntraIdToken @getCosmosDbEntraIdTokenParameters } | Should -Not -Throw
            }

            It 'Should return a secure string' {
                $script:result | Should -BeOfType [System.Security.SecureString]
            }

            It 'Should return secure string containing the expected token' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter { $ResourceUrl -eq 'https://cdbtest1pzqjjk3jfe.documents.azure.com' }
            }
        }

        Context 'When called with endpoint specified ending with a /' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return @{
                    Token = $script:testEntraIdTokenSecureString
                }
            }

            It 'Should not throw exception' {
                $getCosmosDbEntraIdTokenParameters = @{
                    Endpoint = 'https://cdbtest1pzqjjk3jfe.documents.azure.com/'
                }
                { $script:result = Get-CosmosDbEntraIdToken @getCosmosDbEntraIdTokenParameters } | Should -Not -Throw
            }

            It 'Should return a secure string' {
                $script:result | Should -BeOfType [System.Security.SecureString]
            }

            It 'Should return secure string containing the expected token' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testEntraIdToken
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter { $ResourceUrl -eq 'https://cdbtest1pzqjjk3jfe.documents.azure.com' }
            }
        }

        Context 'When called, but an Azure Context is not connected' {
            $script:result = $null

            Mock Get-AzAccessToken -MockWith {
                return $null
            }

            $errorRecord = Get-InvalidOperationRecord `
                -Message ($LocalizedData.ErrorGettingEntraIdToken -f 'https://cosmos.azure.com')

            It 'Should throw expected exception' {
                {
                    $script:result = Get-CosmosDbEntraIdToken
                } | Should -Throw $errorRecord
            }

            It 'Should return null' {
                $script:result | Should -BeNullOrEmpty
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Get-AzAccessToken -Exactly -Times 1 `
                    -ParameterFilter { $ResourceUrl -eq 'https://cosmos.azure.com' }
            }
        }
    }

    Describe 'New-CosmosDbResponseException' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbResponseException -ErrorAction Stop } | Should -Not -Throw
        }

        # PowerShell 7 test – Microsoft.PowerShell.Commands.HttpResponseException
        Context 'When called with HttpResponseException on PowerShell 7.x' {
            $script:skipHttpResponseException = -not ((Get-Variable -Name 'PSEdition').Value -eq 'Core')
            if ($script:skipHttpResponseException)
            {
                Write-Verbose -Message 'Skipping HttpResponseException test on PowerShell 5.x'
            }

            $script:result = $null

            It 'Should not throw exception' -Skip:$script:skipHttpResponseException {
                {
                    $script:httpResponseMessage = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
                    $script:httpResponseException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('Bad Request', $script:httpResponseMessage)

                    $script:result = New-CosmosDbResponseException -InputObject $script:httpResponseException
                } | Should -Not -Throw
            }

            It 'Should return expected CosmosDB.ResponseException' -Skip:$script:skipHttpResponseException {
                $script:result | Should -BeOfType 'CosmosDB.ResponseException'
                $script:result.Message | Should -Be $script:httpResponseException.Message
            }
        }

        # PowerShell 5.x - test System.Net.WebException
        Context 'When called with WebException containing HttpWebResponse' {
            <#
                It is difficult to create a HttpWebResponse mock, so unit testing
                isn't possible. Rely on Integration tests to verify this scenario.
            #>
            Write-Verbose -Message 'Skipping WebException test as it is not possible to mock HttpWebResponse.'

            It 'Should not throw exception' -Skip:$true {
            }

            It 'Should return expected CosmosDB.ResponseException' -Skip:$true {
            }
        }

        # Other exception type
        Context 'When called with non web exception type' {
            It 'Should not throw exception' {
                {
                    $script:testException = [System.Exception]::new('Test Exception')

                    $script:result = New-CosmosDbResponseException -InputObject $script:testException
                } | Should -Not -Throw
            }

            It 'Should return expected CosmosDB.ResponseException' {
                $script:result | Should -BeOfType 'CosmosDB.ResponseException'
                $script:result.Message | Should -Be $script:testException.Message
            }
        }
    }
}
