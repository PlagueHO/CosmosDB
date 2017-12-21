<#
.SYNOPSIS
    Set the custom Cosmos DB trigger types to the trigger returned
    by an API call.

.DESCRIPTION
    This function applies the custom types to the trigger returned
    by an API call.

.PARAMETER Trigger
    This is the trigger that is retunred by a trigger API call.
#>
function Set-CosmosDbTriggerType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Trigger
    )

    foreach ($item in $Trigger)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Trigger')
    }

    return $Trigger
}

<#
.SYNOPSIS
    Return the resource path for a trigger object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a
    trigger object.

.PARAMETER Database
    This is the database containing the trigger.

.PARAMETER CollectionId
    This is the Id of the collection containing the trigger.

.PARAMETER Id
    This is the Id of the trigger.
#>
function Get-CosmosDbTriggerResourcePath
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
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('dbs/{0}/colls/{1}/triggers/{2}' -f $Database, $CollectionId, $Id)
}

<#
.SYNOPSIS
    Return the triggers for a CosmosDB database collection.

.DESCRIPTION
    This cmdlet will return the triggers for a specified collection
    in a CosmosDB database. If an Id is specified then only the
    specified trigger will be returned.

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

.PARAMETER CollectionId
    This is the id of the collection to get the triggers for.

.PARAMETER Id
    This is the id of the trigger to return.
#>
function Get-CosmosDbTrigger
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
        $CollectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')

    $resourcePath = ('colls/{0}/triggers' -f $CollectionId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $trigger = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'triggers' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'triggers' `
            -ResourcePath $resourcePath

        $trigger = $result.Triggers
    }

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}

<#
.SYNOPSIS
    Create a new trigger for a collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a trigger for a collection in a CosmosDB.

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

.PARAMETER CollectionId
    This is the Id of the collection to create the trigger for.

.PARAMETER Id
    This is the Id of the trigger to create.

.PARAMETER TriggerBody
    This is the body of the trigger.

.PARAMETER TriggerOperation
    This is the type of operation that will invoke the trigger.

.PARAMETER TriggerType
    This specifies when the trigger will be fired.
#>
function New-CosmosDbTrigger
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
        [ValidateSet('All', 'Insert', 'Replace', 'Delete')]
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

    $trigger = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'triggers' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$TriggerBody`", `"triggerOperation`" : `"$triggerOperation`", `"triggerType`" : `"$triggerType`" }"

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}

<#
.SYNOPSIS
    Delete a trigger from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will delete a trigger in a CosmosDB from a collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to delete the trigger from.

.PARAMETER Id
    This is the Id of the trigger to delete.
#>
function Remove-CosmosDbTrigger
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
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
        $CollectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/triggers/{1}' -f $CollectionId, $Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'triggers' `
        -ResourcePath $resourcePath
}

<#
.SYNOPSIS
    Update a trigger from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will update an existing trigger in a CosmosDB
    collection.

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

.PARAMETER CollectionId
    This is the Id of the collection to update the trigger for.

.PARAMETER Id
    This is the Id of the trigger to update.

.PARAMETER TriggerBody
    This is the body of the trigger.

.PARAMETER TriggerOperation
    This is the type of operation that will invoke the trigger.

.PARAMETER TriggerType
    This specifies when the trigger will be fired.
#>
function Set-CosmosDbTrigger
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
        [ValidateSet('All', 'Insert', 'Replace', 'Delete')]
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

    $trigger = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'triggers' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$TriggerBody`", `"triggerOperation`" : `"$triggerOperation`", `"triggerType`" : `"$triggerType`" }"

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}
