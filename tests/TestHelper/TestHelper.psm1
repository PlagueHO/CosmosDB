# This module provides helper functions for executing tests

<#
    .SYNOPSIS
        Get an Azure service principal details from a settings file.

    .PARAMETER SettingsFilePath
        The path to the settings file containing the service principal details.
#>
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

<#
    .SYNOPSIS
        Connect to Azure using a servince principal.
#>
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

    Write-Verbose -Message "Logging in to Azure using Service Principal $ApplicationId"

    # Build platform does not offer solution for passing secure strings
    $azureCredential = New-Object `
        -Typename System.Management.Automation.PSCredential `
        -Argumentlist $ApplicationId, $applicationPassword

    # Suppress request to share usage information
    $azurePowerShellPath = "$Home\AppData\Roaming\Windows Azure Powershell\"

    if (-not (Test-Path -Path $azurePowerShellPath))
    {
        $null = New-Item -Path $azurePowerShellPath -ItemType Directory
    }

    $azureProfileFilename = Join-Path `
        -Path $azurePowerShellPath `
        -ChildPath 'AzureDataCollectionProfile.json'
    $null = Set-Content `
        -Value '{"enableAzureDataCollection":true}' `
        -Path $azureProfileFilename

    try
    {
        # Perform login
        $null = Connect-AzAccount `
            -ServicePrincipal `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId `
            -Credential $azureCredential

        # Validate login
        $loginSuccessful = Get-AzSubscription `
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

<#
    .SYNOPSIS
        Get the Entra ID OAuth2 Token for the account authenticated to Azure.

    .DESCRIPTION
        This is used to test Entra ID authentication when RBAC is enabled as per
        https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac

    .OUTPUTS
        System.String
#>
function Get-AzureEntraIdOAuth2Token
{
    [CmdletBinding()]
    param ()

    $context = Get-AzContext
    $instanceProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($instanceProfile)
    $token = $profileClient.AcquireAccessToken($context.Tenant.TenantId)

    # Output the access token
    return $token.AccessToken
}

<#
    .SYNOPSIS
        Create a new Azure Cosmos DB Account for use with testing.
#>
function New-AzureTestCosmosDbAccount
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName
    )

    try
    {
        Write-Verbose -Message ('Creating Cosmos DB test account {0}.' -f $Name)

        # Build hashtable of deployment parameters
        $azureDeployFolder = Join-Path -Path $PSScriptRoot -ChildPath 'AzureDeploy'
        $deployName = ('Deploy_{0}' -f $AccountName)
        $deploymentParameters = @{
            Name                    = $deployName
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = Join-Path -Path $azureDeployFolder -ChildPath 'AzureDeploy.Bicep'
            TemplateParameterObject = @{
                AccountName = $Name
                PrincipalId = $ApplicationId
            }
        }

        if ($PSCmdlet.ShouldProcess('Azure', ("Create an Azure Cosmos DB test account '{0}' in resource group '{1}'" -f $Name, $ResourceGroupName)))
        {
            # Deploy ARM template
            New-AzResourceGroupDeployment `
                @deploymentParameters
        }
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the deployment of the Cosmos DB test account.`n$($_.exception.message)"
    }
}

<#
    .SYNOPSIS
        Remove an existing Azure Cosmos DB Account that was used for testing.
#>
function Remove-AzureTestCosmosDbAccount
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        Write-Verbose -Message ('Removing Cosmos DB test account {0}.' -f $Name)

        if ($PSCmdlet.ShouldProcess('Azure', ("Remove Azure Cosmos DB test account '{0}' from resource group '{1}'" -f $Name, $ResourceGroupName)))
        {
            # Remove resource group
            $null = Remove-AzResource `
                -ResourceName $Name `
                -Name $ResourceGroupName `
                -Force `
                -AsJob
        }
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the removal of the Cosmos DB test account.`n$($_.exception.message)"
    }
}

<#
    .SYNOPSIS
        Create a new Azure resource group for use with testing.
#>
function New-AzureTestCosmosDbResourceGroup
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
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

        if ($PSCmdlet.ShouldProcess('Azure', ("Create Azure Cosmos DB resource group '{0}'" -f $ResourceGroupName)))
        {
            $null = New-AzResourceGroup `
                -Name $ResourceGroupName `
                -Location $Location
        }
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the creation of the Azure Resource Group.`n$($_.exception.message)"
    }
}

<#
    .SYNOPSIS
        Remove an existing Azure resource group that was used with testing.
#>
function Remove-AzureTestCosmosDbResourceGroup
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName
    )

    try
    {
        Write-Verbose -Message ('Removing test Azure Resource Group {0}.' -f $ResourceGroupName)

        if ($PSCmdlet.ShouldProcess('Azure', ("Remove Azure Cosmos DB resource group '{0}'" -f $ResourceGroupName)))
        {
            $null = Remove-AzResourceGroup `
                -Name $ResourceGroupName `
                -Force `
                -AsJob
        }
    }
    catch [System.Exception]
    {
        Write-Error -Message "An error occured during the removal of the Azure Resource Group.`n$($_.exception.message)"
    }
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
        [System.String]
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
    Get-InvalidArgumentRecord,
    Get-InvalidOperationRecord
