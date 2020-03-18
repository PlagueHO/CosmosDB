function New-CosmosDbCollectionUniqueKeyPolicy
{

    [CmdletBinding()]
    [OutputType([CosmosDB.UniqueKeyPolicy.Policy])]
    param
    (
        [Parameter(Mandatory = $true)]
        [CosmosDb.UniqueKeyPolicy.UniqueKey[]]
        $UniqueKey
    )

    $uniqueKeyPolicy = [CosmosDB.UniqueKeyPolicy.Policy]::new()
    $uniqueKeyPolicy.uniqueKeys = $UniqueKey

    return $uniqueKeyPolicy
}
