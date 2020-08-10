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
