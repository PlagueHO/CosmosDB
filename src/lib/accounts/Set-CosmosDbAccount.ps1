function Set-CosmosDbAccount
{

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbResourceGroupNameValid -ResourceGroupName $_ })]
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
    $getCosmosDbAccount_parameters.Remove('Location') | Out-Null
    $getCosmosDbAccount_parameters.Remove('LocationRead') | Out-Null
    $getCosmosDbAccount_parameters.Remove('DefaultConsistencyLevel') | Out-Null
    $getCosmosDbAccount_parameters.Remove('MaxIntervalInSeconds') | Out-Null
    $getCosmosDbAccount_parameters.Remove('MaxStalenessPrefix') | Out-Null
    $getCosmosDbAccount_parameters.Remove('IpRangeFilter') | Out-Null
    $getCosmosDbAccount_parameters.Remove('AsJob') | Out-Null
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

    $PSBoundParameters.Remove('Location') | Out-Null
    $PSBoundParameters.Remove('LocationRead') | Out-Null
    $PSBoundParameters.Remove('DefaultConsistencyLevel') | Out-Null
    $PSBoundParameters.Remove('MaxIntervalInSeconds') | Out-Null
    $PSBoundParameters.Remove('MaxStalenessPrefix') | Out-Null
    $PSBoundParameters.Remove('IpRangeFilter') | Out-Null

    $setAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
        Properties   = $cosmosDBProperties
    }

    if ($PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldUpdateAzureCosmosDBAccount -f $Name, $ResourceGroupName)))
    {
        Write-Verbose -Message $($LocalizedData.UpdatingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

        return (Set-AzureRmResource @setAzureRmResource_parameters -Force)
    }
}
