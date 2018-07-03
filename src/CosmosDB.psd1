@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'CosmosDB.psm1'

    # Version number of this module.
    ModuleVersion     = '2.1.2.514'

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
    Description       = 'This module provides cmdlets for working with Azure Cosmos DB databases, collections, documents, attachments, offers, users, permissions, triggers, stored procedures and user defined functions.'

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
        'Get-CosmosDbCollectionSize'
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
        'New-CosmosDbBackoffPolicy'
        'New-CosmosDbCollection'
        'New-CosmosDbCollectionIncludedPathIndex'
        'New-CosmosDbCollectionIncludedPath'
        'New-CosmosDbCollectionExcludedPath'
        'New-CosmosDbCollectionIndexingPolicy'
        'New-CosmosDbDatabase'
        'New-CosmosDbDocument'
        'New-CosmosDbContext'
        'New-CosmosDbContextToken'
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
        'Set-CosmosDbCollection'
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
## What is New in CosmosDB 2.1.2.514

July 3, 2018

- Changed `New-CosmosDBContext` so that Read Only keys will use the
  `readonlykeys` action endpoint instead of the `listKeys` action - fixes
  [Issue #133](https://github.com/PlagueHO/CosmosDB/issues/133)
- Fixed freeze occuring in functions when `-ErrorAction SilentlyContinue`
  parameter was used and error is returned - fixes [Issue #132](https://github.com/PlagueHO/CosmosDB/issues/132)

## What is New in CosmosDB 2.1.1.498

June 26, 2018

- Changed trigger operation type `Insert` to `Create` in `New-CosmosDBTrigger`
  and `Set-CosmosDBTrigger` functions - fixes [Issue #129](https://github.com/PlagueHO/CosmosDB/issues/129)

## What is New in CosmosDB 2.1.0.487

June 23, 2018

- Removed `UseWebRequest` parameter from `Invoke-CosmosDbReuest` function
  to refactor out the use of `Invoke-RestMethod`. This is because most
  Cosmos DB REST requests return additional header information that is
  lost if using `Invoke-RestMethod`. `Invoke-WebRequest` is used instead
  so that additional headers can always be retured - See [Issue #125](https://github.com/PlagueHO/CosmosDB/issues/125)
- Added integration tests for attachments.
- Added integration tests for stored procedures.
- Added integration tests for triggers.
- Added integration tests for user defined functions.
- Added `New-CosmosDbBackOffPolicy` function for controlling the behaviour
  of a function when a "Too Many Request" (error code 429) is recieved -
  See [Issue #87](https://github.com/PlagueHO/CosmosDB/issues/87)
- Added support for handling a back-off policy to the `Invoke-CosmosDbRequest`
  function.

## What is New in CosmosDB 2.0.16.465

June 20, 2018

- Added None as an IndexingMode - See [Issue #120](https://github.com/PlagueHO/CosmosDB/issues/120)

## What is New in CosmosDB 2.0.15.454

June 15, 2018

- Fix creation of spatial index by `New-CosmosDbCollectionIncludedPathIndex`
  so that precision is not used when passing to `New-CosmosDbCollection`.
- Added support for `-PartitionKey` in `Invoke-CosmosDbStoredProcedure` - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)
- Changed -StoredProcedureParameter from string[] to object[] in `Invoke-CosmosDbStoredProcedure` - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)
- Updated `Invoke-CosmosDbStoredProcedure` to set `x-ms-documentdb-script-enable-logging: true` header and write stored procedure logs to the Verbose Stream when `-Debug` is set - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)

## What is New in CosmosDB 2.0.14.439

June 12, 2018

- Fixed Code Coverage upload to CodeCov.io.
- Fix `New-CosmosDbCollectionIncludedPathIndex` Kind parameter spelling
  of spacial - See [Issue #112](https://github.com/PlagueHO/CosmosDB/issues/112).
- Added parameter validation to `New-CosmosDbCollectionIncludedPathIndex`.

## What is New in CosmosDB 2.0.13.427

June 03, 2018

- Added `Set-CosmosDbCollection` function for updating a collection - See
  [Issue #104](https://github.com/PlagueHO/CosmosDB/issues/104).
- Updated `Invoke-CosmosDbRequest` function to output additional exception
  information to the Verbose stream - See [Issue #103](https://github.com/PlagueHO/CosmosDB/issues/103).

## What is New in CosmosDB 2.0.12.418

May 19, 2018

- Changed Id parameter in `Get-CosmosDbCollectionSize` to be mandatory.
- Added documentation for creating a resource token context - See
  [Issue #33](https://github.com/PlagueHO/CosmosDB/issues/33).
- Added `New-CosmosDbContextToken` to create a resource token context
  object that can be passed to `New-CosmosDbContext` to support working
  with resource level access controls - See
  [Issue #33](https://github.com/PlagueHO/CosmosDB/issues/33).
- Added support to `New-CosmosDbContext` for creating a context object
  with resource tokens from permissions - See
  [Issue #33](https://github.com/PlagueHO/CosmosDB/issues/33).

## What is New in CosmosDB 2.0.11.407

May 12, 2018

- Added PowerShell Core version support badge.
- Prevent integration tests from running if Azure connection
  environment variables are not set.
- Added Code of Conduct to project.
- Fixed error returned by `Get-CosmosDbDocument` when getting documents
  from a partitioned collection without specifying an Id or Query - See
  [Issue #97](https://github.com/PlagueHO/CosmosDB/issues/97).
  Thanks [jasonchester](https://github.com/jasonchester)

## What is New in CosmosDB 2.0.10.388

April 25, 2018

- Added basic integration test support.
- Fixed 401 error returned by `Set-CosmosDbOffer` when
  updating offer - See [Issue #85](https://github.com/PlagueHO/CosmosDB/issues/85).
  Thanks [dl8on](https://github.com/dl8on)

## What is New in CosmosDB 2.0.9.360

April 9, 2018

- Added `Get-CosmosCollectionSize` function to return
  data about size and object counts of collections -
  See [Issue #79](https://github.com/PlagueHO/CosmosDB/issues/79).
  Thanks [WatersJohn](https://github.com/WatersJohn).

## What is New in CosmosDB 2.0.8.350

April 5, 2018

- Fixed `New-CosmosDbAuthorizationToken` function to support
  generating authorization tokens for case sensitive resource
  names - See [Issue #76](https://github.com/PlagueHO/CosmosDB/issues/76).
  Thanks [MWL88](https://github.com/MWL88).

## What is New in CosmosDB 2.0.7.288

March 9, 2018

- Updated CI process to use PSDepend for dependencies.
- Updated CI process to use PSake for tasks.
- Changes AppVeyor.yml to call PSake tasks.

## What is New in CosmosDB 2.0.6.247

March 8, 2018

- Added `PSEdition_Desktop` tag to manifest.
- Added cmdlet help examples for utils.
- Converted help to MAML file CosmosDB-help.xml.
- Updated AppVeyor build to generate MAML help.
- Added more README.MD badges.

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
            '
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}









