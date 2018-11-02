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
