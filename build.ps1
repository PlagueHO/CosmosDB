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

Install-Module -Name PSDeploy -Force -AllowClobber
Import-Module -Name PSDeploy
Invoke-PSDepend -Path $PSScriptRoot -Force -Import

Set-BuildEnvironment -Force

Invoke-Psake -buildFile $ENV:BHProjectPath\psakefile.ps1 -taskList $task -nologo

exit ( [int]( -not $psake.build_success ) )
