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
