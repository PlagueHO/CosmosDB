@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'CosmosDB.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # Supported PSEditions
    CompatiblePSEditions = 'Core', 'Desktop'

    # ID used to uniquely identify this module
    GUID                 = '7d7aeb42-8ed9-4555-b5fd-020795a5aa01'

    # Author of this module
    Author               = 'Daniel Scott-Raynsford'

    # Company or vendor of this module
    CompanyName          = 'None'

    # Copyright statement for this module
    Copyright            = '(c) Daniel Scott-Raynsford. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'This module provides cmdlets for working with Azure Cosmos DB databases, collections, documents, attachments, offers, users, permissions, triggers, stored procedures and user defined functions.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(
        @{ ModuleName = 'Az.Accounts'; GUID = '17a2feff-488b-47f9-8729-e2cec094624c'; ModuleVersion = '1.0.0'; },
        @{ ModuleName = 'Az.Resources'; GUID = '48bb344d-4c24-441e-8ea0-589947784700'; ModuleVersion = '1.0.0'; }
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess       = @(
        'types\attachments.types.ps1xml',
        'types\collections.types.ps1xml',
        'types\databases.types.ps1xml',
        'types\documents.types.ps1xml',
        'types\offers.types.ps1xml',
        'types\permissions.types.ps1xml',
        'types\storedprocedures.types.ps1xml',
        'types\triggers.types.ps1xml',
        'types\userdefinedfunctions.types.ps1xml',
        'types\users.types.ps1xml'
    )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @(
        'formats\attachments.formats.ps1xml',
        'formats\collections.formats.ps1xml',
        'formats\databases.formats.ps1xml',
        'formats\documents.formats.ps1xml',
        'formats\offers.formats.ps1xml',
        'formats\permissions.formats.ps1xml',
        'formats\storedprocedures.formats.ps1xml',
        'formats\triggers.formats.ps1xml',
        'formats\userdefinedfunctions.formats.ps1xml',
        'formats\users.formats.ps1xml'
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @('Get-CosmosDbAccount', 'Get-CosmosDbAccountConnectionString',
        'Get-CosmosDbAccountMasterKey', 'Get-CosmosDbAttachment',
        'Get-CosmosDbAttachmentResourcePath', 'Get-CosmosDbCollection',
        'Get-CosmosDbCollectionResourcePath', 'Get-CosmosDbCollectionSize',
        'Get-CosmosDbContextToken',
        'Get-CosmosDBDatabase', 'Get-CosmosDBDatabaseResourcePath',
        'Get-CosmosDBDocument', 'Get-CosmosDBDocumentResourcePath',
        'Get-CosmosDBOffer', 'Get-CosmosDBOfferResourcePath',
        'Get-CosmosDbPermission', 'Get-CosmosDbPermissionResourcePath',
        'Get-CosmosDbStoredProcedure',
        'Get-CosmosDbStoredProcedureResourcePath', 'Get-CosmosDbTrigger',
        'Get-CosmosDbTriggerResourcePath', 'Get-CosmosDbUser',
        'Get-CosmosDbUserResourcePath', 'Get-CosmosDbUserDefinedFunction',
        'Get-CosmosDbUserDefinedFunctionResourcePath',
        'Invoke-CosmosDbStoredProcedure', 'New-CosmosDbAccount',
        'New-CosmosDbAccountMasterKey', 'New-CosmosDbAttachment',
        'New-CosmosDbBackoffPolicy', 'New-CosmosDbCollection',
        'New-CosmosDbCollectionIncludedPathIndex',
        'New-CosmosDbCollectionIncludedPath',
        'New-CosmosDbCollectionExcludedPath',
        'New-CosmosDbCollectionIndexingPolicy',
        'New-CosmosDbCollectionUniqueKey',
        'New-CosmosDbCollectionUniqueKeyPolicy', 'New-CosmosDbDatabase',
        'New-CosmosDbDocument', 'New-CosmosDbContext',
        'New-CosmosDbContextToken', 'New-CosmosDbPermission',
        'New-CosmosDbStoredProcedure', 'New-CosmosDbTrigger',
        'New-CosmosDbUser', 'New-CosmosDbUserDefinedFunction',
        'Remove-CosmosDbAccount', 'Remove-CosmosDbAttachment',
        'Remove-CosmosDbCollection', 'Remove-CosmosDbDatabase',
        'Remove-CosmosDbDocument', 'Remove-CosmosDbPermission',
        'Remove-CosmosDbStoredProcedure', 'Remove-CosmosDbTrigger',
        'Remove-CosmosDbUser', 'Remove-CosmosDbUserDefinedFunction',
        'Set-CosmosDbAccount', 'Set-CosmosDbAttachment',
        'Set-CosmosDbCollection', 'Set-CosmosDbDocument', 'Set-CosmosDbOffer',
        'Set-CosmosDbStoredProcedure', 'Set-CosmosDbTrigger',
        'Set-CosmosDbUser', 'Set-CosmosDbUserDefinedFunction')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = 'New-CosmosDbConnection'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('CosmosDB', 'DocumentDb', 'Azure', 'PSEdition_Core', 'PSEdition_Desktop', 'Windows', 'Linux', 'MacOS')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/PlagueHO/CosmosDB/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PlagueHO/CosmosDB'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = ''

            Prerelease   = ''
        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

