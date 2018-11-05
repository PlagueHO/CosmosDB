function Get-CosmosDbUri
{

    [CmdletBinding()]
    [OutputType([uri])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Account,

        [Parameter()]
        [System.String]
        $BaseUri = 'documents.azure.com'
    )

    return [uri]::new(('https://{0}.{1}' -f $Account, $BaseUri))
}
