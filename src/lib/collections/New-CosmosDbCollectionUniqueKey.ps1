function New-CosmosDbCollectionUniqueKey
{

    [CmdletBinding()]
    [OutputType([CosmosDB.UniqueKeyPolicy.UniqueKey])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Path
    )

    $uniqueKey = [CosmosDB.UniqueKeyPolicy.UniqueKey]::new()
    $uniqueKey.paths = $Path

    return $uniqueKey
}
