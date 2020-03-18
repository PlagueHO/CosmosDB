function New-CosmosDbCollectionExcludedPath
{

    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.ExcludedPath])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = '/*'
    )

    $excludedPath = [CosmosDB.IndexingPolicy.Path.ExcludedPath]::new()
    $excludedPath.Path = $Path

    return $excludedPath
}
