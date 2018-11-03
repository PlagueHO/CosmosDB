<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Account name is valid.
#>
function Assert-CosmosDbAccountNameValid
{

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    $matches = [regex]::Match($Name,"[A-Za-z0-9\-]{3,31}")
    if ($matches.value -ne $Name)
    {
        Throw $($LocalizedData.AccountNameInvalid -f $Name)
    }

    return $true
}
