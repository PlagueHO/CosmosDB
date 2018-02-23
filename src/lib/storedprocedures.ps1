<#
.SYNOPSIS
    Set the custom Cosmos DB stored procedure types to the
    stored procedure returned by an API call.

.DESCRIPTION
    This function applies the custom types to the stored
    procedure returned by an API call.

.PARAMETER StoredProcedure
    This is the stored procedure that is returned by a
    stored procedure API call.
#>
function Set-CosmosDbStoredProcedureType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $StoredProcedure
    )

    foreach ($item in $StoredProcedure)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.StoredProcedure')
    }

    return $StoredProcedure
}

<#
.SYNOPSIS
    Return the resource path for a stored procedure object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a
    stored procedure object.

.PARAMETER Database
    This is the database containing the stored procedure.

.PARAMETER CollectionId
    This is the Id of the collection containing the stored procedure.

.PARAMETER Id
    This is the Id of the stored procedure.
#>
function Get-CosmosDbStoredProcedureResourcePath
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

    return ('dbs/{0}/colls/{1}/sprocs/{2}' -f $Database, $CollectionId, $Id)
}

<#
.SYNOPSIS
    Return the stored procedures for a CosmosDB database collection.

.DESCRIPTION
    This cmdlet will return the stored procedures for a specified
    collection in a CosmosDB database. If an Id is specified then only
    the specified stored procedures will be returned.

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

.PARAMETER CollectionId
    This is the id of the collection to get the stored procedure for.

.PARAMETER Id
    This is the id of the stored procedures to return.
#>
function Get-CosmosDbStoredProcedure
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
        $CollectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')

    $resourcePath = ('colls/{0}/sprocs' -f $CollectionId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $storedProcedure = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'sprocs' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'sprocs' `
            -ResourcePath $resourcePath

        $storedProcedure = $result.StoredProcedures
    }

    if ($storedProcedure)
    {
        return (Set-CosmosDbStoredProcedureType -StoredProcedure $storedProcedure)
    }
}

<#
.SYNOPSIS
    Execute a new stored procedure for a collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will execute a stored procedure contained in a collection
    in a CosmosDB.

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

.PARAMETER CollectionId
    This is the Id of the collection that contains the stored procedure
    to execute.

.PARAMETER Id
    This is the Id of the stored procedure to execute.

.PARAMETER StoredProcedureParameters
    This is an array of strings containing the parameters to pass to
    the stored procedure.
#>
function Invoke-CosmosDbStoredProcedure
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
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $StoredProcedureParameter
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/sprocs/{1}' -f $CollectionId, $Id)

    if ($PSBoundParameters.ContainsKey('StoredProcedureParameter'))
    {
        $body = ( $StoredProcedureParameter | ForEach-Object { "`"$_`"" } ) -join ','
        $body = "[$body]"
        $null = $PSBoundParameters.Remove('StoredProcedureParameter')
    }
    else
    {
        $body = '[]'
    }

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath `
        -Body $body
}

<#
.SYNOPSIS
    Create a new stored procedure for a collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a stored procedure for a collection in a CosmosDB.

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

.PARAMETER CollectionId
    This is the Id of the collection to create the stored procedure for.

.PARAMETER Id
    This is the Id of the stored procedure to create.

.PARAMETER StoredProcedureBody
    This is the body of the stored procedure.
#>
function New-CosmosDbStoredProcedure
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
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $StoredProcedureBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('StoredProcedureBody')

    $resourcePath = ('colls/{0}/sprocs' -f $CollectionId)

    $StoredProcedureBody = ((($StoredProcedureBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $storedProcedure = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$StoredProcedureBody`" }"

    if ($storedProcedure)
    {
        return (Set-CosmosDbStoredProcedureType -StoredProcedure $storedProcedure)
    }
}

<#
.SYNOPSIS
    Delete a stored procedure from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will delete a stored procedure in a CosmosDB from a collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to delete the stored procedure from.

.PARAMETER Id
    This is the Id of the stored procedure to delete.
#>
function Remove-CosmosDbStoredProcedure
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
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/sprocs/{1}' -f $CollectionId, $Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath
}

<#
.SYNOPSIS
    Update a stored procedure from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will update an existing stored procedure in a CosmosDB
    collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to update the stored procedure for.

.PARAMETER Id
    This is the Id of the stored procedure to update.

.PARAMETER StoredProcedureBody
    This is the body of the stored procedure.
#>
function Set-CosmosDbStoredProcedure
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
        $StoredProcedureBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('StoredProcedureBody')

    $resourcePath = ('colls/{0}/sprocs/{1}' -f $CollectionId, $Id)

    $StoredProcedureBody = ((($StoredProcedureBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $storedProcedure = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$StoredProcedureBody`" }"

    if ($storedProcedure)
    {
        return (Set-CosmosDbStoredProcedureType -StoredProcedure $storedProcedure)
    }
}
