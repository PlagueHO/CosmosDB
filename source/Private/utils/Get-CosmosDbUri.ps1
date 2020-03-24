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
        $BaseUri = 'documents.azure.com',

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
                $BaseUri = 'documents.azure.us'
            }
        }
    }

    return [System.Uri]::new(('https://{0}.{1}' -f $Account, $BaseUri))
}
