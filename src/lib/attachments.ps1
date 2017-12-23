<#
.SYNOPSIS
    Set the custom Cosmos DB Attachment types to the attachment
    returned by an API call.

.DESCRIPTION
    This function applies the custom types to the attachment
    returned by an API call.

.PARAMETER UserDefinedFunction
    This is the attachment that is returned by an attachment API call.
#>
function Set-CosmosDbAttachmentType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Attachment
    )

    foreach ($item in $Attachment)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Attachment')
    }

    return $Attachment
}

<#
.SYNOPSIS
    Return the resource path for an attachment object.

.DESCRIPTION
    This cmdlet returns the resource identifier for an
    attachment object.

.PARAMETER Database
    This is the database containing the attachment.

.PARAMETER CollectionId
    This is the Id of the collection containing the attachment.

.PARAMETER DocumentId
    This is the Id of the document containing the attachment.

.PARAMETER Id
    This is the Id of the attachment.
#>
function Get-CosmosDbAttachmentResourcePath
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
        $DocumentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    return ('dbs/{0}/colls/{1}/docs/{2}/attachments/{3}' -f $Database, $CollectionId, $DocumentId, $Id)
}

<#
.SYNOPSIS
    Return the attachments for a CosmosDB document.

.DESCRIPTION
    This cmdlet will return the attachments for a specified document
    in a CosmosDB database. If an Id is specified then only the
    specified permission will be returned.

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
    This is the Id of the collection to get the attachments for.

.PARAMETER DocumentId
    This is the Id of the document to get the attachments for.

.PARAMETER Id
    This is the Id of the attachment to retrieve.
#>
function Get-CosmosDbAttachment
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')

    $resourcePath = ('colls/{0}/docs/{1}/attachments' -f $CollectionId, $DocumentId)

    if (-not [String]::IsNullOrEmpty($Id))
    {
        $null = $PSBoundParameters.Remove('Id')

        $attachment = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'attachments' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)
    }
    else {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'attachments' `
            -ResourcePath $resourcePath

        $attachment = $result.Attachments
    }

    if ($attachment)
    {
        return (Set-CosmosDbAttachmentType -Attachment $attachment)
    }
}

<#
.SYNOPSIS
    Create a new attachment for a document in a CosmosDB database.

.DESCRIPTION
    This cmdlet will create a attachment for a document in a CosmosDB.

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
    This is the Id of the collection to create the attachment in.

.PARAMETER DocumentId
    This is the Id of the document to create the attachment on.

.PARAMETER Id
    Not Required to be set when attaching raw media. This is a user
    settable property. It is the unique name that identifies the
    attachment, i.e. no two attachments will share the same id.
    The id must not exceed 255 characters.

.PARAMETER ContentType
    Not Required to be set when attaching raw media. This is a user
    settable property. It notes the content type of the attachment.

.PARAMETER Media
    Not Required to be set when attaching raw media. This is the
    URL link or file path where the attachment resides.

.PARAMETER Slug
    The name of the attachment. This is only required when raw media
    is submitted to the Azure Cosmos DB attachment storage.
#>
function New-CosmosDbAttachment
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
        $DocumentId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Media,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Slug
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')

    $resourcePath = ('colls/{0}/docs/{1}/attachments' -f $CollectionId, $DocumentId)

    $headers = @{}
    $bodyObject = @{}

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')
        $bodyObject += @{ id = $Id }
    }

    if ($PSBoundParameters.ContainsKey('ContentType'))
    {
        $null = $PSBoundParameters.Remove('ContentType')
        $bodyObject += @{ contentType = $ContentType }
    }

    if ($PSBoundParameters.ContainsKey('Media'))
    {
        $null = $PSBoundParameters.Remove('Media')
        $bodyObject += @{ media = $Media }
    }

    if ($PSBoundParameters.ContainsKey('Slug'))
    {
        $headers += @{
            'Slug' = $Slug
        }
        $null = $PSBoundParameters.Remove('Slug')
    }

    $body = ConvertTo-Json -InputObject $bodyObject

    $attachment = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'attachments' `
        -ResourcePath $resourcePath `
        -Body $body `
        -Headers $headers

    if ($attachment)
    {
        return (Set-CosmosDbAttachmentType -Attachment $attachment)
    }
}

<#
.SYNOPSIS
    Delete an attachment from a CosmosDB document.

.DESCRIPTION
    This cmdlet will delete an attachment in a CosmosDB from a document.

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
    This is the Id of the collection to delete the attachment from.

.PARAMETER DocumentId
    This is the Id of the document to delete the attachment from.

.PARAMETER Id
    This is the Id of the attachment to delete.
#>
function Remove-CosmosDbAttachment
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/docs/{1}/attachments/{2}' -f $CollectionId, $DocumentId, $Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'attachments' `
        -ResourcePath $resourcePath
}

<#
.SYNOPSIS
    Update am attachment for a CosmosDB document.

.DESCRIPTION
    This cmdlet will update an existing attachment in a CosmosDB
    document.

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
    This is the Id of the collection to update the attachment for.

.PARAMETER DocumentId
    This is the Id of the collection to update the attachment for.

.PARAMETER Id
    This is the Id of the attachment to update.

.PARAMETER NewId
    This is the new Id of the attachment if renaming the attachment.

.PARAMETER ContentType
    Not Required to be set when attaching raw media. This is a user
    settable property. It notes the content type of the attachment.

.PARAMETER Media
    Not Required to be set when attaching raw media. This is the
    URL link or file path where the attachment resides.

.PARAMETER Slug
    The name of the attachment. This is only required when raw media
    is submitted to the Azure Cosmos DB attachment storage.
#>
function Set-CosmosDbAttachment
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
        $DocumentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Media,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Slug
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/docs/{1}/attachments/{2}' -f $CollectionId, $DocumentId, $Id)

    $headers = @{}
    $bodyObject = @{}

    if ($PSBoundParameters.ContainsKey('NewId'))
    {
        $null = $PSBoundParameters.Remove('NewId')
        $bodyObject += @{ id = $NewId }
    }
    else
    {
        $bodyObject += @{ id = $Id }
    }

    if ($PSBoundParameters.ContainsKey('ContentType'))
    {
        $null = $PSBoundParameters.Remove('ContentType')
        $bodyObject += @{ contentType = $ContentType }
    }

    if ($PSBoundParameters.ContainsKey('Media'))
    {
        $null = $PSBoundParameters.Remove('Media')
        $bodyObject += @{ media = $Media }
    }

    if ($PSBoundParameters.ContainsKey('Slug'))
    {
        $headers += @{
            'Slug' = $Slug
        }
        $null = $PSBoundParameters.Remove('Slug')
    }

    $body = ConvertTo-Json -InputObject $bodyObject

    $attachment = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'attachments' `
        -ResourcePath $resourcePath `
        -Body $body `
        -Headers $headers

    if ($attachment)
    {
        return (Set-CosmosDbAttachmentType -Attachment $attachment)
    }
}
