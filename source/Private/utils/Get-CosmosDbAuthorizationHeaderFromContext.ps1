function Get-CosmosDbAuthorizationHeaderFromContext
{

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateSet('', 'Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        [System.String]
        $Method = '',

        [Parameter()]
        [System.String]
        $ResourceType = '',

        [Parameter()]
        [System.String]
        $ResourceId = '',

        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $Date,

        [Parameter()]
        [ValidateSet('1.0')]
        [System.String]
        $TokenVersion = '1.0'
    )

    Write-Verbose -Message $($LocalizedData.CreateAuthorizationToken -f $Method, $ResourceType, $ResourceId, $Date)

    $decryptedKey = Convert-CosmosDbSecureStringToString -SecureString $Key
    $base64Key = [System.Convert]::FromBase64String($decryptedKey)
    $hmacSha256 = New-Object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList (, $base64Key)
    $dateString = ConvertTo-CosmosDbTokenDateString -Date $Date
    $payLoad = @(
        $Method.ToLowerInvariant() + "`n" + `
        $ResourceType.ToLowerInvariant() + "`n" + `
        $ResourceId + "`n" + `
        $dateString.ToLowerInvariant() + "`n" + `
        "" + "`n"
    )

    $body = [System.Text.Encoding]::UTF8.GetBytes($payLoad)
    $hashPayLoad = $hmacSha256.ComputeHash($body)
    $signature = [Convert]::ToBase64String($hashPayLoad)

    Add-Type -AssemblyName 'System.Web'
    $token = [System.Web.HttpUtility]::UrlEncode(('type={0}&ver={1}&sig={2}' -f $KeyType, $TokenVersion, $signature))
    $headers = @{
        'authorization' = $token
        'x-ms-date'     = $dateString
    }
    return $headers
}
