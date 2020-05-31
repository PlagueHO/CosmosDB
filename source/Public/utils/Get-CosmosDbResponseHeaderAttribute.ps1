function Get-CosmosDbResponseHeaderAttribute
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $ResponseHeader,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $HeaderName
    )

    return ([System.String] $ResponseHeader.$HeaderName)
}
