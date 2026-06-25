function Get-CosmosDbEntraIdEndpoint
{
    [CmdletBinding(DefaultParameterSetName = 'Environment')]
    [OutputType([System.String])]
    param
    (
        [Parameter(ParameterSetName = 'Environment')]
        [CosmosDB.Environment]
        $Environment = [CosmosDB.Environment]::AzureCloud,

        [Parameter(Mandatory = $true, ParameterSetName = 'Hostname')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $BaseHostname
    )

    if ($PSCmdlet.ParameterSetName -eq 'Hostname')
    {
        $endpoint = switch -Wildcard ($BaseHostname)
        {
            '*.azure.us' { 'https://cosmos.azure.us' }
            '*.azure.cn' { 'https://cosmos.azure.cn' }
            default      { 'https://cosmos.azure.com' }
        }
    }
    else
    {
        $endpoint = switch ($Environment)
        {
            'AzureUSGovernment' { 'https://cosmos.azure.us' }
            'AzureChinaCloud'   { 'https://cosmos.azure.cn' }
            default             { 'https://cosmos.azure.com' }
        }
    }

    return $endpoint
}
