<#
.SYNOPSIS
    Create a connection object containing the information required
    to connect to a CosmosDB.

.DESCRIPTION
    This cmdlet is used to simplify the calling of the CosmosDB
    cmdlets by providing all the connection information in an
    object that can be passed to the CosmosDB cmdlets.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Database
    The name of the database to access in the CosmosDB account.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.
#>
function New-CosmosDbConnection
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master'
    )

    return [PSCustomObject] @{
        Account  = $Account
        Database = $Database
        Key      = $Key
        KeyType  = $KeyType
        BaseUri  = (Get-CosmosDbUri -Account $Account)
    }
}

<#
.SYNOPSIS
    Return the URI of the CosmosDB that Rest APIs requests will
    be sent to.

.DESCRIPTION
    This cmdlet returns the root URI of the CosmosDB.

.PARAMETER Account
    This is the name of the CosmosDB Account to get the URI
    for.
#>
function Get-CosmosDbUri
{
    [CmdletBinding()]
    [OutputType([uri])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Account,

        [Parameter()]
        [System.String]
        $BaseUri = 'documents.azure.com'
    )

    return [uri]::new(('https://{0}.{1}' -f $Account, $BaseUri))
}

<#
.SYNOPSIS
    Convert a DateTime object into the format required for use
    in a CosmosDB Authorization Token and request header.

.DESCRIPTION
    This cmdlet converts a DateTime object into the format required
    by the Authorization Token and in the request header.

.PARAMETER Date
    This is the DateTime object to convert.
#>
function ConvertTo-CosmosDbTokenDateString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $Date
    )

    return $Date.ToUniversalTime().ToString("r", [System.Globalization.CultureInfo]::InvariantCulture)
}

<#
.SYNOPSIS
    Create a new Authorization Token to be used with in a
    Rest API request to CosmosDB.

.DESCRIPTION
    This cmdlet is used to create an Authorization Token to
    pass in the header of a Rest API request to an Azure CosmosDB.
    The Authorization token that is generated must match the
    other parameters in the header of the request that is passed.

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be accessed. It should be created
    by `New-CosmosDbConnection`.

.PARAMETER Method
    This is the Rest API method that will be made in the request
    this token is being generated for.

.PARAMETER ResourceType
    This is type of resource being accessed in the CosmosDB.
    For example: users, colls

.PARAMETER ResourceId
    This is the resource Id of the CosmosDB being accessed.
    This is in the format 'dbs/{database}' and must match the
    the value in the path of the URI that the request is made
    to.

.PARAMETER Date
    This is the DateTime of the request being made. This must
    be included in the 'x-ms-date' parameter in the request
    header and match what was provided to this cmdlet.
#>
function New-CosmosDbAuthorizationToken
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Connection,

        [Parameter()]
        [ValidateSet('', 'Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        [System.String]
        $Method = '',

        [Parameter()]
        [System.String]
        $ResourceType = '',

        [Parameter()]
        [System.String]
        $ResourceId = '',

        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $Date,

        [Parameter()]
        [ValidateSet('1.0')]
        [System.String]
        $TokenVersion = '1.0'
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Connection.Key)
    $decryptedKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $base64Key = [System.Convert]::FromBase64String($decryptedKey)
    $hmacSha256 = New-Object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList (, $base64Key)
    $dateString = ConvertTo-CosmosDbTokenDateString -Date $Date
    $payLoad = @(
        $Method.ToLowerInvariant() + "`n" + `
            $ResourceType.ToLowerInvariant() + "`n" + `
            $ResourceId + "`n" + `
            $dateString.ToLowerInvariant() + "`n" + `
            "" + "`n"
    )

    $body = [System.Text.Encoding]::UTF8.GetBytes($payLoad)
    $hashPayLoad = $hmacSha256.ComputeHash($body)
    $signature = [Convert]::ToBase64String($hashPayLoad)

    Add-Type -AssemblyName 'System.Web'
    $token = [System.Web.HttpUtility]::UrlEncode(('type={0}&ver={1}&sig={2}' -f $Connection.KeyType, $TokenVersion, $signature))
    return $token
}

<#
.SYNOPSIS
    Create a new Authorization Token to be used with in a
    Rest API request to CosmosDB.

.DESCRIPTION

.PARAMETER Connection
    This is an object containing the connection information of
    the CosmosDB database that will be accessed. It should be created
    by `New-CosmosDbConnection`.

.PARAMETER Account
    The account name of the CosmosDB to access.

.PARAMETER Key
    The key to be used to access this CosmosDB.

.PARAMETER KeyType
    The type of key that will be used to access ths CosmosDB.

.PARAMETER Database
    If specified will override the value in the connection.

.PARAMETER Method
    This is the Rest API method that will be made to the CosmosDB.

.PARAMETER ResourceType
    This is type of resource being accessed in the CosmosDB.
    For example: users, colls

.PARAMETER ResourcePath
    This is the path to the resource that should be accessed in
    the CosmosDB. This will be appended to the path after the
    resourceId in the URI that will be used to access the resource.

.PARAMETER Body
    This is the body of the request that will be submitted if the
    method is 'Put', 'Post' or 'Patch'.

.PARAMETER ApiVersion
    This is the version of the Rest API that will be called.
#>
function Invoke-CosmosDbRequest
{
    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    [OutputType([System.String])]
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

        [Parameter()]
        [ValidateSet('Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        [System.String]
        $Method = 'Get',

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourcePath,

        [Parameter()]
        [System.String]
        $Body = '',

        [Parameter()]
        [ValidateSet('2014-08-21', '2015-04-08', '2015-06-03', '2015-08-06', '2015-12-16', '2016-07-11', '2017-01-19', '2017-02-22')]
        [System.String]
        $ApiVersion = '2017-02-22'
    )

    if ($PSCmdlet.ParameterSetName -eq 'Account')
    {
        $Connection = New-CosmosDbConnection -Account $Account -Database $Database -Key $Key -KeyType $KeyType
    }

    if ($PSBoundParameters.ContainsKey('Database'))
    {
        $Connection.Database = $Database
    }

    if ($PSBoundParameters.ContainsKey('Key'))
    {
        $Connection.Key = $Key
    }

    if ($PSBoundParameters.ContainsKey('KeyType'))
    {
        $Connection.KeyType = $KeyType
    }

    $date = Get-Date
    $dateString = ConvertTo-CosmosDbTokenDateString -Date $date

    # Generate the resource link value that will be used in the URI and to generate the resource id
    if ([String]::IsNullOrEmpty($Connection.Database))
    {
        $resourceLink = $resourceType
    }
    else
    {
        $resourceLink = ('dbs/{0}' -f $Connection.Database)
        if ($PSBoundParameters.ContainsKey('ResourcePath'))
        {
            $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourcePath)
        }
        else
        {
            $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourceType)
        }
    }

    # Generate the resource Id from the resource link value
    $resourceElements = [System.Collections.ArrayList] ($resourceLink -split '/')
    if (($resourceElements.Count % 2) -eq 0)
    {
        $resourceId = $resourceLink
    }
    else
    {
        $resourceElements.RemoveAt($resourceElements.Count-1)
        $resourceId = $resourceElements -Join '/'
    }

    # Generate the URI from the base connection URI and the resource link
    $uri = [uri]::New(('{0}{1}' -f $Connection.BaseUri.ToString(), $resourceLink))

    $token = New-CosmosDbAuthorizationToken `
        -Connection $Connection `
        -Method $Method `
        -ResourceType $ResourceType `
        -ResourceId $resourceId `
        -Date $date

    $headers = @{
        'authorization' = $token
        'x-ms-date'     = $dateString
        'x-ms-version'  = $ApiVersion
    }

    $invokeRestMethodParameters = @{
        Uri         = $uri
        Headers     = $headers
        Method      = $method
        ContentType = 'application/json'
    }

    if ($Method -in ('Put', 'Post', 'Patch'))
    {
        if ($Method -eq 'Patch')
        {
            $invokeRestMethodParameters['contentType'] = 'application/json-patch+json'
        }

        $invokeRestMethodParameters += @{
            Body = $Body
        }
    }

    $restResult = Invoke-RestMethod @invokeRestMethodParameters

    return $restResult
}
