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
    Return the collections in a CosmosDB database.

.DESCRIPTION
    This cmdlet will return the collections in a CosmosDB database.
    If the Id is specified then only the collection matching this
    Id will be returned, otherwise all collections will be returned.

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be accessed. It should be created
    by `New-CosmosDbConnection`.

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
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Connection]
        $Connection,

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

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbConnection`.

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
    This value is used to configure the partition key to be used
    for partitioning data into multiple partitions.
#>
function New-CosmosDbCollection
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Connection]
        $Connection,

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
        $PartitionKey
    )

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('OfferThroughput') -and `
            $PSBoundParameters.ContainsKey('OfferType'))
    {
        New-InvalidOperationException -Message $($LocalizedData.ErrorNewCollectionOfferParameterConflict)
    }

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
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

    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $body = "{ `"id`": `"$id`", `"partitionKey`": { `"paths`": [ `"/$PartitionKey`" ], `"kind`": `"Hash`" } }"
        $null = $PSBoundParameters.Remove('PartitionKey')
    }
    else
    {
        $body = "{ `"id`": `"$id`" }"
    }

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

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbConnection`.

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
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Connection]
        $Connection,

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
