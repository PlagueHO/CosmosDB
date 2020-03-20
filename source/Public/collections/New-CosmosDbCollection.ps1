function New-CosmosDbCollection
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
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ -ArgumentName 'Account' })]
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateRange(400, 250000)]
        [System.Int32]
        $OfferThroughput,

        [Parameter()]
        [ValidateSet('S1', 'S2', 'S3')]
        [System.String]
        $OfferType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PartitionKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.IndexingPolicy.Policy]
        $IndexingPolicy,

        [Parameter()]
        [ValidateRange(-1,2147483647)]
        [System.Int32]
        $DefaultTimeToLive,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.UniqueKeyPolicy.Policy]
        $UniqueKeyPolicy
    )

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('OfferThroughput') -and `
            $PSBoundParameters.ContainsKey('OfferType'))
    {
        New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewCollectionOfferParameterConflict)
    }

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
        if ($OfferThroughput -gt 10000 -and $PartitionKey.Count -eq 0)
        {
            New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewCollectionParitionKeyRequired)
        }

        $headers += @{
            'x-ms-offer-throughput' = $OfferThroughput
        }
        $null = $PSBoundParameters.Remove('OfferThroughput')
    }

    if ($PSBoundParameters.ContainsKey('OfferType'))
    {
        $headers += @{
            'x-ms-offer-type' = $OfferType
        }
        $null = $PSBoundParameters.Remove('OfferType')
    }

    $null = $PSBoundParameters.Remove('Id')

    $bodyObject = @{
        id = $id
    }

    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $bodyObject += @{
            partitionKey = @{
                paths = @('/{0}' -f $PartitionKey.TrimStart('/'))
                kind  = 'Hash'
            }
        }
        $null = $PSBoundParameters.Remove('PartitionKey')
    }
    else
    {
        Write-Warning -Message $($LocalizedData.NonPartitionedCollectionWarning)
    }

    if ($PSBoundParameters.ContainsKey('IndexingPolicy'))
    {
        $bodyObject += @{
            indexingPolicy = $IndexingPolicy
        }
        $null = $PSBoundParameters.Remove('IndexingPolicy')
    }

    if ($PSBoundParameters.ContainsKey('DefaultTimeToLive'))
    {
        $bodyObject += @{
            defaultTtl = $DefaultTimeToLive
        }
        $null = $PSBoundParameters.Remove('DefaultTimeToLive')
    }

    if ($PSBoundParameters.ContainsKey('UniqueKeyPolicy'))
    {
        $bodyObject += @{
            uniqueKeyPolicy = $UniqueKeyPolicy
        }
        $null = $PSBoundParameters.Remove('UniqueKeyPolicy')
    }

    $body = ConvertTo-Json -InputObject $bodyObject -Depth 10

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'colls' `
        -Headers $headers `
        -Body $body

    $collection = ConvertFrom-Json -InputObject $result.Content

    if ($collection)
    {
        return (Set-CosmosDbCollectionType -Collection $collection)
    }
}
