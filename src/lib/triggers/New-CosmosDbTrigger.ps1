function New-CosmosDbTrigger
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
        $TriggerBody,

        [Parameter(Mandatory = $true)]
        [ValidateSet('All', 'Create', 'Replace', 'Delete')]
        [System.String]
        $TriggerOperation,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Pre', 'Post')]
        [System.String]
        $TriggerType
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('TriggerBody')
    $null = $PSBoundParameters.Remove('TriggerOperation')
    $null = $PSBoundParameters.Remove('TriggerType')

    $resourcePath = ('colls/{0}/triggers' -f $CollectionId)

    $TriggerBody = ((($TriggerBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'triggers' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$TriggerBody`", `"triggerOperation`" : `"$triggerOperation`", `"triggerType`" : `"$triggerType`" }"

    $trigger = ConvertFrom-Json -InputObject $result.Content

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}
