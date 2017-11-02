<#
.SYNOPSIS
    Return the resource path for a database object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a database
    object.

.PARAMETER Id
    This is the Id of the database.
#>
function Get-CosmosDbDatabaseResourcePath
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

    return ('dbs/{0}' -f $Id)
}

<#
.SYNOPSIS
    Return the databases in a CosmosDB account.

.DESCRIPTION
    This cmdlet will return the databases in a CosmosDB account.
    If the Id is specified then only the database matching this
    Id will be returned, otherwise all databases will be returned.

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be accessed. It should be created
    by `New-CosmosDbConnection`.

    If the connection contains a database it will be ignored.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the database to get.
#>
function Get-CosmosDbDatabase
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([System.String])]
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
        $Id
    )

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        return Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'dbs' `
            -ResourcePath ('dbs/{0}' -f $Id)
    }
    else
    {
        return Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'dbs'
    }
}

<#
.SYNOPSIS
    Create a new database in a CosmosDB account.

.DESCRIPTION
    This cmdlet will create a database in CosmosDB.

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbConnection`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the database to create.
#>
function New-CosmosDbDatabase
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('Id')

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'dbs' `
        -Body "{ `"id`": `"$id`" }"
}

<#
.SYNOPSIS
    Delete a datanase from a CosmosDB account.

.DESCRIPTION
    This cmdlet will delete a database in CosmosDB.

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be deleted. It should be created
    by `New-CosmosDbConnection`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Id
    This is the Id of the database to delete.
#>
function Remove-CosmosDbDatabase
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('Id')

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'dbs' `
        -ResourcePath ('dbs/{0}' -f $Id)
}
