function New-CosmosDbContext
{
    [CmdletBinding(DefaultParameterSetName = 'Account')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AzureAccount')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter(ParameterSetName = 'Account')]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true, ParameterSetName = 'AzureAccount')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroup,

        [Parameter(ParameterSetName = 'AzureAccount')]
        [ValidateSet('PrimaryMasterKey', 'SecondaryMasterKey', 'PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey')]
        [System.String]
        $MasterKeyType = 'PrimaryMasterKey',

        [Parameter(ParameterSetName = 'Emulator')]
        [Switch]
        $Emulator,

        [Parameter(ParameterSetName = 'Emulator')]
        [System.Int16]
        $Port = 8081,

        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Emulator')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.ContextToken[]]
        $Token
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'Emulator'
        {
            $Account = 'localhost'

            # This is a publically known fixed master key (see https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator#authenticating-requests)
            $Key = ConvertTo-SecureString `
                -String 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==' `
                -AsPlainText `
                -Force

            $BaseUri = [uri]::new('https://localhost:{0}' -f $Port)
        }

        'AzureAccount'
        {
            try
            {
                $null = Get-AzureRmContext -ErrorAction SilentlyContinue
            }
            catch
            {
                $null = Add-AzureRmAccount
            }

            $resource = Invoke-AzureRmResourceAction `
                -ResourceGroupName $ResourceGroup `
                -Name $Account `
                -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
                -ApiVersion "2015-04-08" `
                -Action listKeys `
                -Force `
                -ErrorAction Stop

            if ($resource)
            {
                $Key = ConvertTo-SecureString `
                    -String ($resource.$MasterKeyType) `
                    -AsPlainText `
                    -Force
            }
            else
            {
                return
            }

            $BaseUri = (Get-CosmosDbUri -Account $Account)
        }

        'Account'
        {
            $BaseUri = (Get-CosmosDbUri -Account $Account)
        }

        'Token'
        {
            $BaseUri = (Get-CosmosDbUri -Account $Account)
        }
    }

    $context = New-Object -TypeName 'CosmosDB.Context' -Property @{
        Account  = $Account
        Database = $Database
        Key      = $Key
        KeyType  = $KeyType
        BaseUri  = $BaseUri
        Token    = $Token
    }

    return $context
}

function New-CosmosDbContextToken
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Resource,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.DateTime]
        $TimeStamp,

        [Parameter()]
        [ValidateRange(600,18000)]
        [System.Int32]
        $TokenExpiry = 3600,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Token
    )

    $contextToken = New-Object -TypeName 'CosmosDB.ContextToken' -Property @{
        Resource  = $Resource
        TimeStamp = $TimeStamp
        Expires   = $TimeStamp.AddSeconds($TokenExpiry)
        Token     = $Token
    }

    return $contextToken
}

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

function New-CosmosDbAuthorizationToken
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

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

    Write-Verbose -Message $($LocalizedData.CreateAuthorizationToken -f $Method, $ResourceType, $ResourceId, $Date)

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Key)
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
    $token = [System.Web.HttpUtility]::UrlEncode(('type={0}&ver={1}&sig={2}' -f $KeyType, $TokenVersion, $signature))
    return $token
}

function Invoke-CosmosDbRequest
{
    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([System.String])]
    param
    (
        [Alias("Connection")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
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
        [ValidateSet('attachments', 'colls', 'dbs', 'docs', 'users', 'permissions', 'triggers', 'sprocs', 'udfs', 'offers')]
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
        $ApiVersion = '2017-02-22',

        [Parameter()]
        [Hashtable]
        $Headers = @{},

        [Parameter()]
        [Switch]
        $UseWebRequest,

        [Parameter()]
        [System.String]
        $ContentType = 'application/json',

        [Parameter()]
        [Switch]
        $RetryOnRequestRateTooLarge
    )

    if ($PSCmdlet.ParameterSetName -eq 'Account')
    {
        $Context = New-CosmosDbContext -Account $Account -Database $Database -Key $Key -KeyType $KeyType
    }

    if (-not ($PSBoundParameters.ContainsKey('Database')))
    {
        $Database = $Context.Database
    }

    # Generate the resource link value that will be used in the URI and to generate the resource id
    switch ($resourceType)
    {
        'dbs'
        {
            # Request for a database object (not containined in a database)
            if ([String]::IsNullOrEmpty($ResourcePath))
            {
                $ResourceLink = 'dbs'
            }
            else
            {
                $resourceLink = $ResourcePath
                $resourceId = $resourceLink
            }
        }

        'offers'
        {
            # Request for an offer object (not contained in a database)
            if ([String]::IsNullOrEmpty($ResourcePath))
            {
                $ResourceLink = 'offers'
            }
            else
            {
                $resourceLink = $ResourcePath
                $resourceId = ($ResourceLink -split '/')[1].ToLowerInvariant()
            }
        }

        default
        {
            # Request for an object that is within a database
            $resourceLink = ('dbs/{0}' -f $Database)

            if ($PSBoundParameters.ContainsKey('ResourcePath'))
            {
                $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourcePath)
            }
            else
            {
                $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourceType)
            }

            # Generate the resource Id from the resource link value
            $resourceElements = [System.Collections.ArrayList] ($resourceLink -split '/')

            if (($resourceElements.Count % 2) -eq 0)
            {
                $resourceId = $resourceLink
            }
            else
            {
                $resourceElements.RemoveAt($resourceElements.Count - 1)
                $resourceId = $resourceElements -Join '/'
            }
        }
    }

    # Generate the URI from the base connection URI and the resource link
    $baseUri = $Context.BaseUri.ToString()
    $uri = [uri]::New(('{0}{1}' -f $baseUri, $resourceLink))

    # Determine the token to use to gain access to the resource
    $token = $null

    if ($null -ne $Context.Token)
    {
        Write-Verbose -Message $($LocalizedData.FindResourceTokenInContext -f $resourceLink)

        # Find the most recent token non-expired matching the resource link
        $matchToken = $context.Token |
            Where-Object -FilterScript { $_.Resource -eq $resourceLink }

        if ($matchToken)
        {
            # One or more matching tokens could be found
            Write-Verbose -Message $($LocalizedData.FoundResourceTokenInContext -f $matchToken.Count, $matchToken.Resource)

            $now = (Get-Date)
            $validToken = $matchToken |
                Where-Object -FilterScript { $_.Expires -gt $now } |
                Sort-Object -Property Expires -Descending |
                Select-Object -First 1

            if ($validToken)
            {
                # One or more matching tokens could be found
                Write-Verbose -Message $($LocalizedData.FoundUnExpiredResourceTokenInContext -f $validToken.Resource, $validToken.TimeStamp)

                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($validToken.Token)
                $decryptedToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                $token = [System.Web.HttpUtility]::UrlEncode($decryptedToken)
                $date = $validToken.TimeStamp
                $dateString = ConvertTo-CosmosDbTokenDateString -Date $date
            }
            else
            {
                # No un-expired matching token could be found, so fall back to using a master key if possible
                Write-Verbose -Message $($LocalizedData.NoMatchingUnexpiredResourceTokenInContext -f $resourceLink)
            }
        }
        else
        {
            # No matching token could be found, so fall back to using a master key if possible
            Write-Verbose -Message $($LocalizedData.NotFoundResourceTokenInContext -f $resourceLink)
        }
    }

    if ($null -eq $token)
    {
        <#
            A token in the context that matched the resource link could not
            be found. So use the master key to generate the resource link.
        #>
        if (-not ($PSBoundParameters.ContainsKey('Key')))
        {
            if (-not [System.String]::IsNullOrEmpty($Context.Key))
            {
                $Key = $Context.Key
            }
        }

        if ([System.String]::IsNullOrEmpty($Key))
        {
            New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorAuthorizationKeyEmpty)
        }

        # Generate the date used for the authorization token
        $date = Get-Date
        $dateString = ConvertTo-CosmosDbTokenDateString -Date $date

        $token = New-CosmosDbAuthorizationToken `
            -Key $Key `
            -KeyType $KeyType `
            -Method $Method `
            -ResourceType $ResourceType `
            -ResourceId $resourceId `
            -Date $date
    }

    $Headers += @{
        'authorization' = $token
        'x-ms-date'     = $dateString
        'x-ms-version'  = $ApiVersion
    }

    $invokeRestMethodParameters = @{
        Uri         = $uri
        Headers     = $Headers
        Method      = $method
        ContentType = $ContentType
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
    do {
        try
        {
            if ($UseWebRequest)
            {
                $restResult = Invoke-WebRequest -UseBasicParsing @invokeRestMethodParameters
            }
            else
            {
                $restResult = Invoke-RestMethod @invokeRestMethodParameters
            }
            $done = $true;
        }
        catch [Microsoft.PowerShell.Commands.HttpResponseException]
        {
            if($_.Exception.Response.StatusCode -eq 429 -and $RetryOnRequestRateTooLarge)
            {
                [int] $delay = [int](($_.Exception.Response.Headers | Where-Object Key -eq 'x-ms-retry-after-ms').Value[0])
                Write-Verbose -Message "Retry Caught, delaying $delay ms"
                Start-Sleep -Milliseconds $delay
            }
            else
            {
                Throw $_
            }
        }
        catch [System.Net.WebException]
        {
            <#
                Write out additional exception information into the verbose stream
                In a future version a custom exception type for CosmosDB that
                contains this additional information.
            #>
            if ($_.Exception.Response)
            {
                $exceptionStream = $_.Exception.Response.GetResponseStream()
                $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $exceptionStream
                $exceptionResponse = $streamReader.ReadToEnd()
                if ($exceptionResponse)
                {
                    Write-Verbose -Message $exceptionResponse
                }
            }

            Throw $_
        }
        catch
        {
            Throw $_
        }
    } while ($done -ne $true)

    if($restResult.Headers.'x-ms-request-charge')
    {
        Write-Verbose -Message "Request Charge: $($restResult.Headers.'x-ms-request-charge') RUs"
    }

    return $restResult
}

function New-CosmosDbInvalidArgumentException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ArgumentName
    )

    $argumentException = New-Object -TypeName 'ArgumentException' -ArgumentList @( $Message,
        $ArgumentName )
    $newObjectParams = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @( $argumentException, $ArgumentName, 'InvalidArgument', $null )
    }
    $errorRecord = New-Object @newObjectParams

    throw $errorRecord
}

function New-CosmosDbInvalidOperationException
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $Message)
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException'
    }
    elseif ($null -eq $ErrorRecord)
    {
        $invalidOperationException =
        New-Object -TypeName 'InvalidOperationException' -ArgumentList @( $Message )
    }
    else
    {
        $invalidOperationException =
        New-Object -TypeName 'InvalidOperationException' -ArgumentList @( $Message,
            $ErrorRecord.Exception )
    }

    $newObjectParams = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @( $invalidOperationException.ToString(), 'MachineStateIncorrect',
            'InvalidOperation', $null )
    }
    $errorRecordToThrow = New-Object @newObjectParams
    throw $errorRecordToThrow
}
