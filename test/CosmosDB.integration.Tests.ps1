[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
$TestHelperPath = "$PSScriptRoot\TestHelper"

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name $TestHelperPath -Force

Get-AzureServicePrincipal

if ([String]::IsNullOrEmpty($env:azureSubscriptionId))
{
    Write-Warning -Message 'Integration tests can not be run because Azure connection environment variables are not set.'
    return
}

# Variables for use in tests
$script:testResourceGroupName = 'cosmosdbpsmoduletestrgp'
$script:testAccountName = ('cdbtest{0}' -f [System.IO.Path]::GetRandomFileName() -replace '\.', '')
$script:testOffer = 'testOffer'
$script:testDatabase = 'testDatabase'
$script:testCollection = 'testCollection'

# Connect to Azure
Connect-AzureServicePrincipal `
    -SubscriptionId $env:azureSubscriptionId `
    -ApplicationId $env:azureApplicationId `
    -ApplicationPassword $env:azureApplicationPassword `
    -TenantId $env:azureTenantId `
    -Verbose

# Create Azure CosmosDB Account to use for testing
New-AzureCosmosDbAccount `
    -ResourceGroupName $script:testResourceGroupName `
    -AccountName $script:testAccountName `
    -Verbose

$script:testContext = New-CosmosDbContext `
    -Account $script:testAccountName `
    -Database $script:testDatabase `
    -ResourceGroup $script:testResourceGroupName

Describe 'Cosmos DB Module' -Tag 'Integration' {
    Context 'Create a new database' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase
        }
    }

    Context 'Get existing database' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase
        }
    }

    Context 'Create a new collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'Get existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'Get existing offers' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
            } | Should -Not -Throw
        }
        Write-Verbose -Message ($script:result | fl * | Out-String ) -Verbose

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 400
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
        }
    }

    Context 'Update existing offer throughput' {
        It 'Should not throw an exception' {
            {
                $script:result = `
                    Get-CosmosDbOffer -Context $script:testContext -Verbose |
                    Set-CosmosDbOffer -Context $script:testContext -OfferThroughput 800 -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 800
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
        }
    }

    Context 'Remove existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove existing database' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
        }
    }
}

# Remove Azure CosmosDB Account after testing
Remove-AzureCosmosDbAccount `
    -ResourceGroupName $script:testResourceGroupName `
    -AccountName $script:testAccountName `
    -Verbose
