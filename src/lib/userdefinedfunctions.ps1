<#
.SYNOPSIS
    Set the custom Cosmos DB User Defined Function types to the user
    defined function returned by an API call.

.DESCRIPTION
    This function applies the custom types to the user defined function
    returned by an API call.

.PARAMETER UserDefinedFunction
    This is the user defined function that is returned by a user
    defined function API call.
#>
function Set-CosmosDbUserDefinedFunctionType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $UserDefinedFunction
    )

    foreach ($item in $UserDefinedFunction)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.UserDefinedFunction')
    }

    return $UserDefinedFunction
}

<#
.SYNOPSIS
    Return the resource path for a user defined function object.

.DESCRIPTION
    This cmdlet returns the resource identifier for a
    user defined function object.

.PARAMETER Database
    This is the database containing the user defined function.

.PARAMETER CollectionId
    This is the Id of the collection containing the user defined function.

.PARAMETER Id
    This is the Id of the user defined function.
#>
function Get-CosmosDbUserDefinedFunctionResourcePath
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

    return ('dbs/{0}/colls/{1}/udfs/{2}' -f $Database, $CollectionId, $Id)
}

<#
.SYNOPSIS
    Return the user defined functions for a CosmosDB database collection.

.DESCRIPTION
    This cmdlet will return the user defined functions for a specified
    collection in a CosmosDB database. If an Id is specified then only
    the specified user defined functions will be returned.

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
    This is the id of the collection to get the user defined function for.

.PARAMETER Id
    This is the id of the user defined functions to return.
#>
function Get-CosmosDbUserDefinedFunction
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

    $resourcePath = ('colls/{0}/udfs' -f $CollectionId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $userDefinedFunction = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'udfs' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'udfs' `
            -ResourcePath $resourcePath

        $userDefinedFunction = $result.UserDefinedFunctions
    }

    if ($userDefinedFunction)
    {
        return (Set-CosmosDbUserDefinedFunctionType -UserDefinedFunction $userDefinedFunction)
    }
}

<#
.SYNOPSIS
    Create a new user defined function for a collection in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a user defined function for a collection in a CosmosDB.

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
    This is the Id of the collection to create the user defined function for.

.PARAMETER Id
    This is the Id of the user defined function to create.

.PARAMETER UserDefinedFunctionBody
    This is the body of the user defined function.
#>
function New-CosmosDbUserDefinedFunction
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
        $UserDefinedFunctionBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('UserDefinedFunctionBody')

    $resourcePath = ('colls/{0}/udfs' -f $CollectionId)

    $UserDefinedFunctionBody = ((($UserDefinedFunctionBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $userDefinedFunction = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'udfs' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$UserDefinedFunctionBody`" }"

    if ($userDefinedFunction)
    {
        return (Set-CosmosDbUserDefinedFunctionType -UserDefinedFunction $userDefinedFunction)
    }
}

<#
.SYNOPSIS
    Delete a user defined function from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will delete a user defined function in a CosmosDB from a collection.

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
    This is the Id of the collection to delete the user defined function from.

.PARAMETER Id
    This is the Id of the user defined function to delete.
#>
function Remove-CosmosDbUserDefinedFunction
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

    $resourcePath = ('colls/{0}/udfs/{1}' -f $CollectionId, $Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'udfs' `
        -ResourcePath $resourcePath
}

<#
.SYNOPSIS
    Update a user defined function from a CosmosDB collection.

.DESCRIPTION
    This cmdlet will update an existing user defined function in a CosmosDB
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
    This is the Id of the collection to update the user defined function for.

.PARAMETER Id
    This is the Id of the user defined function to update.

.PARAMETER UserDefinedFunctionBody
    This is the body of the user defined function.
#>
function Set-CosmosDbUserDefinedFunction
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
        $UserDefinedFunctionBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('UserDefinedFunctionBody')

    $resourcePath = ('colls/{0}/udfs/{1}' -f $CollectionId, $Id)

    $UserDefinedFunctionBody = ((($UserDefinedFunctionBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $userDefinedFunction = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'udfs' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$UserDefinedFunctionBody`" }"

    if ($userDefinedFunction)
    {
        return (Set-CosmosDbUserDefinedFunctionType -UserDefinedFunction $userDefinedFunction)
    }
}
