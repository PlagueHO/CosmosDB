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
        [System.String]
        $ContentType = 'application/json',

        [Parameter()]
        [ValidateSet('Default', 'UTF-8')]
        [System.String]
        $Encoding = 'Default'
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

    $invokeWebRequestParameters = @{
        Uri             = $uri
        Headers         = $Headers
        Method          = $method
        ContentType     = $ContentType
        UseBasicParsing = $true
    }

    if ($Method -in ('Put', 'Post', 'Patch'))
    {
        if ($Method -eq 'Patch')
        {
            $invokeWebRequestParameters['ContentType'] = 'application/json-patch+json'
        }

        if ($Encoding -eq 'UTF-8')
        {
            <#
                An encoding type of UTF-8 was passed so explictly set this in the
                request and convert to the body string to UTF8 bytes.
            #>
            $invokeWebRequestParameters['ContentType'] = ('{0}; charset={1}' -f $invokeWebRequestParameters['ContentType'], $Encoding)
            $invokeWebRequestParameters += @{
                Body = [System.Text.Encoding]::UTF8.GetBytes($Body)
            }
        }
        else
        {
            $invokeWebRequestParameters += @{
                Body = $Body
            }
        }
    }

    $requestComplete = $false
    $retry = 0

    <#
        This should initially be set to $false and changed to $true when fatal error
        is caught
    #>
    $fatal = $false

    do
    {
        try
        {

            $requestResult = Invoke-WebRequest @invokeWebRequestParameters
            $requestComplete = $true
        }
        catch [System.Net.WebException],[Microsoft.PowerShell.Commands.HttpResponseException]
        {
            if ($_.Exception.Response.StatusCode -eq 429)
            {
                <#
                    The exception was caused by exceeding provisioned throughput
                    so determine is we should delay and try again or exit
                #>
                [System.Int32] $retryAfter = ($_.Exception.Response.Headers | Where-Object -Property Key -eq 'x-ms-retry-after-ms').Value[0]

                $delay = Get-CosmosDbBackoffDelay `
                    -BackOffPolicy $Context.BackoffPolicy `
                    -Retry $retry `
                    -RequestedDelay $retryAfter

                # A null delay means retries have been exceeded or no back-off policy specified
                if ($null -ne $delay)
                {
                    $retry++
                    Write-Verbose -Message $($LocalizedData.WaitingBackoffPolicyDelay -f $retry, $delay)
                    Start-Sleep -Milliseconds $delay
                    continue
                }
            }

            if ($_.Exception.Response)
            {
                <#
                    Write out additional exception information into the verbose stream
                    In a future version a custom exception type for CosmosDB that
                    contains this additional information.
                #>

                if($PSEdition -eq 'Core')
                {
                    # https://get-powershellblog.blogspot.com/2017/11/powershell-core-web-cmdlets-in-depth.html#L13
                    $exceptionResponse = $_.ErrorDetails
                }
                else
                {
                    $exceptionStream = $_.Exception.Response.GetResponseStream()
                    $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $exceptionStream
                    $exceptionResponse = $streamReader.ReadToEnd()
                }

                if ($exceptionResponse)
                {
                    Write-Verbose -Message $exceptionResponse
                }
            }

            # A non-recoverable exception occurred
            $fatal = $true

            Throw $_
        }
        catch
        {
            # A non-recoverable exception occurred
            $fatal = $true

            Throw $_
        }
    } while ($requestComplete -eq $false -and -not $fatal)

    # Display the Request Charge as a verbose message
    $requestCharge = [Uri]::UnescapeDataString($requestResult.Headers.'x-ms-request-charge').Trim()
    if ($requestCharge)
    {
        Write-Verbose -Message $($LocalizedData.RequestChargeResults -f $method, $uri, $requestCharge)
    }

    return $requestResult
}