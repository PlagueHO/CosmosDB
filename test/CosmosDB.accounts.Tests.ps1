[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force

InModuleScope CosmosDB {
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
    $script:mockGetAzureRmResource = @{
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
            capabilities                  = @()
            ResourceGroupName             = $script:testResourceGroupName
            ResourceType                  = 'Microsoft.DocumentDB/databaseAccounts'
            Sku                           = $null
            Tags                          = @{}
            Type                          = 'Microsoft.DocumentDB/databaseAccounts'
        }
    }

    Describe 'Get-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName' {
            $script:result = $null

            $getAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-AzureRmResource `
                -ParameterFilter $getAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                ($AsJob -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $newAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName New-AzureRmResource `
                -ParameterFilter $newAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

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
                Assert-VerifiableMock
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
            }

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                ($AsJob -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Location -eq $script:testLocation) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                Assert-VerifiableMock
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

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

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
                }

                $setAzurRmResource_parameterFilter = {
                    ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                    ($ApiVersion -eq '2015-04-08') -and `
                    ($Name -eq $script:testName) -and `
                    ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                    ($Force -eq $true) -and `
                    (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
                }

                Mock `
                    -CommandName Set-AzureRmResource `
                    -ParameterFilter $setAzurRmResource_parameterFilter `
                    -MockWith { 'Account' } `
                    -Verifiable

                $getCosmosDbAccount_parameterFilter = {
                    ($Name -eq $script:testName) -and `
                    ($ResourceGroupName -eq $script:testResourceGroupName)
                }

                Mock `
                    -CommandName Get-CosmosDbAccount `
                    -ParameterFilter $getCosmosDbAccount_parameterFilter `
                    -MockWith { $script:mockGetAzureRmResource } `
                    -Verifiable

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
            }

            It 'Should return expected result' {
                $script:result | Should -Be 'Account'
            }

            It 'Should call expected mocks' {
                Assert-VerifiableMock
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
            }

            $setAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true) -and `
                (ConvertTo-Json -InputObject $Properties) -eq (ConvertTo-Json -InputObject $testCosmosDBProperties)
            }

            Mock `
                -CommandName Set-AzureRmResource `
                -ParameterFilter $setAzurRmResource_parameterFilter `
                -MockWith { 'Account' } `
                -Verifiable

            $getCosmosDbAccount_parameterFilter = {
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName)
            }

            Mock `
                -CommandName Get-CosmosDbAccount `
                -ParameterFilter $getCosmosDbAccount_parameterFilter `
                -MockWith { $script:mockGetAzureRmResource } `
                -Verifiable

            It 'Should not throw exception' {
                $setCosmosDbAccountParameters = @{
                    Name                    = $script:testName
                    ResourceGroupName       = $script:testResourceGroupName
                    Location                = $script:testLocation
                    MaxIntervalInSeconds    = $script:testMaxIntervalInSeconds
                    Verbose                 = $true
                }

                { $script:result = Set-CosmosDbAccount @setCosmosDbAccountParameters } | Should -Not -Throw
            }
        }
    }

    Describe 'Remove-CosmosDbAccount' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbAccount -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a Name and ResourceGroupName' {
            $script:result = $null

            $removeAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Remove-AzureRmResource `
                -ParameterFilter $removeAzurRmResource_parameterFilter `
                -Verifiable

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
                Assert-VerifiableMock
            }
        }

        Context 'When called with a Name and ResourceGroupName and AsJob' {
            $script:result = $null

            $removeAzurRmResource_parameterFilter = {
                ($ResourceType -eq 'Microsoft.DocumentDb/databaseAccounts') -and `
                ($ApiVersion -eq '2015-04-08') -and `
                ($Name -eq $script:testName) -and `
                ($ResourceGroupName -eq $script:testResourceGroupName) -and `
                ($AsJob -eq $true) -and `
                ($Force -eq $true)
            }

            Mock `
                -CommandName Remove-AzureRmResource `
                -ParameterFilter $removeAzurRmResource_parameterFilter `
                -Verifiable

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
                Assert-VerifiableMock
            }
        }
    }
}
