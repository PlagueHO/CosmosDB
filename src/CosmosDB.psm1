#Requires -version 5.0

$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

#region Types
if (-not ([System.Management.Automation.PSTypeName]'CosmosDB.Context').Type)
{
    $typeDefinition = @'
namespace CosmosDB {
    public class Context
    {
        public System.String Account;
        public System.String Database;
        public System.Security.SecureString Key;
        public System.String KeyType;
        public System.String BaseUri;
    }
}
'@
    Add-Type -TypeDefinition $typeDefinition
}
#endregion

#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}

Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename 'CosmosDB.strings.psd1' `
    -BaseDirectory $moduleRoot `
    -UICulture $culture
#endregion

#region ImportFunctions
# Dot source any functions in the libs folder
$libs = Get-ChildItem `
    -Path (Join-Path -Path $moduleRoot -ChildPath 'lib') `
    -Include '*.ps1' `
    -Recurse

Foreach ($lib in $libs)
{
    Write-Verbose -Message $($LocalizedData.ImportingLibFileMessage -f $lib.Fullname)
    . $lib.Fullname
}
#endregion

# Add Aliases
New-Alias -Name 'New-CosmosDbConnection' -Value 'New-CosmosDbContext' -Force
