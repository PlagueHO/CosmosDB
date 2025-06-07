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

    # Technically `-AsSecureString` is not required here because as of Az.Accounts 5.0.0+
    # the `Get-AzAccessToken` cmdlet returns a secure string by default.
    $token = (Get-AzAccessToken -ResourceUrl $Endpoint -AsSecureString).Token
    if ([System.String]::IsNullOrEmpty($token)) {
        return $null
    }
}
