function Get-CosmosDbPermissionResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbUserIdValid -Id $_ -ArgumentName 'UserId' })]
        [System.String]
        $UserId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbPermissionIdValid -Id $_ })]
        [System.String]
        $Id
    )

    return ('dbs/{0}/users/{1}/permissions/{2}' -f $Database, $UserId, $Id)
}
