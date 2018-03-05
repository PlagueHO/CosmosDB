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

<#
.SYNOPSIS
    Update an existing offer in a CosmosDB database.

.DESCRIPTION
    This cmdlet will update an offer resource in CosmosDB.

.PARAMETER Context
    This is an object containing the context information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbContext`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    The offer Id of the offer to set.

.PARAMETER OfferVersion
    This can be V1 for pre-defined throughput levels and V2 for user-defined
    throughput levels.

.PARAMETER OfferType
    This is a user settable property, which must be set to S1, S2, or S3 for
    pre-defined performance levels, and Invalid for user-defined performance
    levels.

.PARAMETER OfferThroughput
    This contains the throughput of the collection. Applicable for V2 offers
    only.

.PARAMETER OfferIsRUPerMinuteThroughputEnabled
    The offer is RU per minute throughput enabled. Applicable for V2 offers
    only.
#>
function Set-CosmosDbOffer
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
        [System.String]
        $Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter(ParameterSetName = 'Account')]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object[]]
        $InputObject,

        [Parameter()]
        [ValidateSet('V1', 'V2')]
        [System.String]
        $OfferVersion,

        [Parameter()]
        [ValidateSet('S1', 'S2', 'S3', 'Invalid')]
        [System.String]
        $OfferType,

        [Parameter()]
        [ValidateRange(400, 250000)]
        [System.Int32]
        $OfferThroughput,

        [Parameter()]
        [System.Boolean]
        $OfferIsRUPerMinuteThroughputEnabled
    )

    begin {
        $invokeCosmosDbRequest = @{} + $PSBoundParameters
    }

    process {
        $null = $invokeCosmosDbRequest.Remove('InputObject')

        foreach ($object in $InputObject)
        {
            $bodyObject = @{
                '_rid'          = $object._rid
                id              = $object.id
                '_ts'           = $object._ts
                '_self'         = $object._self
                '_etag'         = $object._etag
                resource        = $object.resource
                offerType       = $object.offerType
                offerResourceId = $object.offerResourceId
                offerVersion    = $object.offerVersion
            }

            if ($PSBoundParameters.ContainsKey('OfferVersion'))
            {
                $null = $invokeCosmosDbRequest.Remove('OfferVersion')
                $bodyObject.offerVersion = $OfferVersion
            }

            if ($PSBoundParameters.ContainsKey('OfferType'))
            {
                $null = $invokeCosmosDbRequest.Remove('OfferType')
                $bodyObject.offerType = $OfferType
            }

            if ($bodyObject.offerVersion -eq 'V2')
            {
                <#
                    Setting the Offer Throughput and RU Per minute settings only
                    applicable for Offer Version V2
                #>
                $content = @{
                    offerThroughput = $object.Content.offerThroughput
                    offerIsRUPerMinuteThroughputEnabled = $object.Content.offerIsRUPerMinuteThroughputEnabled
                }

                if ($PSBoundParameters.ContainsKey('OfferThroughput'))
                {
                    $null = $invokeCosmosDbRequest.Remove('OfferThroughput')
                    $content.offerThroughput = $OfferThroughput
                }
                else
                {
                    if ($content.offerThroughput -lt 1000)
                    {
                        <#
                            If no offer throughput specified set to min for V2 of 400
                            However for partitioned collections minimum is 1000
                        #>
                        $content.offerThroughput = 1000
                    }
                }

                if ($PSBoundParameters.ContainsKey('OfferIsRUPerMinuteThroughputEnabled'))
                {
                    $null = $invokeCosmosDbRequest.Remove('OfferIsRUPerMinuteThroughputEnabled')
                    $content.offerIsRUPerMinuteThroughputEnabled = $OfferIsRUPerMinuteThroughputEnabled
                }

                $bodyObject += @{
                    content = $content
                }
            }

            $offer = Invoke-CosmosDbRequest @invokeCosmosDbRequest `
                -Method 'Put' `
                -ResourceType 'offers' `
                -ResourcePath ('offers/{0}' -f $bodyObject.id) `
                -Body (ConvertTo-Json -InputObject $bodyObject)

            if ($offer)
            {
                (Set-CosmosDbOfferType -Offer $offer)
            }
        }
    }

    end {}
}
