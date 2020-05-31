function Get-CosmosDbContinuationToken
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $ResponseHeader
    )

    $continuationToken = Get-CosmosDbResponseHeaderAttribute `
        -ResponseHeader $ResponseHeader `
        -HeaderName 'x-ms-continuation'

    if ([System.String]::IsNullOrEmpty($continuationToken))
    {
        Write-Warning -Message $LocalizedData.ResponseHeaderContinuationTokenMissingOrEmpty
        $continuationToken = $null
    }

    return $continuationToken
}
