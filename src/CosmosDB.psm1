<#
.EXTERNALHELP CosmosDB-help.xml
#>
#Requires -Version 5.1
#Requires –Modules @{ ModuleName = 'Az.Accounts'; ModuleVersion = '1.0.0'; Guid = '17a2feff-488b-47f9-8729-e2cec094624c' }
#Requires –Modules @{ ModuleName = 'Az.Resources'; ModuleVersion = '1.0.0'; Guid = '48bb344d-4c24-441e-8ea0-589947784700' }

$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

# Import dependent Az modules
Import-Module -Name Az.Accounts -MinimumVersion 1.0.0 -Scope Global
Import-Module -Name Az.Resources -MinimumVersion 1.0.0 -Scope Global

#region Types
if (-not ([System.Management.Automation.PSTypeName]'CosmosDB.Context').Type)
{
    $typeDefinition = @'
namespace CosmosDB {
    public class ContextToken
    {
        public System.String Resource;
        public System.DateTime TimeStamp;
        public System.DateTime Expires;
        public System.Security.SecureString Token;
    }

    public class BackoffPolicy
    {
        public System.Int32 MaxRetries;
        public System.String Method;
        public System.Int32 Delay;
    }

    public class Context
    {
        public System.String Account;
        public System.String Database;
        public System.Security.SecureString Key;
        public System.String KeyType;
        public System.String BaseUri;
        public CosmosDB.ContextToken[] Token;
        public CosmosDB.BackoffPolicy BackoffPolicy;
    }

    namespace IndexingPolicy {
        namespace Path {
            public class Index {
                public System.String dataType;
                public System.String kind;
            }

            public class IndexRange : CosmosDB.IndexingPolicy.Path.Index {
                public System.Int32 precision;
            }

            public class IndexHash : CosmosDB.IndexingPolicy.Path.Index {
                public System.Int32 precision;
            }

            public class IndexSpatial : CosmosDB.IndexingPolicy.Path.Index {
            }

            public class IncludedPath
            {
                public System.String path;
                public CosmosDB.IndexingPolicy.Path.Index[] indexes;
            }

            public class ExcludedPath
            {
                public System.String path;
            }
        }

        public class Policy
        {
            public System.Boolean automatic;
            public System.String indexingMode;
            public CosmosDB.IndexingPolicy.Path.IncludedPath[] includedPaths;
            public CosmosDB.IndexingPolicy.Path.ExcludedPath[] excludedPaths;
        }
    }

    namespace UniqueKeyPolicy {
        public class UniqueKey {
            public System.String[] paths;
        }

        public class Policy
        {
            public CosmosDB.UniqueKeyPolicy.UniqueKey[] uniqueKeys;
        }
    }
}
'@
    Add-Type -TypeDefinition $typeDefinition
}

<#
    This type is available in PowerShell Core, but it is not available in
    Windows PowerShell. It is needed to check the exception type within the
    Invoke-CosmosDbRequest function.
#>
if (-not ([System.Management.Automation.PSTypeName]'Microsoft.PowerShell.Commands.HttpResponseException').Type)
{
    $httpResponseExceptionClassDefinition = @'
namespace Microsoft.PowerShell.Commands
{
    public class HttpResponseException : System.Net.WebException
    {
        public System.Int32 dummy;
    }
}
'@

    Add-Type -TypeDefinition $httpResponseExceptionClassDefinition
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
$libFiles = Get-ChildItem `
    -Path (Join-Path -Path $moduleRoot -ChildPath 'lib') `
    -Include '*.ps1' `
    -Recurse

Foreach ($libFile in $libFiles)
{
    Write-Verbose -Message $($LocalizedData.ImportingLibFileMessage -f $libFile.Fullname)
    . $libFile.Fullname
}
#endregion

# Add Aliases
New-Alias -Name 'New-CosmosDbConnection' -Value 'New-CosmosDbContext' -Force
