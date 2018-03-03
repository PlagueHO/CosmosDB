<#
.SYNOPSIS
    Set the custom Cosmos DB Offer types to the offer
    returned by an API call.

.DESCRIPTION
    This function applies the custom types to the offer returned
    by an API call.

.PARAMETER Offer
    This is the offer that is returned by a user API call.
#>
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

<#
.SYNOPSIS
    Return the resource path for a offer object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a offer
    object.

.PARAMETER Id
    This is the Id of the offer.
#>
function Get-CosmosDbOfferResourcePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('offers/{0}' -f $Id)
}

<#
.SYNOPSIS
    Return the offers in a CosmosDB account.

.DESCRIPTION
    This cmdlet will return the offers in a CosmosDB account.
    If the Id is specified then only the offer matching this
    Id will be returned, otherwise all offers will be returned.

.PARAMETER Context
    This is an object containing the context information of
    the CosmosDB account that will be accessed. It should be created
    by `New-CosmosDbContext`.

    If the context contains a database it will be ignored.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the offer to get.

.PARAMETER Query
    A SQL select query to execute to select the offers. This
    should not be specified if Id is specified.
#>
function Get-CosmosDbOffer
{
    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([Object])]
    param
    (
        [Alias("Connection")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Query
    )

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $offer = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'offers' `
            -ResourcePath ('offers/{0}' -f $Id)
    }
    else
    {
        if (-not [String]::IsNullOrEmpty($Query))
        {
            $null = $PSBoundParameters.Remove('Query')

            # A query has been specified
            $headers += @{
                'x-ms-documentdb-isquery' = $True
            }

            # Set the content type to application/query+json for querying
            $null = $PSBoundParameters.Add('ContentType', 'application/query+json')

            # Create the body JSON for the query
            $bodyObject = @{ query = $Query }
            $body = ConvertTo-Json -InputObject $bodyObject

            $result = Invoke-CosmosDbRequest @PSBoundParameters `
                -Method 'Post' `
                -ResourceType 'offers' `
                -Headers $headers `
                -Body $body
        }
        else
        {
            $result = Invoke-CosmosDbRequest @PSBoundParameters `
                -Method 'Get' `
                -ResourceType 'offers'
        }

        $offer = $result.Offers
    }

    if ($offer)
    {
        return (Set-CosmosDbOfferType -Offer $offer)
    }
}
