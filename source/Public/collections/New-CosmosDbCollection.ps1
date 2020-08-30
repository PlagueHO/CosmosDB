function New-CosmosDbCollection
{

    [CmdletBinding(DefaultParameterSetName = 'ContextIndexPolicy')]
    [OutputType([Object])]
    param
    (
        [Alias('Connection')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ContextIndexPolicy')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ContextIndexPolicyJson')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'AccountIndexPolicy')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AccountIndexPolicyJson')]
        [ValidateScript( { Assert-CosmosDbAccountNameValid -Name $_ -ArgumentName 'Account' })]
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
        [ValidateScript( { Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Alias('Name')]
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Assert-CosmosDbCollectionIdValid -Id $_ })]
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

        [Parameter(ParameterSetName = 'ContextIndexPolicy')]
        [Parameter(ParameterSetName = 'AccountIndexPolicy')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.IndexingPolicy.Policy]
        $IndexingPolicy,

        [Parameter(ParameterSetName = 'ContextIndexPolicyJson')]
        [Parameter(ParameterSetName = 'AccountIndexPolicyJson')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $IndexingPolicyJson,

        [Parameter()]
        [ValidateRange(-1, 2147483647)]
        [System.Int32]
        $DefaultTimeToLive,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.UniqueKeyPolicy.Policy]
        $UniqueKeyPolicy,

        [Alias('AutopilotThroughput')]
        [ValidateRange(4000, 1000000)]
        [System.Int32]
        $AutoscaleThroughput
    )

    $headers = @{ }

    if (($PSBoundParameters.ContainsKey('OfferThroughput') -and $PSBoundParameters.ContainsKey('OfferType')) -or `
        ($PSBoundParameters.ContainsKey('OfferThroughput') -and $PSBoundParameters.ContainsKey('AutoscaleThroughput')) -or `
        ($PSBoundParameters.ContainsKey('OfferType') -and $PSBoundParameters.ContainsKey('AutoscaleThroughput')))
    {
        New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewCollectionOfferParameterConflict)
    }

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
        if ($OfferThroughput -gt 10000 -and -not ($PSBoundParameters.ContainsKey('PartitionKey')))
        {
            New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewCollectionParitionKeyOfferRequired)
        }

        $headers += @{
            'x-ms-offer-throughput' = $OfferThroughput
        }
        $null = $PSBoundParameters.Remove('OfferThroughput')
    }

    if ($PSBoundParameters.ContainsKey('OfferType'))
    {
        Write-Warning -Message $LocalizedData.WarningNewCollectionOfferTypeDeprecated
        $headers += @{
            'x-ms-offer-type' = $OfferType
        }
        $null = $PSBoundParameters.Remove('OfferType')
    }

    if ($PSBoundParameters.ContainsKey('AutoscaleThroughput'))
    {
        if (-not ($PSBoundParameters.ContainsKey('PartitionKey')))
        {
            New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewCollectionParitionKeyAutoscaleRequired)
        }

        $headers += @{
            'x-ms-cosmos-offer-autopilot-settings' = ConvertTo-Json -InputObject @{
                maxThroughput = $AutoscaleThroughput
            } -Compress
        }
        $null = $PSBoundParameters.Remove('AutoscaleThroughput')
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
    elseif ($PSBoundParameters.ContainsKey('IndexingPolicyJson'))
    {
        $bodyObject += @{
            indexingPolicy = ConvertFrom-Json -InputObject $IndexingPolicyJson
        }
        $null = $PSBoundParameters.Remove('IndexingPolicyJson')
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

    $body = ConvertTo-Json -InputObject $bodyObject -Depth 20

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
