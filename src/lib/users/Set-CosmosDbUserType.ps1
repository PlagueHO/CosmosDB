function Set-CosmosDbUserType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $User
    )

    foreach ($item in $User)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.User')
    }

    return $User
}
