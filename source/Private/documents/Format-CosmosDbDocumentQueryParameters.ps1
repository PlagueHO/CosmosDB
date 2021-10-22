<#
    .SYNOPSIS
    Helper function that formats Cosmos DB Document QueryParameters' keys to lowercase.
#>
function Format-CosmosDbDocumentQueryParameters
{
    [CmdletBinding()]
    [OutputType([Hashtable[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable[]]
        $QueryParameters
    )

    $Output = foreach ($hashtable in $QueryParameters)
    {
        $item_ht = @{}
        $hashtable.getenumerator() | ForEach-Object {
            $item_ht.add($PSItem.Name.ToLower(), $PSItem.Value)
        }
        $item_ht
    }

    return $Output
}
