<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Collection Id is valid.
#>
function Assert-CosmosDbCollectionIdValid
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
        Throw $($LocalizedData.CollectionIdInvalid -f $Id)
    }

    return $true
}
