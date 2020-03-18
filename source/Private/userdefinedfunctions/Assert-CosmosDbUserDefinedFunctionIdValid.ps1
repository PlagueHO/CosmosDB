<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB User Defined Function Id is valid.
#>
function Assert-CosmosDbUserDefinedFunctionIdValid
{

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ArgumentName = 'Id'
    )

    $matches = [regex]::Match($Id,"[^\\/#?]{1,255}(?<!\s)")
    if ($matches.value -ne $Id)
    {
        New-CosmosDbInvalidArgumentException `
            -Message $($LocalizedData.UserDefinedFunctionIdInvalid -f $Id) `
            -ArgumentName $ArgumentName
    }

    return $true
}
