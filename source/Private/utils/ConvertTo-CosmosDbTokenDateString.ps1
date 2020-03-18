function ConvertTo-CosmosDbTokenDateString
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $Date
    )

    return $Date.ToUniversalTime().ToString("r", [System.Globalization.CultureInfo]::InvariantCulture)
}
