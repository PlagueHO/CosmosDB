function Get-CosmosDbEntraIdToken {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Endpoint = 'https://cosmos.azure.com'
    )

    # Remove any trailing slash as Cosmos DB RBAC does not expect the resource URL to have a trailing slash
    $Endpoint = $Endpoint.TrimEnd('/')

    $token = (Get-AzAccessToken -ResourceUrl $Endpoint).Token
    if ([System.String]::IsNullOrEmpty($token)) {
        return $null
    }
    return (ConvertTo-SecureString -String $token -AsPlainText -Force)
}
