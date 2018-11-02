<#
.EXTERNALHELP CosmosDB-help.xml
#>
#Requires -version 5.0

$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

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
