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
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ArgumentName = 'Name'
    )

    $matches = [regex]::Match($Name,"[A-Za-z0-9\-]{3,50}")
    if ($matches.value -ne $Name)
    {
        New-CosmosDbInvalidArgumentException `
            -Message $($LocalizedData.AccountNameInvalid -f $Name) `
            -ArgumentName $ArgumentName
    }

    return $true
}
