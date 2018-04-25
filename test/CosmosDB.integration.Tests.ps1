[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

# Always show verbose messages
$VerbosePreference = 'Continue'

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
$TestHelperPath = "$PSScriptRoot\TestHelper"

Import-Module -Name $TestHelperPath -Force
Import-Module -Name $ModuleManifestPath -Force

Get-AzureServicePrincipal

if ([String]::IsNullOrEmpty($env:azureSubscriptionId))
{
    Write-Warning -Message 'Integration tests can not be run because Azure connection environment variables are not set.'
    return
}

InModuleScope CosmosDB {
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
        -TenantId $env:azureTenantId

    # Create Azure CosmosDB Account to use for testing
    New-AzureCosmosDbAccount `
        -ResourceGroupName $script:testResourceGroupName `
        -AccountName $script:testAccountName

    Describe 'Collections' -Tag 'Integration' {
        Context 'Create collection and assign Offer' {
        }
    }

    # Remove Azure CosmosDB Account after testing
    Remove-AzureCosmosDbAccount `
        -ResourceGroupName $script:testResourceGroupName `
        -AccountName $script:testAccountName
}
