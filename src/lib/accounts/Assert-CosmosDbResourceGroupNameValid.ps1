<#
    .SYNOPSIS
    Helper function that asserts a Azure Resource Group name is valid.
#>
function Assert-CosmosDbResourceGroupNameValid
{

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName
    )

    $matches = [regex]::Match($ResourceGroupName,"[A-Za-z0-9_\-\.]{1,90}(?<!\.)")
    if ($matches.value -ne $ResourceGroupName)
    {
        Throw $($LocalizedData.ResourceGroupNameInvalid -f $ResourceGroupName)
    }

    return $true
}
