function Set-CosmosDbDatabaseType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Database
    )

    foreach ($item in $Database)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Database')
    }

    return $Database
}
