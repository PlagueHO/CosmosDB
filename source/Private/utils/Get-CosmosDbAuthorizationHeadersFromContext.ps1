function Get-CosmosDbAuthorizationHeadersFromContext
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.Context]
        $Context,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceLink
    )

    $headers = $null

    if ($null -ne $Context.Token)
    {
        Write-Verbose -Message $($LocalizedData.FindResourceTokenInContext -f $ResourceLink)

        # Find the most recent token non-expired matching the resource link
        $matchToken = $context.Token |
            Where-Object -FilterScript { $_.Resource -eq $ResourceLink }

        if ($matchToken)
        {
            # One or more matching tokens could be found
            Write-Verbose -Message $($LocalizedData.FoundResourceTokenInContext -f $matchToken.Count, $matchToken.Resource)

            $now = Get-Date
            $validToken = $matchToken |
                Where-Object -FilterScript { $_.Expires -gt $now } |
                Sort-Object -Property Expires -Descending |
                Select-Object -First 1

            if ($validToken)
            {
                # One or more matching tokens could be found
                Write-Verbose -Message $($LocalizedData.FoundUnExpiredResourceTokenInContext -f $validToken.Resource, $validToken.TimeStamp)

                $decryptedToken = Convert-CosmosDbSecureStringToString -SecureString $validToken.Token
                $token = [System.Web.HttpUtility]::UrlEncode($decryptedToken)
                $date = $validToken.TimeStamp
                $dateString = ConvertTo-CosmosDbTokenDateString -Date $date
                $headers = @{
                    'authorization' = $token
                    'x-ms-date'     = $dateString
                }
            }
            else
            {
                # No un-expired matching token could be found, so fall back to using a master key if possible
                Write-Verbose -Message $($LocalizedData.NoMatchingUnexpiredResourceTokenInContext -f $resourceLink)
            }
        }
        else
        {
            # No matching token could be found, so fall back to using a master key if possible
            Write-Verbose -Message $($LocalizedData.NotFoundResourceTokenInContext -f $resourceLink)
        }
    }
    else
    {
        # No tokens in context
        Write-Verbose -Message $($LocalizedData.NoResourceTokensInContext)
    }

    return $headers
}
