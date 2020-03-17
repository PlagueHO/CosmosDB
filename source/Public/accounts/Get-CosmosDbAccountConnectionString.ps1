function Get-CosmosDbAccountConnectionString
{

    [CmdletBinding()]
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
        [ValidateSet('PrimaryMasterKey', 'SecondaryMasterKey', 'PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey')]
        [System.String]
        $MasterKeyType = 'PrimaryMasterKey'
    )

    $null = $PSBoundParameters.Remove('MasterKeyType')

    $invokeAzResourceAction_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
        Action       = 'listConnectionStrings'
        Force        = $true
    }

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccountConnectionString -f $Name, $ResourceGroupName, $MasterKeyType)

    $connectionStrings = Invoke-AzResourceAction @invokeAzResourceAction_parameters

    $connectionStringMapping = @{
        'PrimaryMasterKey' = 'Primary SQL Connection String'
        'SecondaryMasterKey' = 'Secondary SQL Connection String'
        'PrimaryReadonlyMasterKey' = 'Primary Read-Only SQL Connection String'
        'SecondaryReadonlyMasterKey' = 'Secondary Read-Only SQL Connection String'
    }

    $connectionString = $connectionStrings.connectionStrings | Where-Object -Property description -Eq $connectionStringMapping[$MasterKeyType]

    return $connectionString.connectionString
}
