function Get-CosmosDbAccount
{

    [CmdletBinding()]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName
    )

    $getAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

    return Get-AzureRmResource @getAzureRmResource_parameters
}
