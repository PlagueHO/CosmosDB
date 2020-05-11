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

    $continuationToken = [System.String] $ResponseHeader.'x-ms-continuation'

    if ([System.String]::IsNullOrEmpty($continuationToken))
    {
        Write-Warning -Message $LocalizedData.ResponseHeaderContinuationTokenMissingOrEmpty
        $continuationToken = $null
    }

    return $continuationToken
}
