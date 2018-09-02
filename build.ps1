[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $Deploy
)

$task = 'Default'
if ($Deploy)
{
    $task = 'Deploy'
}

$null = Get-PackageProvider -Name NuGet -ForceBootstrap

# Install PSDepend module
if (-not (Get-Module -Name PSDepend -ListAvailable))
{
    try
    {
        Install-Module -Name PSDepend -Force -AllowClobber
    }
    catch
    {
        Install-Module -Name PSDepend -Force -AllowClobber -Scope CurrentUser
    }
}

# Install all other build dependencies
Import-Module -Name PSDepend
Invoke-PSDepend -Path $PSScriptRoot -Force -Import -Install

Set-BuildEnvironment -Force

Invoke-Psake -buildFile $ENV:BHProjectPath\psakefile.ps1 -taskList $task -nologo

exit ( [int]( -not $psake.build_success ) )
