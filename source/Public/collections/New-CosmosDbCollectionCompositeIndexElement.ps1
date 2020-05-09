function New-CosmosDbCollectionCompositeIndexElement
{

    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.CompositeIndex.Element])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Ascending', 'Descending')]
        [System.String]
        $Order = 'Ascending'
    )

    $element = New-Object -TypeName 'CosmosDB.IndexingPolicy.CompositeIndex.Element'
    $element.path = $Path
    $element.order = $Order.ToLower()

    return $element
}
