function Get-CosmosDbAccountConnectionString
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

    $invokeAzResourceAction_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
        Action       = 'listConnectionStrings'
        Force        = $true
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccountConnectionString -f $Name, $ResourceGroupName)
    Write-Warning -Message $LocalizedData.GettingAzureCosmosDBAccountConnectionStringWarning

    return Invoke-AzResourceAction @invokeAzResourceAction_parameters
}
