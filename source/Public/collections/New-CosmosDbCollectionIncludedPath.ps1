function New-CosmosDbCollectionIncludedPath
{

    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.IncludedPath])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = '/*',

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.Index[]]
        $Index
    )

    if ($PSBoundParameters.ContainsKey('Index'))
    {
        $includedPath = [CosmosDB.IndexingPolicy.Path.IncludedPathIndex]::new()
        $includedPath.Path = $Path
        $includedPath.Indexes = $Index
    }
    else
    {
        $includedPath = [CosmosDB.IndexingPolicy.Path.IncludedPath]::new()
        $includedPath.Path = $Path
    }

    return $includedPath
}
