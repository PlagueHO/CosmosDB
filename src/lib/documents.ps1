<#
.SYNOPSIS
    Return the resource path for a document object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a
    document object.

.PARAMETER Database
    This is the database containing the document.

.PARAMETER CollectionId
    This is the Id of the collection containing the
    document.

.PARAMETER Id
    This is the Id of the document.
#>
function Get-CosmosDbDocumentResourcePath
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
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('dbs/{0}/colls/{1}/docs/{2}' -f $Database, $CollectionId, $Id)
}

<#
.SYNOPSIS
    Return the documents for a CosmosDB database collection.

.DESCRIPTION
    This cmdlet will return the documents for a specified
    collection in a CosmosDB database. If an Id is specified then only
    the specified documents will be returned.

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

.PARAMETER CollectionId
    This is the id of the collection to get the documents for.

.PARAMETER Id
    This is the id of the document to return.

.PARAMETER MaxItemCount
    An integer indicating the maximum number of items to be
    returned per page. Should not be set if Id is set.

.PARAMETER ContinuationToken
    A string token returned for queries and read-feed operations
    if there are more results to be read. Should not be set if
    Id is set.

.PARAMETER ConsistencyLevel
    This is the consistency level override. The override must
    be the same or weaker than the account’s configured consistency
    level. Should not be set if Id is set.

.PARAMETER SessionToken
    A string token used with session level consistency. Clients
    must echo the latest read value of this header during read
    requests for session consistency. Should not be set if Id is
    set.

.PARAMETER PartitionKeyRangeId
    The partition key range Id for reading data. Should not be set
    if Id is set.

.PARAMETER Query
    A SQL select query to execute to select the documents. This
    should not be specified if Id is specified.

.PARAMETER QueryParameters
    This is an array of key value pairs (Name, Value) that will be
    passed into the SQL Query. This should only be specified if
    Query is specified.

.PARAMETER QueryEnableCrossPartition
    If the collection is partitioned, this must be set to True to
    allow execution across multiple partitions. This should only
    be specified if Query is specified.
#>
function Get-CosmosDbDocument
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
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
        $CollectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Int32]
        $MaxItemCount = -1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContinuationToken,

        [Parameter()]
        [ValidateSet('Strong', 'Bounded', 'Session', 'Eventual')]
        [System.String]
        $ConsistencyLevel,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $SessionToken,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PartitionKeyRangeId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Query,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable[]]
        $QueryParameters,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean]
        $QueryEnableCrossPartition = $False
    )

    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('MaxItemCount')
    $null = $PSBoundParameters.Remove('ContinuationToken')
    $null = $PSBoundParameters.Remove('ConsistencyLevel')
    $null = $PSBoundParameters.Remove('SessionToken')
    $null = $PSBoundParameters.Remove('PartitionKeyRangeId')
    $null = $PSBoundParameters.Remove('Query')
    $null = $PSBoundParameters.Remove('QueryParameters')
    $null = $PSBoundParameters.Remove('QueryEnableCrossPartition')

    $resourcePath = ('colls/{0}/docs' -f $CollectionId)
    $method = 'Get'

    if (-not [String]::IsNullOrEmpty($Id))
    {
        # A document Id has been specified
        return Invoke-CosmosDbRequest @PSBoundParameters `
            -Method $method `
            -ResourceType 'docs' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else
    {
        $headers = @{}
        $body = ''

        if (-not [String]::IsNullOrEmpty($Query))
        {
            # A query has been specified
            $method = 'Post'

            $headers += @{
                'x-ms-documentdb-isquery' = $True
            }

            if ($QueryEnableCrossPartition -eq $True)
            {
                $headers += @{
                    'x-ms-documentdb-query-enablecrosspartition' = $True
                }
            }

            # Set the content type to application/query+json for querying
            $null = $PSBoundParameters.Add('ContentType', 'application/query+json')

            # Create the body JSON for the query
            $bodyObject = @{ query = $Query }
            if (-not [String]::IsNullOrEmpty($QueryParameters))
            {
                $bodyObject += @{ parameters = $QueryParameters }
            }
            $body = ConvertTo-Json -InputObject $bodyObject
        }
        else
        {
            if (-not [String]::IsNullOrEmpty($PartitionKeyRangeId))
            {
                $headers += @{
                    'x-ms-documentdb-partitionkeyrangeid' = $PartitionKeyRangeId
                }
            }
        }

        # The following headers apply when querying documents or just getting a list
        $headers += @{
            'x-ms-max-item-count' = $MaxItemCount
        }

        if (-not [String]::IsNullOrEmpty($ContinuationToken))
        {
            $headers += @{
                'x-ms-continuation' = $ContinuationToken
            }
        }

        if (-not [String]::IsNullOrEmpty($ConsistencyLevel))
        {
            $headers += @{
                'x-ms-consistency-level' = $ConsistencyLevel
            }
        }

        if (-not [String]::IsNullOrEmpty($SessionToken))
        {
            $headers += @{
                'x-ms-session-token' = $SessionToken
            }
        }

        # Because the headers of this request will contain important information
        # then we need to use a plain web request.
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method $method `
            -ResourceType 'docs' `
            -ResourcePath $resourcePath `
            -Headers $headers `
            -Body $body `
            -UseWebRequest

        $tempObject = (ConvertFrom-JSON -InputObject $result.Content)

        return [PSCustomObject] @{
            _rid      = $tempObject._rid
            Documents = $tempObject.Documents
            _count    = $tempObject._count
            Headers   = $result.Headers
        }
    }
}

<#
.SYNOPSIS
    Create a new document for a collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a document for a collection in a CosmosDB.

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

.PARAMETER CollectionId
    This is the Id of the collection to create the document for.

.PARAMETER DocumentBody
    This is the body of the document. It must be formatted as
    a JSON string and contain the Id value of the document to
    create.

    The document body must contain an id field.

.PARAMETER IndexingDirective
    Include adds the document to the index. Exclude omits the
    document from indexing. The default for indexing behavior is
    determined by the automatic property’s value in the indexing
    policy for the collection.
#>
function New-CosmosDbDocument
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Connection,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentBody,

        [Parameter()]
        [ValidateSet('Include', 'Exclude')]
        [System.String]
        $IndexingDirective
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('DocumentBody')

    $resourcePath = ('colls/{0}/docs' -f $CollectionId)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('IndexingDirective'))
    {
        $headers += @{
            'x-ms-indexing-directive' = $IndexingDirective
        }
        $null = $PSBoundParameters.Remove('IndexingDirective')
    }

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'docs' `
        -ResourcePath $resourcePath `
        -Body $DocumentBody `
        -Headers $headers
}

<#
.SYNOPSIS
    Delete a document from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will delete a document in a CosmosDB from a collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to delete the document from.

.PARAMETER Id
    This is the Id of the document to delete.

.PARAMETER PartitionKey
    The partition key value for the document to be deleted.
    Must be included if and only if the collection is created
    with a partitionKey definition.
#>
function Remove-CosmosDbDocument
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Connection,

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

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CollectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PartitionKey
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/docs/{1}' -f $CollectionId, $Id)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('PartitionKeyRangeId'))
    {
        $headers += @{
            'x-ms-documentdb-partitionkey' = $PartitionKey
        }
        $null = $PSBoundParameters.Remove('PartitionKeyRangeId')
    }

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'docs' `
        -ResourcePath $resourcePath `
        -Headers $headers
}

<#
.SYNOPSIS
    Update a document from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will update an existing document in a CosmosDB
    collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to update the document for.

.PARAMETER Id
    This is the Id of the document to update.

.PARAMETER DocumentBody
    This is the body of the document to update. It must be
    formatted as a JSON string and contain the Id value of the
    document to create.

.PARAMETER IndexingDirective
    Include includes the document in the indexing path while
    Exclude omits the document from indexing.

.PARAMETER PartitionKey
    The partition key value for the document to be deleted.
    Required if and must be specified only if the collection is
    created with a partitionKey definition.
#>
function Set-CosmosDbDocument
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Connection,

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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentBody,

        [Parameter()]
        [ValidateSet('Include', 'Exclude')]
        [System.String]
        $IndexingDirective,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PartitionKey
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('DocumentBody')

    $resourcePath = ('colls/{0}/docs/{1}' -f $CollectionId, $Id)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('IndexingDirective'))
    {
        $headers += @{
            'x-ms-indexing-directive' = $IndexingDirective
        }
        $null = $PSBoundParameters.Remove('IndexingDirective')
    }

    if ($PSBoundParameters.ContainsKey('PartitionKeyRangeId'))
    {
        $headers += @{
            'x-ms-documentdb-partitionkey' = $PartitionKey
        }
        $null = $PSBoundParameters.Remove('PartitionKeyRangeId')
    }

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'docs' `
        -ResourcePath $resourcePath `
        -Body $DocumentBody `
        -Headers $headers
}
