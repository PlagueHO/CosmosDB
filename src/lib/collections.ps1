function Set-CosmosDbCollectionType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Collection
    )

    foreach ($item in $Collection)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection')
        $item.indexingPolicy.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy')
        foreach ($includedPath in $item.indexingPolicy.includedPaths)
        {
            $includedPath.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.IncludedPath')
            foreach ($index in $includedPath.indexes)
            {
                $index.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.Index')
            }
        }
        foreach ($excludedPath in $item.indexingPolicy.excludedPaths)
        {
            $excludedPath.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.ExcludedPath')
            foreach ($index in $excludedPath.indexes)
            {
                $index.PSObject.TypeNames.Insert(0, 'CosmosDB.Collection.IndexingPolicy.Index')
            }
        }
    }

    return $Collection
}

function Get-CosmosDbCollectionResourcePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('dbs/{0}/colls/{1}' -f $Database, $Id)
}

function New-CosmosDbCollectionIncludedPathIndex
{
    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.Index])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Hash', 'Range', 'Spatial')]
        [System.String]
        $Kind,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Number', 'Point', 'Polygon', 'LineString')]
        [System.String]
        $DataType,

        [Parameter()]
        [Int32]
        $Precision
    )

    # Validate the path index parameters
    switch ($Kind)
    {
        'Hash'
        {
            if ($DataType -notin @('String', 'Number'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'String, Number') `
                    -ArgumentName 'DataType'
            }

            $typeName = 'CosmosDB.IndexingPolicy.Path.IndexHash'
        }

        'Range'
        {
            if ($DataType -notin @('String', 'Number'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'String, Number') `
                    -ArgumentName 'DataType'
            }

            $typeName = 'CosmosDB.IndexingPolicy.Path.IndexRange'
        }

        'Spatial'
        {
            if ($DataType -notin @('Point', 'Polygon', 'LineString'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'Point, Polygon, LineString') `
                    -ArgumentName 'DataType'
            }

            $typeName = 'CosmosDB.IndexingPolicy.Path.IndexSpatial'
        }
    }

    $index = New-Object -TypeName $typeName
    $index.Kind = $Kind
    $index.DataType = $DataType
    if ($PSBoundParameters.ContainsKey('Precision'))
    {
        $index.Precision = $Precision
    }

    return $index
}

function New-CosmosDbCollectionIncludedPath
{
    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.IncludedPath])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = '/*',

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.Index[]]
        $Index
    )

    $includedPath = [CosmosDB.IndexingPolicy.Path.IncludedPath]::new()
    $includedPath.Path = $Path
    $includedPath.Indexes = $Index

    return $includedPath
}

function New-CosmosDbCollectionExcludedPath
{
    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.ExcludedPath])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = '/*'
    )

    $excludedPath = [CosmosDB.IndexingPolicy.Path.ExcludedPath]::new()
    $excludedPath.Path = $Path

    return $excludedPath
}

function New-CosmosDbCollectionIndexingPolicy
{
    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Policy])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $Automatic = $true,

        [Parameter()]
        [ValidateSet('Consistent', 'Lazy')]
        [System.String]
        $IndexingMode = 'Consistent',

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.IncludedPath[]]
        $IncludedPath = @(),

        [Parameter()]
        [CosmosDB.IndexingPolicy.Path.ExcludedPath[]]
        $ExcludedPath = @()
    )

    $indexingPolicy = [CosmosDB.IndexingPolicy.Policy]::new()
    $indexingPolicy.Automatic = $Automatic
    $indexingPolicy.IndexingMode = $IndexingMode
    $indexingPolicy.IncludedPaths = $IncludedPath
    $indexingPolicy.ExcludedPaths = $ExcludedPath

    return $indexingPolicy
}

function Get-CosmosDbCollection
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
        $Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $collection = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'colls' `
            -ResourcePath ('colls/{0}' -f $Id)
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'colls'

        $collection = $result.DocumentCollections
    }

    if ($collection)
    {
        return (Set-CosmosDbCollectionType -Collection $collection)
    }
}

function Get-CosmosDbCollectionSize
{
    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([System.Collections.Hashtable])]
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
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    <#
        per https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-accounts,
        The quota and usage information for the collection is returned in the
        x-ms-resource-quota and x-ms-resource-usage headers in the response.
    #>

    $null = $PSBoundParameters.Remove('Id')

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Get' `
        -ResourceType 'colls' `
        -ResourcePath ('colls/{0}' -f $Id) `
        -UseWebRequest

    $usageItems = @{}
    $($result.headers["x-ms-resource-usage"]).Split(';', [System.StringSplitOptions]::RemoveEmptyEntries) |
        ForEach-Object {
            $k, $v = $_.Split('=')
            $usageItems[$k] = $v
        }

    if ($usageItems)
    {
        return $usageItems
    }
}

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
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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
        $IndexingPolicy
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
                paths = @('/{0}' -f $PartitionKey)
                kind  = 'Hash'
            }
        }
        $null = $PSBoundParameters.Remove('PartitionKey')
    }

    if ($PSBoundParameters.ContainsKey('IndexingPolicy'))
    {
        $bodyObject += @{
            indexingPolicy = $IndexingPolicy
        }
        $null = $PSBoundParameters.Remove('IndexingPolicy')
    }

    $body = ConvertTo-Json -InputObject $bodyObject -Depth 10

    $collection = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'colls' `
        -Headers $headers `
        -Body $body

    return (Set-CosmosDbCollectionType -Collection $collection)
}

function Remove-CosmosDbCollection
{
    [CmdletBinding(DefaultParameterSetName = 'Context')]
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
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('Id')

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'colls' `
        -ResourcePath ('colls/{0}' -f $Id)
}

function Set-CosmosDbCollection
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
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.IndexingPolicy.Policy]
        $IndexingPolicy
    )

    $headers = @{}

    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('IndexingPolicy')

    $bodyObject = @{
        id = $id
    }

    $bodyObject += @{
        indexingPolicy = $IndexingPolicy
    }

    <#
        The partition key on an existing collection can not be changed.
        So to ensure an error does not occur, get the current collection
        and pass the existing partition key in the body.
    #>
    $existingCollection = Get-CosmosDbCollection @PSBoundParameters -Id $Id
    if ($existingCollection.partitionKey)
    {
        $bodyObject += @{
            partitionKey = $existingCollection.partitionKey
        }
    }

    $body = ConvertTo-Json -InputObject $bodyObject -Depth 10

    $collection = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'colls' `
        -ResourcePath ('colls/{0}' -f $Id) `
        -Headers $headers `
        -Body $body

    if ($collection)
    {
        return (Set-CosmosDbCollectionType -Collection $collection)
    }
}
