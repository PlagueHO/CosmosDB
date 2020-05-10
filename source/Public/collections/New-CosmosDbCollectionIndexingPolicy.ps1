function New-CosmosDbCollectionIndexingPolicy
{

    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Policy])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $Automatic = $true,

        [Parameter()]
        [ValidateSet('Consistent', 'Lazy', 'None')]
        [System.String]
        $IndexingMode = 'Consistent',

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.IncludedPath[]]
        $IncludedPath = @(),

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.ExcludedPath[]]
        $ExcludedPath = @(),

        [Parameter()]
        [CosmosDB.IndexingPolicy.CompositeIndex.Element[][]]
        $CompositeIndex = @(@())
    )

    if ($IndexingMode -eq 'None' -and $Automatic)
    {
        New-CosmosDbInvalidArgumentException `
            -Message $($LocalizedData.ErrorNewCollectionIndexingPolicyInvalidMode) `
            -ArgumentName 'Automatic'
    }

    $indexingPolicy = [CosmosDB.IndexingPolicy.Policy]::new()
    $indexingPolicy.Automatic = $Automatic
    $indexingPolicy.IndexingMode = $IndexingMode
    $indexingPolicy.IncludedPaths = $IncludedPath
    $indexingPolicy.ExcludedPaths = $ExcludedPath
    $indexingPolicy.CompositeIndexes = $CompositeIndex

    return $indexingPolicy
}
