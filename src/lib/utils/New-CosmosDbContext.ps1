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
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [Parameter(ParameterSetName = 'Emulator')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter(ParameterSetName = 'Account')]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Alias("ResourceGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = 'AzureAccount')]
        [ValidateScript({ Assert-CosmosDbResourceGroupNameValid -ResourceGroupName $_ })]
        [System.String]
        $ResourceGroupName,

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

        [Parameter(ParameterSetName = 'Emulator')]
        [System.String]
        $URI = 'localhost',

        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Emulator')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.ContextToken[]]
        $Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.BackoffPolicy]
        $BackoffPolicy
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

            $BaseUri = [uri]::new(('https://{0}:{1}' -f $URI, $Port))
        }

        'AzureAccount'
        {
            try
            {
                $null = Get-AzContext -ErrorAction SilentlyContinue
            }
            catch
            {
                $null = Connect-AzAccount
            }

            $Key = Get-CosmosDbAccountMasterKey `
                -ResourceGroupName $ResourceGroupName `
                -Name $Account `
                -MasterKeyType $MasterKeyType

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
