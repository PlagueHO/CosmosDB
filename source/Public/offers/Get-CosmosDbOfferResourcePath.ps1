function Get-CosmosDbOfferResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('offers/{0}' -f $Id)
}
