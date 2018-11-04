<#
    .SYNOPSIS
    Helper function that asserts a Cosmos DB Attachment Id is valid.
#>
function Assert-CosmosDbAttachmentIdValid
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
        Throw $($LocalizedData.AttachmentIdInvalid -f $Id)
    }

    return $true
}
