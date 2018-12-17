function New-CosmosDbAccount
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

    $newAzResource_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
        Properties   = $cosmosDBProperties
    }

    if ($PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldCreateAzureCosmosDBAccount -f $Name, $ResourceGroupName, $Location)))
    {
        Write-Verbose -Message $($LocalizedData.CreatingAzureCosmosDBAccount -f $Name, $ResourceGroupName, $Location)

        return (New-AzResource @newAzResource_parameters -Force)
    }
}
