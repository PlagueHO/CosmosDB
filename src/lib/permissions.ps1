<#
.SYNOPSIS
    Return the resource path for a permission object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a
    permission object.

.PARAMETER Database
    This is the database containing the permission.

.PARAMETER UserId
    This is the Id of the user containing the permission.

.PARAMETER PermissionId
    This is the Id of the permission.
#>
function Get-CosmosDbPermissionResourcePath
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
        $UserId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('dbs/{0}/users/{1}/permissions/{2}' -f $Database, $UserId, $Id)
}

<#
.SYNOPSIS
    Return the permissions for a CosmosDB database user.

.DESCRIPTION
    This cmdlet will return the permissions for a specified user
    in a CosmosDB database. If an Id is specified then only the
    specified permission will be returned.

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

.PARAMETER UserId
    This is the id of the user to get the permissions for.

.PARAMETER Id
    This is the id of the permission to return.
#>
function Get-CosmosDbPermission
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
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('UserId')

    $resourcePath = ('users/{0}/permissions' -f $UserId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        return Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'permissions' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else
    {
        return Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'permissions' `
            -ResourcePath $resourcePath
    }
}

<#
.SYNOPSIS
    Create a new permission for a user in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a permission for a user in a CosmosDB.

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

.PARAMETER UserId
    This is the id of the user to create the permissions for.

.PARAMETER Id
    This is the Id of the permission to create.

.PARAMETER Resource
    This is the full path to the resource to grant permission
    to the user.

.PARAMETER PermissionsMode
    The permission to grant to the user: All or Read.
#>
function New-CosmosDbPermission
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
        $UserId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Resource,

        [Parameter()]
        [ValidateSet('All', 'Read')]
        [System.String]
        $PermissionMode = 'All'
    )

    $null = $PSBoundParameters.Remove('UserId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('Resource')
    $null = $PSBoundParameters.Remove('PermissionMode')

    $resourcePath = ('users/{0}/permissions' -f $UserId)

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'permissions' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"permissionMode`" : `"$PermissionMode`", `"resource`" : `"$Resource`" }"
}

<#
.SYNOPSIS
    Delete a permission from a CosmosDB user.

.DESCRIPTION
    This cmdlet will delete a permission in a CosmosDB from a user.

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

.PARAMETER UserId
    This is the id of the user to delete the permissions from.

.PARAMETER Id
    This is the Id of the permission to delete.
#>
function Remove-CosmosDbPermission
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

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('UserId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('users/{0}/permissions/{1}' -f $UserId,$Id)

    return Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'permissions' `
        -ResourcePath $resourcePath
}
