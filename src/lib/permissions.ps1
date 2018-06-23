function Set-CosmosDbPermissionType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Permission
    )

    foreach ($item in $Permission)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Permission')
    }

    return $Permission
}

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

function Get-CosmosDbPermission
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
        $UserId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateRange(600,18000)]
        [System.Int32]
        $TokenExpiry
    )

    $null = $PSBoundParameters.Remove('UserId')

    $resourcePath = ('users/{0}/permissions' -f $UserId)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('TokenExpiry'))
    {
        $null = $PSBoundParameters.Remove('TokenExpiry')

        $headers += @{
            'x-ms-documentdb-expiry-seconds' = $TokenExpiry
        }
    }

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'permissions' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id) `
            -Headers $headers

        $permission = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'permissions' `
            -ResourcePath $resourcePath `
            -Headers $headers

        $body = ConvertFrom-Json -InputObject $result.Content

        $permission = $body.Permissions
    }

    if ($permission)
    {
        return (Set-CosmosDbPermissionType -Permission $permission)
    }
}

function New-CosmosDbPermission
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

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'permissions' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"permissionMode`" : `"$PermissionMode`", `"resource`" : `"$Resource`" }"

    $permission = ConvertFrom-Json -InputObject $result.Content

    if ($permission)
    {
        return (Set-CosmosDbPermissionType -Permission $permission)
    }
}

function Remove-CosmosDbPermission
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
        $UserId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('UserId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('users/{0}/permissions/{1}' -f $UserId,$Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'permissions' `
        -ResourcePath $resourcePath
}
