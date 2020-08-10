function New-CosmosDbContext
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Account'
    )]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AzureAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAzureAccount')]
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAccount')]
        [Parameter(ParameterSetName = 'Emulator')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter(ParameterSetName = 'Account')]
        [Parameter(ParameterSetName = 'CustomAccount')]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Alias("ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = 'AzureAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAzureAccount')]
        [ValidateScript({ Assert-CosmosDbResourceGroupNameValid -ResourceGroupName $_ })]
        [System.String]
        $ResourceGroupName,

        [Parameter(ParameterSetName = 'AzureAccount')]
        [Parameter(ParameterSetName = 'CustomAzureAccount')]
        [ValidateSet('PrimaryMasterKey', 'SecondaryMasterKey', 'PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey')]
        [System.String]
        $MasterKeyType = 'PrimaryMasterKey',

        [Parameter(ParameterSetName = 'Emulator')]
        [Switch]
        $Emulator,

        [Parameter(ParameterSetName = 'Emulator')]
        [System.Int16]
        $Port,

        [Parameter(ParameterSetName = 'Emulator')]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Emulator')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.ContextToken[]]
        $Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.BackoffPolicy]
        $BackoffPolicy,

        [Parameter(ParameterSetName = 'Account')]
        [Parameter(ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'AzureAccount')]
        [CosmosDB.Environment]
        $Environment = [CosmosDB.Environment]::AzureCloud,

        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CustomAzureAccount')]
        [System.Uri]
        $EndpointHostname
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'Emulator'
        {
            $Account = 'emulator'

            if (-not ($PSBoundParameters.ContainsKey('Key')))
            {
                # This is a publically known fixed master key (see https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator#authenticating-requests)
                $Key = ConvertTo-SecureString `
                    -String 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==' `
                    -AsPlainText `
                    -Force
            }

            if (-not ($PSBoundParameters.ContainsKey('Uri')))
            {
                $Uri = 'https://localhost:8081'
            }

            if ($Uri -notmatch '^https?:\/\/')
            {
                $Uri = 'https://{0}' -f $Uri
            }

            if ($Uri -notmatch ':\d*$')
            {
                if ($PSBoundParameters.ContainsKey('Port'))
                {
                    Write-Warning -Message $LocalizedData.DeprecateContextPortWarning
                }
                else
                {
                    $Port = 8081
                }

                $Uri = '{0}:{1}' -f $Uri, $Port
            }

            $BaseUri = [System.Uri]::new($Uri)
        }

        'AzureAccount'
        {
            try
            {
                $null = Get-AzContext -ErrorAction SilentlyContinue
            }
            catch
            {
                $null = Connect-AzAccount -Environment $Environment
            }

            $Key = Get-CosmosDbAccountMasterKey `
                -ResourceGroupName $ResourceGroupName `
                -Name $Account `
                -MasterKeyType $MasterKeyType

            $BaseUri = Get-CosmosDbUri -Account $Account -Environment $Environment
        }

        'CustomAzureAccount'
        {
            try
            {
                $null = Get-AzContext -ErrorAction SilentlyContinue
            }
            catch
            {
                New-CosmosDbInvalidOperationException -Message ($LocalizedData.NotLoggedInToCustomCloudException)
            }

            $Key = Get-CosmosDbAccountMasterKey `
                -ResourceGroupName $ResourceGroupName `
                -Name $Account `
                -MasterKeyType $MasterKeyType

            $BaseUri = Get-CosmosDbUri -Account $Account -BaseHostname $EndpointHostname
        }

        'Account'
        {
            $BaseUri = Get-CosmosDbUri -Account $Account -Environment $Environment
        }

        'CustomAccount'
        {
            $BaseUri = Get-CosmosDbUri -Account $Account -BaseHostname $EndpointHostname
        }

        'Token'
        {
            $BaseUri = Get-CosmosDbUri -Account $Account -Environment $Environment
        }
    }

    if ($PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldCreateAzureCosmosDBContext -f $Account, $Database, $BaseUri)))
    {
        $context = New-Object -TypeName 'CosmosDB.Context' -Property @{
            Account       = $Account
            Database      = $Database
            Key           = $Key
            KeyType       = $KeyType
            BaseUri       = $BaseUri
            Token         = $Token
            BackoffPolicy = $BackoffPolicy
        }

        return $context
    }
}
