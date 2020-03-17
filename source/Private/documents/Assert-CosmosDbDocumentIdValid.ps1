<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Document Id is valid.
#>
function Assert-CosmosDbDocumentIdValid
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
            -Message $($LocalizedData.DocumentIdInvalid -f $Id) `
            -ArgumentName $ArgumentName
    }

    return $true
}
