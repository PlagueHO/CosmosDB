@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'CosmosDB.psm1'

    # Version number of this module.
    ModuleVersion     = '2.1.10.103'

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
        'Get-CosmosDbAccount'
        'Get-CosmosDbAccountConnectionString'
        'Get-CosmosDbAccountMasterKey'
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
        'New-CosmosDbAccount'
        'New-CosmosDbAccountMasterKey'
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
        'Remove-CosmosDbAccount'
        'Remove-CosmosDbAttachment'
        'Remove-CosmosDbCollection'
        'Remove-CosmosDbDatabase'
        'Remove-CosmosDbDocument'
        'Remove-CosmosDbPermission'
        'Remove-CosmosDbStoredProcedure'
        'Remove-CosmosDbTrigger'
        'Remove-CosmosDbUser'
        'Remove-CosmosDbUserDefinedFunction'
        'Set-CosmosDbAccount'
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
## What is New in CosmosDB 2.1.10.103

October 22, 2018

- Added support for creating and updating documents containing
    non-ASCII characters by adding Encoding parameter to `New-CosmosDbDocument`
    and `Set-CosmosDbDocument` functions - fixes [Issue #151](https://github.com/PlagueHO/CosmosDB/issues/151).
- Fix table of contents link in README.MD.

## What is New in CosmosDB 2.1.9.92

October 20, 2018

- Improved unit test reliability on MacOS and Linux.
- Improved unit tests for account functions to include parameter filters on mock assertions.
- Added `Get-CosmosDbAccountConnectionString` function for retrieving the connection strings
    of an existing account in Azure - fixes [Issue #163](https://github.com/PlagueHO/CosmosDB/issues/163).
    This function is not currently working due to an issue with the Microsoft\DocumentDB provider
    in Azure - see [this issue](https://github.com/Azure/azure-powershell/issues/3650) for more information.
- Fixed ''Unable to find type \[Microsoft.PowerShell.Commands.HttpResponseException\]'' exception
    being thrown in `Invoke-CosmosDbRequest` when error is returned by Cosmos DB in PowerShell 5.x
    or earlier - fixes [Issue #186](https://github.com/PlagueHO/CosmosDB/issues/186).
- Split unit and integration test execution in CI process so that integration tests do
    not run when unit tests fail - fixes [Issue #184](https://github.com/PlagueHO/CosmosDB/issues/184).

## What is New in CosmosDB 2.1.8.59

October 3, 2018

- Fixed RU display - fixes [Issue #168](https://github.com/PlagueHO/CosmosDB/issues/168)
- Fixed Powershell Core `Invoke-WebRequest` error handling.
- Fixed retry logic bug (`$fatal` initially set to `$true` instead of `$false`).
- Fixed stored procedure debug logging output.
- Rework CI process to simplify code.
- Enabled integration test execution in Azure DevOps Pipelines - fixes [Issue #179](https://github.com/PlagueHO/CosmosDB/issues/179)
- Added artifact publish tasks for Azure Pipeline.
- Refactored module deployment process to occur in Azure DevOps pipeline - fixes [Issue #181](https://github.com/PlagueHO/CosmosDB/issues/181)

## What is New in CosmosDB 2.1.7.675

September 11, 2018

- Added support for running CI in Azure DevOps Pipelines - fixes [Issue #174](https://github.com/PlagueHO/CosmosDB/issues/174)

## What is New in CosmosDB 2.1.7.635

September 3, 2018

- Added `New-CosmosDbAccount` function for creating a new Cosmos DB
  account in Azure - fixes [Issue #111](https://github.com/PlagueHO/CosmosDB/issues/111)
- Added `Get-CosmosDbAccount` function for retrieving the properties
  of an existing account in Azure - fixes [Issue #159](https://github.com/PlagueHO/CosmosDB/issues/159)
- Added `Set-CosmosDbAccount` function for updating an existing Cosmos DB
  account in Azure - fixes [Issue #160](https://github.com/PlagueHO/CosmosDB/issues/160)
- Added `Remove-CosmosDbAccount` function for removing an existing Cosmos DB
  account in Azure - fixes [Issue #161](https://github.com/PlagueHO/CosmosDB/issues/161)
- Added OSx and Linux PowerShell Core continuous integration using
  TravisCI.
- Improved CI/CodeCoverage badges in README.MD.
- Improved build process to handle build environments that do not
  have Administrator/Root access.
- Skip test for `Convert-CosmosDbRequestBody` when run in Linux/OSx using
  PowerShell Core due to behavior difference - see [PowerShell Core #Issue](https://github.com/PowerShell/PowerShell/issues/7693)

## What is New in CosmosDB 2.1.6.561

August 24, 2018

- Updated partition key handling when creating collections to allow for
  leading ''/'' characters in the partition key - fixes [Issue #153](https://github.com/PlagueHO/CosmosDB/issues/153)
- Add support for setting URI and Key when using with a Cosmos DB
  Emulator - fixes [Issue #155](https://github.com/PlagueHO/CosmosDB/issues/155)

  ## What is New in CosmosDB 2.1.5.548

August 4, 2018

- Changed references to `CosmosDB` to `Cosmos DB` in documentation - fixes [Issue #147](https://github.com/PlagueHO/CosmosDB/issues/147)

## What is New in CosmosDB 2.1.4.536

July 25, 2018

- Added `RemoveDefaultTimeToLive` switch parameter to `Set-CosmosDbCollection`
  to allow removal of a default time to live setting on a collection - fixes [Issue #144](https://github.com/PlagueHO/CosmosDB/issues/144)

## What is New in CosmosDB 2.1.3.528

July 12, 2018

- Changed `New-CosmosDbStoredProcedure` & `Set-CosmosDbStoredProcedure` to use serialization
  instead of tricky request body conversion - fixes
  [Issue #137](https://github.com/PlagueHO/CosmosDB/issues/137)
- Added parameter `DefaultTimeToLive` to `New-CosmosDbCollection` and
  `Set-CosmosDbCollection` - fixes [Issue #139](https://github.com/PlagueHO/CosmosDB/issues/139)
- Changed the `IndexingPolicy` parameter on`Set-CosmosDbCollection`
  to be optional - fixes [Issue #140](https://github.com/PlagueHO/CosmosDB/issues/140)

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
            '
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}









