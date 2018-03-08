@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'CosmosDB.psm1'

    # Version number of this module.
    ModuleVersion     = '2.0.5.216'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '7d7aeb42-8ed9-4555-b5fd-020795a5aa01'

    # Author of this module
    Author            = 'Daniel Scott-Raynsford'

    # Company or vendor of this module
    CompanyName       = ''

    # Copyright statement for this module
    Copyright         = '(c) 2018 Daniel Scott-Raynsford. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module provides cmdlets for working with Azure Cosmos DB databases, collections, users and permissions.'

    # Minimum version of the Windows PowerShell engine required by this module
    # PowerShellVersion = ''

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
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess    = @(
        'types\attachments.types.ps1xml'
        'types\collections.types.ps1xml'
        'types\databases.types.ps1xml'
        'types\documents.types.ps1xml'
        'types\offers.types.ps1xml'
        'types\permissions.types.ps1xml'
        'types\storedprocedures.types.ps1xml'
        'types\triggers.types.ps1xml'
        'types\userdefinedfunctions.types.ps1xml'
        'types\users.types.ps1xml'
    )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess  = @(
        'formats\attachments.formats.ps1xml'
        'formats\collections.formats.ps1xml'
        'formats\databases.formats.ps1xml'
        'formats\documents.formats.ps1xml'
        'formats\offers.formats.ps1xml'
        'formats\permissions.formats.ps1xml'
        'formats\storedprocedures.formats.ps1xml'
        'formats\triggers.formats.ps1xml'
        'formats\userdefinedfunctions.formats.ps1xml'
        'formats\users.formats.ps1xml'
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-CosmosDbAttachment'
        'Get-CosmosDbAttachmentResourcePath'
        'Get-CosmosDbCollection'
        'Get-CosmosDbCollectionResourcePath'
        'Get-CosmosDBDatabase'
        'Get-CosmosDBDatabaseResourcePath'
        'Get-CosmosDBDocument'
        'Get-CosmosDBDocumentResourcePath'
        'Get-CosmosDBOffer'
        'Get-CosmosDBOfferResourcePath'
        'Get-CosmosDbPermission'
        'Get-CosmosDbPermissionResourcePath'
        'Get-CosmosDbStoredProcedure'
        'Get-CosmosDbStoredProcedureResourcePath'
        'Get-CosmosDbTrigger'
        'Get-CosmosDbTriggerResourcePath'
        'Get-CosmosDbUser'
        'Get-CosmosDbUserResourcePath'
        'Get-CosmosDbUserDefinedFunction'
        'Get-CosmosDbUserDefinedFunctionResourcePath'
        'Invoke-CosmosDbStoredProcedure'
        'New-CosmosDbAttachment'
        'New-CosmosDbCollection'
        'New-CosmosDbCollectionIncludedPathIndex'
        'New-CosmosDbCollectionIncludedPath'
        'New-CosmosDbCollectionExcludedPath'
        'New-CosmosDbCollectionIndexingPolicy'
        'New-CosmosDbDatabase'
        'New-CosmosDbDocument'
        'New-CosmosDbContext'
        'New-CosmosDbPermission'
        'New-CosmosDbStoredProcedure'
        'New-CosmosDbTrigger'
        'New-CosmosDbUser'
        'New-CosmosDbUserDefinedFunction'
        'Remove-CosmosDbAttachment'
        'Remove-CosmosDbCollection'
        'Remove-CosmosDbDatabase'
        'Remove-CosmosDbDocument'
        'Remove-CosmosDbPermission'
        'Remove-CosmosDbStoredProcedure'
        'Remove-CosmosDbTrigger'
        'Remove-CosmosDbUser'
        'Remove-CosmosDbUserDefinedFunction'
        'Set-CosmosDbAttachment'
        'Set-CosmosDbDocument'
        'Set-CosmosDbOffer'
        'Set-CosmosDbStoredProcedure'
        'Set-CosmosDbTrigger'
        'Set-CosmosDbUser'
        'Set-CosmosDbUserDefinedFunction'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @(
        'New-CosmosDbConnection'
    )

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('CosmosDB', 'DocumentDb', 'Azure', 'PSEdition_Core', 'PSEdition_Desktop')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/PlagueHO/CosmosDB/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PlagueHO/CosmosDB'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = '
## What is New in CosmosDB Unreleased

March 8, 2018

- Added `PSEdition_Desktop` tag to manifest.
- Added cmdlet help examples for utils.
- Converted help to MAML file CosmosDB-help.xml.
- Updated AppVeyor build to generate MAML help.

## What is New in CosmosDB 2.0.5.216

March 3, 2018

- Added `*-CosmosDbOffer` cmdlets.

## What is New in CosmosDB 2.0.4.202

February 27, 2018

- Fixed bug in `Get-CosmosDbDocument` when looking up a document in
  a partitioned collection by adding a `PartitionKey` parameter.
- Added `Upsert` parameter to `New-CosmosDbDocument` to enable updating
  a document if it exists.
- Fixed bug in `New-CosmosDbDocument` when adding document to
  a partitioned collection but no partition key is specified - See
  [Issue #48](https://github.com/PlagueHO/CosmosDB/issues/48).
- Fixed bug in `Set-CosmosDbDocument` when updating a document in
  a partitioned collection.
- Fixed bug in `Remove-CosmosDbDocument` when deleting a document in
  a partitioned collection.
- Added check to `New-CosmosDbCollection` to ensure `PartitionKey`
  parameter is passed if `OfferThroughput` is greater than 10000.

## What is New in CosmosDB 2.0.3.190

February 25, 2018

- Added support for creating custom indexing policies when
  creating a new collection.

## What is New in CosmosDB 2.0.2.184

February 24, 2018

- Converted all `connection` function names and parameter names
  over to `context`. Aliases were implemented for old `connection`
  function and parameter names to reduce possibility of breakage.

## What is New in CosmosDB 2.0.1

January 27, 2018

- Added support for CosmosDB Emulator.

## What is New in CosmosDB 2.0.0

December 23, 2017

- BREAKING CHANGE: Converted all cmdlets to return custom types
  and added support for custom formats.

## What is New in CosmosDB 1.0.12

December 9, 2017

- Added support for managing Attachments.

## What is New in CosmosDB 1.0.11

December 8, 2017

- Fix bug in querying documents.

## What is New in CosmosDB 1.0.10

November 12, 2017

- Added support for managing Documents.
            '
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}








