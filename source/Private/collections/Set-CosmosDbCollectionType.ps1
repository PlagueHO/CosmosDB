function Set-CosmosDbCollectionType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Collection
    )

    foreach ($item in $Collection)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection')
        $item.indexingPolicy.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy')
        foreach ($includedPath in $item.indexingPolicy.includedPaths)
        {
            $includedPath.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.IncludedPath')
            foreach ($index in $includedPath.indexes)
            {
                $index.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.Index')
            }
        }
        foreach ($excludedPath in $item.indexingPolicy.excludedPaths)
        {
            $excludedPath.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.ExcludedPath')
            foreach ($index in $excludedPath.indexes)
            {
                $index.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.Index')
            }
        }
    }

    return $Collection
}
