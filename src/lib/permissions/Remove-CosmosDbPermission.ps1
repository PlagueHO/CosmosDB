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
