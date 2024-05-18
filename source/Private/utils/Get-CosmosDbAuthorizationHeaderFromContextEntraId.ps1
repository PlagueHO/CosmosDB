function Get-CosmosDbAuthorizationHeaderFromContextEntraId
{

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.Context]
        $Context,

        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $Date
    )

    Write-Verbose -Message $($LocalizedData.CreateAuthorizationTokenEntraId)

    if (-not [System.String]::IsNullOrEmpty($Context.EntraIdToken))
    {
        $decryptedEntraIdToken = Convert-CosmosDbSecureStringToString -SecureString $Context.EntraIdToken
        $token = [System.Web.HttpUtility]::UrlEncode(('type=aad&ver=1.0&sig={0}' -f $decryptedEntraIdToken))
        $headers = @{
            'authorization' = $token
            'x-ms-date'     = ConvertTo-CosmosDbTokenDateString -Date $Date
        }
        return $headers
    }
}
