function Set-CosmosDbOfferType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Offer
    )

    foreach ($item in $Offer)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Offer')
    }

    return $Offer
}
