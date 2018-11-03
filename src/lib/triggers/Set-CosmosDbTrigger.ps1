function Set-CosmosDbTrigger
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

    $resourcePath = ('colls/{0}/triggers/{1}' -f $CollectionId, $Id)

    $TriggerBody = ((($TriggerBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'triggers' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$TriggerBody`", `"triggerOperation`" : `"$triggerOperation`", `"triggerType`" : `"$triggerType`" }"

    $trigger = ConvertFrom-Json -InputObject $result.Content

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}
