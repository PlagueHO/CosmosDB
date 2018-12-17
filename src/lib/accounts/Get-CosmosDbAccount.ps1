function Get-CosmosDbAccount
{

    [CmdletBinding()]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbResourceGroupNameValid -ResourceGroupName $_ })]
        [System.String]
        $ResourceGroupName
    )

    $getAzResource_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

    return Get-AzResource @getAzResource_parameters
}
