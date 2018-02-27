<#
.SYNOPSIS
    Set the custom Cosmos DB Collection types to the collection
    returned by an API call.

.DESCRIPTION
    This function applies the custom types to the collection returned
    by an API call.

.PARAMETER Collection
    This is the collection that is returned by a collection API call.
#>
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

<#
.SYNOPSIS
    Return the resource path for a collection object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a collection
    object.

.PARAMETER Database
    This is the database containing the collection.

.PARAMETER Id
    This is the Id of the collection.
#>
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

<#
.SYNOPSIS
    Creates an indexing policy included path index object that
    can be added to an Included Path of an Indexing Policy.

.DESCRIPTION
    This function will return an indexing policy included path index
    object that can be added to an included path Indexing Policy.

.PARAMETER Kind
    The type of index. Hash indexes are useful for equality
    comparisons while Range indexes are useful for equality,
    range comparisons and sorting. Spatial indexes are useful
    for spatial queries.

.PARAMETER DataType
    This is the datatype for which the indexing behavior is
    applied to. Can be String, Number, Point, Polygon, or LineString.
    Note that Booleans and nulls are automatically indexed

.PARAMETER Precision
    The precision of the index. Can be either set to -1 for maximum
    precision or between 1-8 for Number, and 1-100 for String. Not
    applicable for Point, Polygon, and LineString data types.
#>
function New-CosmosDbCollectionIncludedPathIndex
{
    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.Index])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Hash', 'Range', 'Spacial')]
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

    $index = [CosmosDB.IndexingPolicy.Path.Index]::new()
    $index.Kind = $Kind
    $index.DataType = $DataType
    if ($PSBoundParameters.ContainsKey('Precision'))
    {
        $index.Precision = $Precision
    }

    return $index
}

<#
.SYNOPSIS
    Creates an indexing policy included path object that can be
    added to an Indexing Policy.

.DESCRIPTION
    This function will return an indexing policy included path
    object that can be added to an Indexing Policy.

.PARAMETER Path
    Path for which the indexing behavior applies to. Index paths
    start with the root (/) and typically end with the ? wildcard
    operator, denoting that there are multiple possible values for
    the prefix. For example, to serve
    SELECT * FROM Families F WHEREF.familyName = "Andersen", you
    must include an index path for /familyName/? in the collection’s
    index policy.

    Index paths can also use the * wildcard operator to specify the
    behavior for paths recursively under the prefix. For example, /payload/*
    can be used to include everything under the payload property
    from indexing.

.PARAMETER Index
    This is an array of included path index objects that were
    created by New-CosmosDbCollectionIncludedPath.
#>
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

<#
.SYNOPSIS
    Creates an indexing policy excluded path object that can be
    added to an Indexing Policy.

.DESCRIPTION
    This function will return an indexing policy excluded path
    object that can be added to an Indexing Policy.

.PARAMETER Path
    Path that is excluded from indexing. Index paths start with the
    root (/) and typically end with the * wildcard operator..
    For example, /payload/* can be used to exclude everything under
    the payload property from indexing.
#>
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

<#
.SYNOPSIS
    Creates an indexing policy object that can be passed to the
    New-CosmosDbCollection function.

.DESCRIPTION
    This function will return an indexing policy object that can
    be passed to the New-CosmosDbCollection function to configure
    custom indexing policies on a collection.

.PARAMETER Automatic
    Indicates whether automatic indexing is on or off. The default
    value is True, thus all documents are indexed. Setting the value
    to False would allow manual configuration of indexing paths.

.PARAMETER IndexingMode
    By default, the indexing mode is Consistent. This means that
    indexing occurs synchronously during insertion, replacment or
    deletion of documents. To have indexing occur asynchronously,
    set the indexing mode to lazy.

.PARAMETER IncludedPath
    The array containing document paths to be indexed. By default, two
    paths are included: the / path which specifies that all document
    paths be indexed, and the _ts path, which indexes for a timestamp
    range comparison.

.PARAMETER ExcludedPath
    The array containing document paths to be excluded from indexing.
#>
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

<#
.SYNOPSIS
    Return the collections in a CosmosDB database.

.DESCRIPTION
    This cmdlet will return the collections in a CosmosDB database.
    If the Id is specified then only the collection matching this
    Id will be returned, otherwise all collections will be returned.

.PARAMETER Context
    This is an object containing the context information of
    the CosmosDB database that will be accessed. It should be created
    by `New-CosmosDbContext`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Database
    The name of the database to access in the CosmosDB account.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the id of the collection to get. If not specified
    all collections in the database will be returned.
#>
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

<#
.SYNOPSIS
    Create a new collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a collection in a CosmosDB.

.PARAMETER Context
    This is an object containing the context information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbContext`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Database
    The name of the database to access in the CosmosDB account.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the collection to create.

.PARAMETER OfferThroughput
    The user specified throughput for the collection expressed
    in units of 100 request units per second. This can be between
    400 and 250,000 (or higher by requesting a limit increase).
    If specified OfferType should not be specified.

.PARAMETER OfferType
    The user specified performance level for pre-defined performance
    levels S1, S2 and S3. If specified OfferThroughput should not be
    specified.

.PARAMETER PartitionKey
    This value is used to configure the partition keys to be used
    for partitioning data into multiple partitions.

.PARAMETER IndexingPolicy
    This is an Indexing Policy object that was created by the
    New-CosmosDbCollectionIndexingPolicy function.
#>
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
        New-InvalidOperationException -Message $($LocalizedData.ErrorNewCollectionOfferParameterConflict)
    }

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
        if ($OfferThroughput -gt 10000 -and $PartitionKey.Count -eq 0)
        {
            New-InvalidOperationException -Message $($LocalizedData.ErrorNewCollectionParitionKeyRequired)
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
        id  = $id
    }

    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $bodyObject += @{
                partitionKey = @{
                    paths = @('/{0}' -f $PartitionKey)
                    kind = 'Hash'
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

<#
.SYNOPSIS
    Delete a collection from a CosmosDB database.

.DESCRIPTION
    This cmdlet will delete a collection in a CosmosDB.

.PARAMETER Context
    This is an object containing the context information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbContext`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Database
    The name of the database to access in the CosmosDB account.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the collection to delete.
#>
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
