function Set-CosmosDbTriggerType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Trigger
    )

    foreach ($item in $Trigger)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Trigger')
    }

    return $Trigger
}
