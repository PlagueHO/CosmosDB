function Set-CosmosDbCollection
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
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ -ArgumentName 'Account' })]
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.IndexingPolicy.Policy]
        $IndexingPolicy,

        [Parameter()]
        [ValidateRange(-1,2147483647)]
        [System.Int32]
        $DefaultTimeToLive,

        [Parameter()]
        [Switch]
        $RemoveDefaultTimeToLive,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.UniqueKeyPolicy.Policy]
        $UniqueKeyPolicy
    )

    if ($PSBoundParameters.ContainsKey('DefaultTimeToLive') -and $RemoveDefaultTimeToLive.IsPresent)
    {
        New-CosmosDbInvalidArgumentException `
            -Message $LocalizedData.ErrorSetCollectionRemoveDefaultTimeToLiveConflict `
            -ArgumentName 'RemoveDefaultTimeToLive'
    }

    $headers = @{}

    $bodyObject = @{
        id = $id
    }

    $indexingPolicyIncluded = $PSBoundParameters.ContainsKey('IndexingPolicy')
    $defaultTimeToLiveIncluded = $PSBoundParameters.ContainsKey('DefaultTimeToLive')
    $uniqueKeyPolicyIncluded = $PSBoundParameters.ContainsKey('UniqueKeyPolicy')

    $null = $PSBoundParameters.Remove('IndexingPolicy')
    $null = $PSBoundParameters.Remove('DefaultTimeToLive')
    $null = $PSBoundParameters.Remove('RemoveDefaultTimeToLive')
    $null = $PSBoundParameters.Remove('UniqueKeyPolicy')

    <#
        The partition key on an existing collection can not be changed.
        So to ensure an error does not occur, get the current collection
        and pass the existing partition key in the body.
    #>
    $existingCollection = Get-CosmosDbCollection @PSBoundParameters

    $null = $PSBoundParameters.Remove('Id')

    if ($indexingPolicyIncluded)
    {
        $bodyObject += @{
            indexingPolicy = $IndexingPolicy
        }
    }
    else
    {
        $bodyObject += @{
            indexingPolicy = $existingCollection.indexingPolicy
        }
    }

    if ($existingCollection.partitionKey)
    {
        $bodyObject += @{
            partitionKey = $existingCollection.partitionKey
        }
    }

    if ($defaultTimeToLiveIncluded)
    {
        $bodyObject += @{
            defaultTtl = $DefaultTimeToLive
        }
    }
    elseif ($existingCollection.defaultTtl -and -not $RemoveDefaultTimeToLive)
    {
        $bodyObject += @{
            defaultTtl = $existingCollection.defaultTtl
        }
    }

    if ($uniqueKeyPolicyIncluded)
    {
        $bodyObject += @{
            uniqueKeyPolicy = $UniqueKeyPolicy
        }
    }
    elseif ($existingCollection.uniqueKeyPolicy)
    {
        $bodyObject += @{
            uniqueKeyPolicy = $existingCollection.uniqueKeyPolicy
        }
    }

    $body = ConvertTo-Json -InputObject $bodyObject -Depth 10

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'colls' `
        -ResourcePath ('colls/{0}' -f $Id) `
        -Headers $headers `
        -Body $body

    $collection = ConvertFrom-Json -InputObject $result.Content

    if ($collection)
    {
        return (Set-CosmosDbCollectionType -Collection $collection)
    }
}
