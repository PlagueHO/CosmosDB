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

function Get-CosmosDbAttachment
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

function New-CosmosDbAttachment
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

function Remove-CosmosDbAttachment
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

function Set-CosmosDbAttachment
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
