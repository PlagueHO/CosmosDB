<#
.SYNOPSIS
    Set the custom Cosmos DB User types to the user
    returned by an API call.

.DESCRIPTION
    This function applies the custom types to the user returned
    by an API call.

.PARAMETER User
    This is the user that is returned by a user API call.
#>
function Set-CosmosDbUserType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $User
    )

    foreach ($item in $User)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.User')
    }

    return $User
}

<#
.SYNOPSIS
    Return the resource path for a user object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a user
    object.

.PARAMETER Database
    This is the database containing the user.

.PARAMETER Id
    This is the Id of the user.
#>
function Get-CosmosDbUserResourcePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Id
    )

    return ('dbs/{0}/users/{1}' -f $Database, $Id)
}

<#
.SYNOPSIS
    Return the users in a CosmosDB database.

.DESCRIPTION
    This cmdlet will return the users in a CosmosDB database.
    If the Id is specified then only the user matching this
    Id will be returned, otherwise all users will be returned.

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
function Get-CosmosDbUser
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $user = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'users' `
            -ResourcePath ('users/{0}' -f $Id)
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'users'

        $user = $result.Users
    }

    if ($user)
    {
        return (Set-CosmosDbUserType -User $user)
    }
}

<#
.SYNOPSIS
    Create a new user in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a user in a CosmosDB.

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
    This is the Id of the user to create.
#>
function New-CosmosDbUser
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
        $Id
    )

    $null = $PSBoundParameters.Remove('Id')

    $user = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'users' `
        -Body "{ `"id`": `"$Id`" }"

    if ($user)
    {
        return (Set-CosmosDbUserType -User $user)
    }
}

<#
.SYNOPSIS
    Delete a user from a CosmosDB database.

.DESCRIPTION
    This cmdlet will delete a user in a CosmosDB.

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
    This is the Id of the user to delete.
#>
function Remove-CosmosDbUser
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
        $Id
    )

    $null = $PSBoundParameters.Remove('Id')

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'users' `
        -ResourcePath ('users/{0}' -f $Id)
}

<#
.SYNOPSIS
    Set the user Id of an existing user in a CosmosDB database.

.DESCRIPTION
    This cmdlet will set the user Id of an existing  user in
    a CosmosDB.

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
    The user Id of the user to set.

.PARAMETER NewId
    This is the new Id of rhe user.
#>
function Set-CosmosDbUser
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
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewId
    )

    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('NewId')

    $user = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'users' `
        -ResourcePath ('users/{0}' -f $Id) `
        -Body "{ `"id`": `"$NewId`" }"

    if ($user)
    {
        return (Set-CosmosDbUserType -User $user)
    }
}
