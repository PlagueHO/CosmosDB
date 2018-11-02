function Set-CosmosDbUserDefinedFunctionType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $UserDefinedFunction
    )

    foreach ($item in $UserDefinedFunction)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.UserDefinedFunction')
    }

    return $UserDefinedFunction
}
