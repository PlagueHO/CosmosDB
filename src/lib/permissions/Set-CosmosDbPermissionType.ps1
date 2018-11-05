function Set-CosmosDbPermissionType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Permission
    )

    foreach ($item in $Permission)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Permission')
    }

    return $Permission
}
