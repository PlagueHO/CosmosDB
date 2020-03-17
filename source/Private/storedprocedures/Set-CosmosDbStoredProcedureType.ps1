function Set-CosmosDbStoredProcedureType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $StoredProcedure
    )

    foreach ($item in $StoredProcedure)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.StoredProcedure')
    }

    return $StoredProcedure
}
