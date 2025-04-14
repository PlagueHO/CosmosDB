<#
.SYNOPSIS
    Constructs a Cosmos DB URI based on the account name and environment or base hostname.

.DESCRIPTION
    The Get-CosmosDbUri function generates a URI for a Cosmos DB account.
    It supports specifying the environment (e.g., AzureCloud, AzureUSGovernment, AzureChinaCloud)
    or directly providing a base hostname.

.PARAMETER Account
    The name of the Cosmos DB account. This is required.

.PARAMETER BaseHostname
    The base hostname for the Cosmos DB URI. Defaults to 'documents.azure.com'.
    This parameter is used when the 'Uri' parameter set is selected.

.PARAMETER Environment
    The environment for the Cosmos DB account (e.g., AzureCloud, AzureUSGovernment, AzureChinaCloud).
    This parameter is used when the 'Environment' parameter set is selected.

.OUTPUTS
    System.Uri
        Returns a URI object representing the Cosmos DB account URI.

.EXAMPLE
    Get-CosmosDbUri -Account 'mycosmosdbaccount' -Environment AzureCloud

    Constructs a URI for the Cosmos DB account 'mycosmosdbaccount' in the AzureCloud environment.

.EXAMPLE
    Get-CosmosDbUri -Account 'mycosmosdbaccount' -BaseHostname 'documents.azure.cn'

    Constructs a URI for the Cosmos DB account 'mycosmosdbaccount' using the specified base hostname.
#>
function Get-CosmosDbUri
{

    [CmdletBinding(
        DefaultParameterSetName = 'Environment'
    )]
    [OutputType([System.Uri])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Account,

        [Parameter(ParameterSetName = 'Uri')]
        [System.String]
        $BaseHostname = 'documents.azure.com',

        [Parameter(ParameterSetName = 'Environment')]
        [CosmosDB.Environment]
        $Environment = [CosmosDB.Environment]::AzureCloud
    )

    if ($PSCmdlet.ParameterSetName -eq 'Environment')
    {
        switch ($Environment)
        {
            'AzureUSGovernment'
            {
                $BaseHostname = 'documents.azure.us'
            }

            'AzureChinaCloud'
            {
                $BaseHostname = 'documents.azure.cn'
            }
        }
    }

    return [System.Uri]::new(('https://{0}.{1}' -f $Account, $BaseHostname))
}
