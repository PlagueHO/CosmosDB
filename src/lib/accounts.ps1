function Get-CosmosDbAccount
{
    [CmdletBinding()]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName
    )

    $getAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

    return Get-AzureRmResource @getAzureRmResource_parameters
}


function New-CosmosDbAccount
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $LocationRead,

        [Parameter()]
        [ValidateSet('Eventual', 'Strong', 'Session', 'BoundedStaleness')]
        [System.String]
        $DefaultConsistencyLevel = 'Session',

        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Int32]
        $MaxIntervalInSeconds = 5,

        [Parameter()]
        [ValidateRange(1, [Int32]::MaxValue)]
        [System.Int32]
        $MaxStalenessPrefix = 100,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IpRangeFilter = @(),

        [Parameter()]
        [Switch]
        $AsJob
    )

    <#
        Assemble a location object that will be used to generate the request JSON.
        It will consist of a single write location and 0 or more read locations.
    #>
    $locationObject = @(
        @{
            locationName     = $Location
            failoverPriority = 0
        })

    $failoverPriority = 1

    foreach ($locationReadItem in $LocationRead)
    {
        $locationObject += @{
            locationName     = $locationReadItem
            failoverPriority = $failoverPriority
        }
        $failoverPriority++
    }

    $consistencyPolicyObject = @{
        defaultConsistencyLevel = $DefaultConsistencyLevel
        maxIntervalInSeconds    = $MaxIntervalInSeconds
        maxStalenessPrefix      = $MaxStalenessPrefix
    }

    $cosmosDBProperties = @{
        databaseAccountOfferType = 'Standard'
        locations                = $locationObject
        consistencyPolicy        = $consistencyPolicyObject
        ipRangeFilter            = ($IpRangeFilter -join ',')
    }

    $null = $PSBoundParameters.Remove('LocationRead')
    $null = $PSBoundParameters.Remove('DefaultConsistencyLevel')
    $null = $PSBoundParameters.Remove('MaxIntervalInSeconds')
    $null = $PSBoundParameters.Remove('MaxStalenessPrefix')
    $null = $PSBoundParameters.Remove('IpRangeFilter')

    $newAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
        Properties        = $cosmosDBProperties
    }

    if ($PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldCreateAzureCosmosDBAccount -f $Name, $ResourceGroupName, $Location)))
    {
        Write-Verbose -Message $($LocalizedData.CreatingAzureCosmosDBAccount -f $Name, $ResourceGroupName, $Location)

        return (New-AzureRmResource @newAzureRmResource_parameters -Force)
    }
}

function Set-CosmosDbAccount
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter()]
        [System.String[]]
        $LocationRead,

        [Parameter()]
        [ValidateSet('Eventual', 'Strong', 'Session', 'BoundedStaleness')]
        [System.String]
        $DefaultConsistencyLevel,

        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Int32]
        $MaxIntervalInSeconds,

        [Parameter()]
        [ValidateRange(1, [Int32]::MaxValue)]
        [System.Int32]
        $MaxStalenessPrefix,

        [Parameter()]
        [System.String[]]
        $IpRangeFilter,

        [Parameter()]
        [Switch]
        $AsJob
    )

    # Get the existing Cosmos DB Account
    $getCosmosDbAccount_parameters = @{} + $PSBoundParameters
    $null = $getCosmosDbAccount_parameters.Remove('Location')
    $null = $getCosmosDbAccount_parameters.Remove('LocationRead')
    $null = $getCosmosDbAccount_parameters.Remove('DefaultConsistencyLevel')
    $null = $getCosmosDbAccount_parameters.Remove('MaxIntervalInSeconds')
    $null = $getCosmosDbAccount_parameters.Remove('MaxStalenessPrefix')
    $null = $getCosmosDbAccount_parameters.Remove('IpRangeFilter')
    $null = $getCosmosDbAccount_parameters.Remove('AsJob')
    $existingAccount = Get-CosmosDbAccount @getCosmosDbAccount_parameters

    if (-not $existingAccount)
    {
        New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorAccountDoesNotExist -f $Name, $ResourceGroupName)
    }

    <#
        Assemble a location object that will be used to generate the request JSON.
        It will consist of a single write location and 0 or more read locations.
    #>
    if (-not ($PSBoundParameters.ContainsKey('Location')))
    {
        $Location = $existingAccount.Location
    }

    $locationObject = @(
        @{
            locationName     = $Location
            failoverPriority = 0
        })

    if ($PSBoundParameters.ContainsKey('LocationRead'))
    {
        $failoverPriority = 1

        foreach ($locationReadItem in $LocationRead)
        {
            $locationObject += @{
                locationName     = $locationReadItem
                failoverPriority = $failoverPriority
            }
            $failoverPriority++
        }
    }

    if (-not ($PSBoundParameters.ContainsKey('DefaultConsistencyLevel')))
    {
        $DefaultConsistencyLevel = $existingAccount.Properties.consistencyPolicy.defaultConsistencyLevel
    }

    if (-not ($PSBoundParameters.ContainsKey('MaxIntervalInSeconds')))
    {
        $MaxIntervalInSeconds = $existingAccount.Properties.consistencyPolicy.maxIntervalInSeconds
    }

    if (-not ($PSBoundParameters.ContainsKey('MaxStalenessPrefix')))
    {
        $MaxStalenessPrefix = $existingAccount.Properties.consistencyPolicy.maxStalenessPrefix
    }

    $consistencyPolicyObject = @{
        defaultConsistencyLevel = $DefaultConsistencyLevel
        maxIntervalInSeconds    = $MaxIntervalInSeconds
        maxStalenessPrefix      = $MaxStalenessPrefix
    }

    if ($PSBoundParameters.ContainsKey('IpRangeFilter'))
    {
        $ipRangeFilterString = ($IpRangeFilter -join ',')
    }
    else
    {
        $ipRangeFilterString = $existingAccount.Properties.ipRangeFilter
    }

    $cosmosDBProperties = @{
        databaseAccountOfferType = 'Standard'
        locations                = $locationObject
        consistencyPolicy        = $consistencyPolicyObject
        ipRangeFilter            = $ipRangeFilterString
    }

    $null = $PSBoundParameters.Remove('Location')
    $null = $PSBoundParameters.Remove('LocationRead')
    $null = $PSBoundParameters.Remove('DefaultConsistencyLevel')
    $null = $PSBoundParameters.Remove('MaxIntervalInSeconds')
    $null = $PSBoundParameters.Remove('MaxStalenessPrefix')
    $null = $PSBoundParameters.Remove('IpRangeFilter')

    $setAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
        Properties        = $cosmosDBProperties
    }

    if ($PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldUpdateAzureCosmosDBAccount -f $Name, $ResourceGroupName)))
    {
        Write-Verbose -Message $($LocalizedData.UpdatingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

        return (Set-AzureRmResource @setAzureRmResource_parameters -Force)
    }
}

function Remove-CosmosDbAccount
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter()]
        [Switch]
        $AsJob,

        [Parameter()]
        [Switch]
        $Force
    )

    $removeAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
    }

    if ($Force -or `
            $PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldRemoveAzureCosmosDBAccount -f $Name, $ResourceGroupName)))
    {
        Write-Verbose -Message $($LocalizedData.RemovingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

        $null = Remove-AzureRmResource @removeAzureRmResource_parameters
    }
}
