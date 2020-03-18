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

    $includedPath = [CosmosDB.IndexingPolicy.Path.IncludedPath]::new()
    $includedPath.Path = $Path
    $includedPath.Indexes = $Index

    return $includedPath
}
