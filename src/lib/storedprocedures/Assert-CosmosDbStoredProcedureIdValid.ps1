<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB StoredProcedure Id is valid.
#>
function Assert-CosmosDbStoredProcedureIdValid
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

    $matches = [regex]::Match($Id,"[^\\/#?]{1,255}(?<!\s)")
    if ($matches.value -ne $Id)
    {
        Throw $($LocalizedData.StoredProcedureIdInvalid -f $Id)
    }

    return $true
}
