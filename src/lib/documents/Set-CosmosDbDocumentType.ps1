function Set-CosmosDbDocumentType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Document
    )

    foreach ($item in $Document)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Document')
    }

    return $Document
}
