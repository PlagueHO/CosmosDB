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
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ -ArgumentName 'Account' })]
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbUserIdValid -Id $_ -ArgumentName 'UserId' })]
        [System.String]
        $UserId,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbPermissionIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateRange(600,18000)]
        [System.Int32]
        $TokenExpiry
    )

    $PSBoundParameters.Remove('UserId') | Out-Null

    $resourcePath = ('users/{0}/permissions' -f $UserId)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('TokenExpiry'))
    {
        $PSBoundParameters.Remove('TokenExpiry') | Out-Null

        $headers += @{
            'x-ms-documentdb-expiry-seconds' = $TokenExpiry
        }
    }

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $PSBoundParameters.Remove('Id') | Out-Null

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
