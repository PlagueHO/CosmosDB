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
    $script:testName = 'testName'
    $script:testResourceGroupName = 'testResourceGroupName'
    $script:testLocation = 'North Central US'
    $script:testLocationRead1 = 'South Central US'
    $script:testLocationRead2 = 'East US'
    $script:testIpRangeFilter = @('10.0.0.1/8', '10.0.0.2/8')
    $script:testConsistencyLevel = 'Strong'
    $script:testMaxIntervalInSeconds = 60
    $script:testMaxStalenessPrefix = 900
    $script:testCapability = @('EnableServerless', 'EnableCassandra')
    $script:testCorsAllowedOrigins = @('https://www.contoso.com', 'https://www.fabrikam.com')
    $script:mockGetAzResource = @{
        ResourceId = 'ignore'
        Id         = 'ignore'
        Kind       = 'GlobalDocumentDB'
        Location   = 'North Central US'
        Name       = $script:testName
        Properties = @{
            provisioningState             = 'Succeeded'
            documentEndpoint              = "https://$script:testName.documents.azure.com:443/"
            ipRangeFilter                 = ''
            enableAutomaticFailover       = $false
            enableMultipleWriteLocations  = $false
            isVirtualNetworkFilterEnabled = $false
            virtualNetworkRules           = @()
            databaseAccountOfferType      = 'Standard'
            consistencyPolicy             = @{
                defaultConsistencyLevel = 'Session'
                maxIntervalInSeconds    = 5
                maxStalenessPrefix      = 100
            }
            configurationOverrides        = @{}
            writeLocations                = @(
                @{
                    id                = "$script:testLocation-northcentralus"
                    locationName      = $script:testLocation
                    documentEndpoint  = "https://$script:testLocation-northcentralus.documents.azure.com:443/"
                    provisioningState = 'Succeeded'
                    failoverPriority  = 0
                }
            )
            readLocations                 = @(
                @{
                    id                = "$script:testLocation-northcentralus"
                    locationName      = $script:testLocation
                    documentEndpoint  = "https://$script:testLocation-northcentralus.documents.azure.com:443/"
                    provisioningState = 'Succeeded'
                    failoverPriority  = 0
                }
            )
            failoverPolicies              = @(
                @{
                    id               = "$script:testLocation-northcentralus"
                    locationName     = $script:testLocation
                    failoverPriority = 0
                }
            )
            cors                          = @(
                @{
                    allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                }
            )
            capabilities                  = @(@{name = $script:testCapability})
            ResourceGroupName             = $script:testResourceGroupName
            ResourceType                  = 'Microsoft.DocumentDB/databaseAccounts'
            Sku                           = $null
            Tags                          = @{}
            Type                          = 'Microsoft.DocumentDB/databaseAccounts'
        }
    }
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:mockInvokeAzResourceActionConnectionString = {
        @{
            ConnectionStrings = @(
                [PSCustomObject] @{
                    connectionString = 'AccountEndpoint=Primary SQL Connection String'
                    description = 'Primary SQL Connection String'
                },
                [PSCustomObject] @{
                    connectionString = 'AccountEndpoint=Secondary SQL Connection String'
                    description = 'Secondary SQL Connection String'
                },
                [PSCustomObject] @{
                    connectionString = 'AccountEndpoint=Primary Read-Only SQL Connection String'
                    description = 'Primary Read-Only SQL Connection String'
                }
                [PSCustomObject] @{
                    connectionString = 'AccountEndpoint=Secondary Read-Only SQL Connection String'
                    description = 'Secondary Read-Only SQL Connection String'
                }
            )
        }
    }

    Describe 'Assert-CosmosDbAccountNameValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbAccountNameValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid name' {
            It 'Should return $true' {
                Assert-CosmosDbAccountNameValid -Name 'validaccountname' | Should -Be $true
            }
        }

        Context 'When called with a 2 character name' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AccountNameInvalid -f ('a' * 2)) `
                    -ArgumentName 'Name'

                {
                    Assert-CosmosDbAccountNameValid -Name ('a' * 2)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with a 51 character name' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AccountNameInvalid -f ('a' * 51)) `
                    -ArgumentName 'Name'

                {
                    Assert-CosmosDbAccountNameValid -Name ('a' * 51)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called containing an underscore' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AccountNameInvalid -f 'a_b') `
                    -ArgumentName 'Name'

                {
                    Assert-CosmosDbAccountNameValid -Name 'a_b'
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called containing a period' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AccountNameInvalid -f 'a.b') `
                    -ArgumentName 'Name'

                {
                    Assert-CosmosDbAccountNameValid -Name 'a.b'
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid name and an argument is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AccountNameInvalid -f 'a.b') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbAccountNameValid -Name 'a.b' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Assert-CosmosDbResourceGroupNameValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbResourceGroupNameValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid resource group name' {
            It 'Should return $true' {
                Assert-CosmosDbResourceGroupNameValid -ResourceGroupName 'valid_resource-group.name123' | Should -Be $true
            }
        }

        Context 'When called with a 91 character resource group name' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.ResourceGroupNameInvalid -f ('a' * 91)) `
                    -ArgumentName 'ResourceGroupName'

                {
                    Assert-CosmosDbResourceGroupNameValid -ResourceGroupName ('a' * 91)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with resource group name containing an exclamation' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.ResourceGroupNameInvalid -f 'a!') `
                    -ArgumentName 'ResourceGroupName'

                {
                    Assert-CosmosDbResourceGroupNameValid -ResourceGroupName 'a!'
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with resource group name ending in a period' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.ResourceGroupNameInvalid -f 'a.') `
                    -ArgumentName 'ResourceGroupName'

                {
                    Assert-CosmosDbResourceGroupNameValid -ResourceGroupName 'a.'
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid resource group name and an argument is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.ResourceGroupNameInvalid -f 'a.') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbResourceGroupNameValid -ResourceGroupName 'a.' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName' {
            $script:result = $null

            <#
                Due to the inconsistent name of the ResourceName parameter in Get-CosmosDbAccount
                in different versions we need to look for both in the mock.
            #>
            $getAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                (($ResourceName -eq $script:testName) -or ($Name -eq $script:testName)) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $getCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Verbose           = $true
                }

                { $script:result = Get-CosmosDbAccount @getCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Get-AzResource `
                    -ParameterFilter $getAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Location specified only with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location specified and AsJob' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                ($AsJob -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    AsJob             = $true
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and LocationRead specified with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    },
                    @{
                        locationName     = $script:testLocationRead1
                        failoverPriority = 1
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    LocationRead      = $script:testLocationRead1
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and two LocationRead specified with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    },
                    @{
                        locationName     = $script:testLocationRead1
                        failoverPriority = 1
                    },
                    @{
                        locationName     = $script:testLocationRead2
                        failoverPriority = 2
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    LocationRead      = @( $script:testLocationRead1, $script:testLocationRead2 )
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and IpRangeFilter specified and other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ($script:testIpRangeFilter -join ',')
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    IpRangeFilter     = $script:testIpRangeFilter
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location, DefaultConsistencyLevel, MaxIntervalInSeconds and MaxStalenessPrefix specified' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = $script:testConsistencyLevel
                    maxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    maxStalenessPrefix      = $script:testMaxStalenessPrefix
                }
                ipRangeFilter            = ''
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name                    = $script:testName
                    ResourceGroupName       = $script:testResourceGroupName
                    Location                = $script:testLocation
                    DefaultConsistencyLevel = $script:testConsistencyLevel
                    MaxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    MaxStalenessPrefix      = $script:testMaxStalenessPrefix
                    Verbose                 = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and AllowedOrigin specified and other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    AllowedOrigin     = $script:testCorsAllowedOrigins
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location specified and the EnableServerless and EnableCassandra capabilities' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                capabilities             = @(
                    @{
                        name = 'EnableServerless'
                    },
                    @{
                        name = 'EnableCassandra'
                    }
                )
            }

            $newAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzResource `
                -MockWith { 'Account' }

            It 'Should not throw exception' {
                $newCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    Capability        = $script:testCapability
                    Verbose           = $true
                }

                { $script:result = New-CosmosDbAccount @newCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName New-AzResource `
                    -ParameterFilter $newAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Location specified only with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location specified and AsJob' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($AsJob -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    AsJob             = $true
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and LocationRead specified with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    },
                    @{
                        locationName     = $script:testLocationRead1
                        failoverPriority = 1
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    LocationRead      = $script:testLocationRead1
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and two LocationRead specified with other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    },
                    @{
                        locationName     = $script:testLocationRead1
                        failoverPriority = 1
                    },
                    @{
                        locationName     = $script:testLocationRead2
                        failoverPriority = 2
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    LocationRead      = @( $script:testLocationRead1, $script:testLocationRead2 )
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and IpRangeFilter specified and other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ($script:testIpRangeFilter -join ',')
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    IpRangeFilter     = $script:testIpRangeFilter
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location, DefaultConsistencyLevel, MaxIntervalInSeconds and MaxStalenessPrefix specified' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = $script:testConsistencyLevel
                    maxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    maxStalenessPrefix      = $script:testMaxStalenessPrefix
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name                    = $script:testName
                    ResourceGroupName       = $script:testResourceGroupName
                    Location                = $script:testLocation
                    DefaultConsistencyLevel = $script:testConsistencyLevel
                    MaxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    MaxStalenessPrefix      = $script:testMaxStalenessPrefix
                    Verbose                 = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and DefaultConsistencyLevel specified' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = $script:testConsistencyLevel
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name                    = $script:testName
                    ResourceGroupName       = $script:testResourceGroupName
                    Location                = $script:testLocation
                    DefaultConsistencyLevel = $script:testConsistencyLevel
                    Verbose                 = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and MaxIntervalInSeconds specified' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource } `
                -Verifiable

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name                 = $script:testName
                    ResourceGroupName    = $script:testResourceGroupName
                    Location             = $script:testLocation
                    MaxIntervalInSeconds = $script:testMaxIntervalInSeconds
                    Verbose              = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Location and AllowedOrigins specified and other parameters default' {
            $script:result = $null
            $testCosmosDBProperties = @{
                databaseAccountOfferType = 'Standard'
                locations                = @(
                    @{
                        locationName     = $script:testLocation
                        failoverPriority = 0
                    }
                )
                consistencyPolicy        = @{
                    defaultConsistencyLevel = 'Session'
                    maxIntervalInSeconds    = 5
                    maxStalenessPrefix      = 100
                }
                ipRangeFilter            = ''
                cors                     = @(
                    @{
                        allowedOrigins = ($script:testCorsAllowedOrigins -join ',')
                    }
                )
            }

            $setAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                ($Properties.databaseAccountOfferType -eq $testCosmosDBProperties.databaseAccountOfferType) -and `
                ($Properties.locations[0].locationName -eq $testCosmosDBProperties.locations[0].locationName) -and `
                ($Properties.locations[0].failoverPriority -eq $testCosmosDBProperties.locations[0].failoverPriority) -and `
                ($Properties.consistencyPolicy.defaultConsistencyLevel -eq $testCosmosDBProperties.consistencyPolicy.defaultConsistencyLevel) -and `
                ($Properties.consistencyPolicy.maxStalenessPrefix -eq $testCosmosDBProperties.consistencyPolicy.maxStalenessPrefix) -and `
                ($Properties.consistencyPolicy.maxIntervalInSeconds -eq $testCosmosDBProperties.consistencyPolicy.maxIntervalInSeconds) -and `
                ($Properties.ipRangeFilter -eq $testCosmosDBProperties.ipRangeFilter) -and `
                ($Properties.cors.allowedOrigins -eq $testCosmosDBProperties.cors.allowedOrigins)
            }

            Mock `
                -CommandName Set-AzResource `
                -MockWith { 'Account' }

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -MockWith { $script:mockGetAzResource }

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Location          = $script:testLocation
                    AllowedOrigin     = $script:testCorsAllowedOrigins
                    Verbose           = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Set-AzResource `
                    -ParameterFilter $setAzResource_parameterFilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName' {
            $script:result = $null

            $removeAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Remove-AzResource

            It 'Should not throw exception' {
                $removeCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Force             = $true
                    Verbose           = $true
                }

                { $script:result = Remove-CosmosDbAccount @removeCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Remove-AzResource `
                    -ParameterFilter $removeAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Name and ResourceGroupName and AsJob' {
            $script:result = $null

            $removeAzResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($AsJob -eq $true) -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Remove-AzResource

            It 'Should not throw exception' {
                $removeCosmosDbAccountParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    AsJob             = $true
                    Force             = $true
                    Verbose           = $true
                }

                { $script:result = Remove-CosmosDbAccount @removeCosmosDbAccountParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Remove-AzResource `
                    -ParameterFilter $removeAzResource_parameterFilter `
                    -Exactly -Times 1
            }
        }
    }

    Context 'When called with a Name and ResourceGroupName and MasterKeyType is default' {
        $script:result = $null

        $invokeAzResourceAction_parameterFilter = {
            ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
            ($ApiVersion -eq '2015-04-08') -and `
            ($ResourceName -eq $script:testName) -and `
            ($ResourceGroupName -eq $script:testResourceGroupName) -and `
            ($Action -eq 'listConnectionStrings') -and `
            ($Force -eq $true)
        }

        Mock `
            -CommandName Invoke-AzResourceAction `
            -MockWith $script:mockInvokeAzResourceActionConnectionString

        It 'Should not throw exception' {
            $getCosmosDbAccountConnectionStringParameters = @{
                Name              = $script:testName
                ResourceGroupName = $script:testResourceGroupName
                Verbose           = $true
            }

            { $script:result = Get-CosmosDbAccountConnectionString @getCosmosDbAccountConnectionStringParameters } | Should -Not -Throw
        }

        It 'Should return expected result' {
            $script:result | Should -Be 'AccountEndpoint=Primary SQL Connection String'
        }

        It 'Should call expected mocks' {
            Assert-MockCalled `
                -CommandName Invoke-AzResourceAction `
                -ParameterFilter $invokeAzResourceAction_parameterFilter `
                -Exactly -Times 1
        }
    }

    Describe 'Get-CosmosDbAccountConnectionString' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAccountConnectionString -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName and MasterKeyType set to SecondaryReadonlyMasterKey' {
            $script:result = $null

            $invokeAzResourceAction_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Action -eq 'listConnectionStrings') -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Invoke-AzResourceAction `
                -MockWith $script:mockInvokeAzResourceActionConnectionString

            It 'Should not throw exception' {
                $getCosmosDbAccountConnectionStringParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'SecondaryReadonlyMasterKey'
                    Verbose           = $true
                }

                { $script:result = Get-CosmosDbAccountConnectionString @getCosmosDbAccountConnectionStringParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'AccountEndpoint=Secondary Read-Only SQL Connection String'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-AzResourceAction `
                    -ParameterFilter $invokeAzResourceAction_parameterFilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Get-CosmosDbAccountMasterKey' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAccountMasterKey -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName with a MasterKeyType is Default' {
            $script:result = $null

            $invokeAzResourceAction_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Action -eq 'listKeys') -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Invoke-AzResourceAction `
                -MockWith {
                [PSCustomObject] @{ PrimaryMasterKey = $script:testKey}
            }

            It 'Should not throw exception' {
                $getCosmosDbAccountMasterKeyParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    Verbose           = $true
                }

                { $script:result = Get-CosmosDbAccountMasterKey @getCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-AzResourceAction `
                    -ParameterFilter $invokeAzResourceAction_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Name and ResourceGroupName with a MasterKeyType is SecondaryMasterKey' {
            $script:result = $null

            $invokeAzResourceAction_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Action -eq 'listKeys') -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Invoke-AzResourceAction `
                -MockWith {
                [PSCustomObject] @{ SecondaryMasterKey = $script:testKey}
            }

            It 'Should not throw exception' {
                $getCosmosDbAccountMasterKeyParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'SecondaryMasterKey'
                    Verbose           = $true
                }

                { $script:result = Get-CosmosDbAccountMasterKey @getCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-AzResourceAction `
                    -ParameterFilter $invokeAzResourceAction_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with a Name and ResourceGroupName with a MasterKeyType is PrimaryReadonlyMasterKey' {
            $script:result = $null

            $invokeAzResourceAction_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($ResourceName -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Action -eq 'readonlykeys') -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Invoke-AzResourceAction `
                -MockWith {
                [PSCustomObject] @{ PrimaryReadonlyMasterKey = $script:testKey}
            }

            It 'Should not throw exception' {
                $getCosmosDbAccountMasterKeyParameters = @{
                    Name              = $script:testName
                    ResourceGroupName = $script:testResourceGroupName
                    MasterKeyType     = 'PrimaryReadonlyMasterKey'
                    Verbose           = $true
                }

                { $script:result = Get-CosmosDbAccountMasterKey @getCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Convert-CosmosDbSecureStringToString | Should -Be $script:testKey
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-AzResourceAction `
                    -ParameterFilter $invokeAzResourceAction_parameterFilter `
                    -Exactly -Times 1
            }
        }

        Describe 'New-CosmosDbAccountMasterKey' -Tag 'Unit' {
            It 'Should exist' {
                { Get-Command -Name New-CosmosDbAccountMasterKey -ErrorAction Stop } | Should -Not -Throw
            }

            Context 'When called with a Name and ResourceGroupName with a MasterKeyType is Default' {
                $script:result = $null

                $invokeAzResourceAction_parameterFilter = {
                    ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                    ($ApiVersion -eq '2015-04-08') -and `
                    ($ResourceName -eq $script:testName) -and `
                    ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                    ($Action -eq 'regenerateKey') -and `
                    ($Parameters['keyKind'] -eq 'Primary')
                    ($Force -eq $true)
                }

                Mock `
                    -CommandName Invoke-AzResourceAction `
                    -MockWith {
                    [PSCustomObject] @{ PrimaryMasterKey = $script:testKey}
                }

                It 'Should not throw exception' {
                    $newCosmosDbAccountMasterKeyParameters = @{
                        Name              = $script:testName
                        ResourceGroupName = $script:testResourceGroupName
                        Verbose           = $true
                    }

                    { $script:result = New-CosmosDbAccountMasterKey @newCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Invoke-AzResourceAction `
                        -ParameterFilter $invokeAzResourceAction_parameterFilter `
                        -Exactly -Times 1
                }
            }

            Context 'When called with a Name and ResourceGroupName with a MasterKeyType is SecondaryMasterKey' {
                $script:result = $null

                $invokeAzResourceAction_parameterFilter = {
                    ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                    ($ApiVersion -eq '2015-04-08') -and `
                    ($ResourceName -eq $script:testName) -and `
                    ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                    ($Action -eq 'regenerateKey') -and `
                    ($Parameters['keyKind'] -eq 'Secondary')
                    ($Force -eq $true)
                }

                Mock `
                    -CommandName Invoke-AzResourceAction `
                    -MockWith {
                    [PSCustomObject] @{ PrimaryMasterKey = $script:testKey}
                }

                It 'Should not throw exception' {
                    $newCosmosDbAccountMasterKeyParameters = @{
                        Name              = $script:testName
                        ResourceGroupName = $script:testResourceGroupName
                        Verbose           = $true
                    }

                    { $script:result = New-CosmosDbAccountMasterKey @newCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Invoke-AzResourceAction `
                        -ParameterFilter $invokeAzResourceAction_parameterFilter `
                        -Exactly -Times 1
                }
            }

            Context 'When called with a Name and ResourceGroupName with a MasterKeyType is PrimaryReadonlyMasterKey' {
                $script:result = $null

                $invokeAzResourceAction_parameterFilter = {
                    ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                    ($ApiVersion -eq '2015-04-08') -and `
                    ($ResourceName -eq $script:testName) -and `
                    ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                    ($Action -eq 'regenerateKey') -and `
                    ($Parameters['keyKind'] -eq 'PrimaryReadonly')
                    ($Force -eq $true)
                }

                Mock `
                    -CommandName Invoke-AzResourceAction `
                    -MockWith {
                    [PSCustomObject] @{ PrimaryMasterKey = $script:testKey}
                }

                It 'Should not throw exception' {
                    $newCosmosDbAccountMasterKeyParameters = @{
                        Name              = $script:testName
                        ResourceGroupName = $script:testResourceGroupName
                        Verbose           = $true
                    }

                    { $script:result = New-CosmosDbAccountMasterKey @newCosmosDbAccountMasterKeyParameters } | Should -Not -Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Invoke-AzResourceAction `
                        -ParameterFilter $invokeAzResourceAction_parameterFilter `
                        -Exactly -Times 1
                }
            }
        }
    }
}
