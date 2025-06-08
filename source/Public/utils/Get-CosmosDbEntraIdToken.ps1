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

    <#
        `-AsSecureString` is not required here because the `Get-AzAccessToken` cmdlet always
        returns a SecureString as of Az.Accounts 5.0.0 and newer.
    #>
    Write-Verbose -Message ($LocalizedData.GettingEntraIdToken -f $Endpoint)
    $token = Get-AzAccessToken -ResourceUrl $Endpoint -AsSecureString
    if ($null -eq $token) {
        New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorGettingEntraIdToken -f $Endpoint)
        return $null
    }
    return $token.Token
}
