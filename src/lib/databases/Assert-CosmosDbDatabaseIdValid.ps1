<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Database Id is valid.
#>
function Assert-CosmosDbDatabaseIdValid
{

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $matches = [regex]::Match($Id,"[^\\/#?=]{1,255}(?<!\s)")
    if ($matches.value -ne $Id)
    {
        Throw $($LocalizedData.DatabaseIdInvalid -f $Id)
    }

    return $true
}
