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

            $result = Invoke-CosmosDbRequest @invokeCosmosDbRequest `
                -Method 'Put' `
                -ResourceType 'offers' `
                -ResourcePath ('offers/{0}' -f $bodyObject.id) `
                -Body (ConvertTo-Json -InputObject $bodyObject)

            $offer = ConvertFrom-Json -InputObject $result.Content

            if ($offer)
            {
                (Set-CosmosDbOfferType -Offer $offer)
            }
        }
    }

    end {}
}
