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

Install-Module -Name PSDepend -Force -AllowClobber
Import-Module -Name PSDepend
Invoke-PSDepend -Path $PSScriptRoot -Force -Import -Install

Set-BuildEnvironment -Force

Invoke-Psake -buildFile $ENV:BHProjectPath\psakefile.ps1 -taskList $task -nologo

exit ( [int]( -not $psake.build_success ) )
