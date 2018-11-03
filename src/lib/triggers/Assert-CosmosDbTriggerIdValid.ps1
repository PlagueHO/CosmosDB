<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Trigger Id is valid.
#>
function Assert-CosmosDbTriggerIdValid
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
        Throw $($LocalizedData.TriggerIdInvalid -f $Id)
    }

    return $true
}
