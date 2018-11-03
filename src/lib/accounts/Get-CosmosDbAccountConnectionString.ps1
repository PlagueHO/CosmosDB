function Get-CosmosDbAccountConnectionString
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

    $invokeAzureRmResourceAction_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
        Action       = 'listConnectionStrings'
        Force        = $true
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccountConnectionString -f $Name, $ResourceGroupName)
    Write-Warning -Message $LocalizedData.GettingAzureCosmosDBAccountConnectionStringWarning

    return Invoke-AzureRmResourceAction @invokeAzureRmResourceAction_parameters
}
