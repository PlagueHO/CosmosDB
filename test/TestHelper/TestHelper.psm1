# This module provides helper functions for executing tests
function Get-AzureServicePrincipal
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $SettingsFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'AzureConnection.user.ps1')
    )

    if ((Test-Path -Path $SettingsFilePath))
    {
        Write-Verbose -Message ('Loading Azure Connection Settings from User File ''{0}''.' -f $SettingsFilePath)
        & $SettingsFilePath
    }
    else
    {
        Write-Verbose -Message 'Getting Azure Connection Settings from Environment Variables.'
    }
}

function Connect-AzureServicePrincipal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationId,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $ApplicationPassword,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TenantId
    )

    try
    {
        Write-Verbose -Message "Logging in to Azure using Service Principal $ApplicationId"

        # Build platform (AppVeyor) does not offer solution for passing secure strings
        $azureCredential = New-Object `
            -Typename System.Management.Automation.PSCredential `
            -Argumentlist $ApplicationId, $applicationPassword

        # Suppress request to share usage information
        $path = "$Home\AppData\Roaming\Windows Azure Powershell\"
        if (-not (Test-Path -Path $Path))
        {
            $null = New-Item -Path $Path -ItemType Directory
        }
        $azureProfileFilename = Join-Path `
            -Path $Path `
            -ChildPath 'AzureDataCollectionProfile.json'
        $null = Set-Content `
            -Value '{"enableAzureDataCollection":true}' `
            -Path $azureProfileFilename

        # Handle login
        $null = Connect-AzAccount `
            -ServicePrincipal `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId `
            -Credential $azureCredential `
            -ErrorAction SilentlyContinue

        # Validate login
        $loginSuccessful = Get-AzureRmSubscription `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId

        if ($null -eq $loginSuccessful)
        {
            throw 'Login to Azure was unsuccessful!'
        }
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured while logging in to Azure`n$($_.exception.message)"
    }
}

function New-AzureTestCosmosDbAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AccountName
    )

    try
    {
        Write-Verbose -Message ('Creating Cosmos DB test account {0}.' -f $AccountName)

        # Build hashtable of deployment parameters
        $azureDeployFolder = Join-Path -Path $PSScriptRoot -ChildPath 'AzureDeploy'
        $deployName = ('Deploy_{0}' -f $AccountName)
        $deploymentParameters = @{
            Name                    = $deployName
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = Join-Path -Path $azureDeployFolder -ChildPath 'AzureDeploy.json'
            TemplateParameterObject = @{
                AccountName = $AccountName
            }
        }

        # Deploy ARM template
        New-AzureRmResourceGroupDeployment `
            @deploymentParameters
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the deployment of the Cosmos DB test account.`n$($_.exception.message)"
    }
}

function Remove-AzureTestCosmosDbAccount
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AccountName
    )

    try
    {
        Write-Verbose -Message ('Removing Cosmos DB test account {0}.' -f $AccountName)

        # Remove resource group as
        $null = Remove-AzureRmResourceGroup `
            -Name $ResourceGroupName `
            -Force `
            -AsJob
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the removal of the Cosmos DB test account.`n$($_.exception.message)"
    }
}

function New-AzureTestCosmosDbResourceGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,

        [Parameter()]
        [System.String]
        $Location = 'East US'
    )

    try
    {
        Write-Verbose -Message ('Creating test Azure Resource Group {0} in {1}.' -f $ResourceGroupName,$Location)

        $null = New-AzureRmResourceGroup `
            -Name $ResourceGroupName `
            -Location $Location
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the creation of the Azure Resource Group.`n$($_.exception.message)"
    }
}

function Remove-AzureTestCosmosDbResourceGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName
    )

    try
    {
        Write-Verbose -Message ('Removing test Azure Resource Group {0}.' -f $ResourceGroupName)

        $null = Remove-AzureRmResourceGroup `
            -Name $ResourceGroupName `
            -Force `
            -AsJob
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the removal of the Azure Resource Group.`n$($_.exception.message)"
    }
}

function Convert-SecureStringToString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Security.SecureString]
        $SecureString
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

<#
    .SYNOPSIS
        Returns an invalid argument exception object

    .PARAMETER Message
        The message explaining why this error is being thrown

    .PARAMETER ArgumentName
        The name of the invalid argument that is causing this error to be thrown
#>
function Get-InvalidArgumentRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ArgumentName
    )

    $argumentException = New-Object -TypeName 'ArgumentException' -ArgumentList @( $Message,
        $ArgumentName )
    $newObjectParams = @{
        TypeName = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @( $argumentException, $ArgumentName, 'InvalidArgument', $null )
    }
    return New-Object @newObjectParams
}

<#
    .SYNOPSIS
        Returns an invalid operation exception object

    .PARAMETER Message
        The message explaining why this error is being thrown

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing this terminating error
#>
function Get-InvalidOperationRecord
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

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
        TypeName = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @( $invalidOperationException.ToString(), 'MachineStateIncorrect',
            'InvalidOperation', $null )
    }
    return New-Object @newObjectParams
}


Export-ModuleMember -Function `
    Get-AzureServicePrincipal, `
    Connect-AzureServicePrincipal, `
    New-AzureTestCosmosDbAccount, `
    Remove-AzureTestCosmosDbAccount, `
    New-AzureTestCosmosDbResourceGroup, `
    Remove-AzureTestCosmosDbResourceGroup,
    Convert-SecureStringToString,
    Get-InvalidArgumentRecord,
    Get-InvalidOperationRecord
