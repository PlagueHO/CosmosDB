# Release Notes

## What is New in CosmosDB 3.5.2.487

March 14, 2020

- Update `BuildHelpers` to version 2.0.11.
- Update `Psake` to version 4.9.0.
- Update `Pester` to version 4.10.1.
- Update `PSScriptAnalyzer` to version 1.18.3.
- Change Azure Pipeline Linux build to test PowerShell Core 6.2.3-1.
- Change TravisCI Linux build to test PowerShell Core 6.2.3-1.
- Change TravisCI MacOS build to test PowerShell Core 6.2.3-1.
- Add PowerShell 7 test to Azure Pipeline - fixes [Issue #325](https://github.com/PlagueHO/CosmosDB/issues/325).
- Fix bug converting Secure String in PowerShell 7 on Linux - fixes [Issue #323](https://github.com/PlagueHO/CosmosDB/issues/323).
- Fix issue in Azure Pipeline in MacOS build job - fixes [Issue #326](https://github.com/PlagueHO/CosmosDB/issues/326).
- Remove TravisCI Pipeline - fixes [Issue #327](https://github.com/PlagueHO/CosmosDB/issues/327).

## What is New in CosmosDB 3.5.1.458

November 12, 2019

- Change `psakefile.ps1` to detect Azure Pipelines correctly.
- Updated `BuildHelpers` support module for CI pipelines to 2.0.10.
- Added PowerShell Gallery badge to `README.md`.
- Refactored `Invoke-CosmosDbRequest` and added
  `Get-CosmosDbAuthorizationHeadersFromContext` to split out function to pull
  token out of `Context` object. This was done to reduce the size of the
  `Invoke-CosmosDbRequest` function and to improve testability.
- Fix TravisCI MacOS build - fixes [Issue #313](https://github.com/PlagueHO/CosmosDB/issues/313).
- Created helper function `Format-CosmosDbDocumentPartitionKey` to
  format the partition key string passed to `x-ms-documentdb-partitionkey`
  in document functions.
- Add support for integer partition keys to functions
  `Get-CosmosDbDocument`, `New-CosmosDbDocument`, `Remove-CosmosDbDocument`
  and `Set-CosmosDbDocument`.

## What is New in CosmosDB 3.5.0.425

July 19, 2019

- Fix issue with integration test execution error in Azure DevOps
  when running against a pull request and the contributor has not
  set build environment variables for connecting to Azure - fixes [Issue #304](https://github.com/PlagueHO/CosmosDB/issues/304).
- Added `.markdownlint.json` to enable linting of markdown files.
- Added optional `ETag` parameter to `Set-CosmosDbDocument` to check if
  the document has been updated since last get.

## What is New in CosmosDB 3.4.0.410

June 29, 2019

- Added `OfferThroughput` parameter to `New-CosmosDbDatabase`
  function - fixes [Issue #110](https://github.com/PlagueHO/CosmosDB/issues/110).

## What is New in CosmosDB 3.3.0.404

June 22, 2019

- Moved CosmosDB namespace class definitions into C# project to be built
  into a .NET Standard 2.0 DLL that can be loaded instead of a CS file.
  This is to work around a problem with Azure Functions 2.0 where
  types can not be compiled in the runtime (see [this issue](https://github.com/Azure/azure-functions-powershell-worker/issues/220)) -
  fixes [Issue #290](https://github.com/PlagueHO/CosmosDB/issues/290).

## What is New in CosmosDB 3.2.4.375

May 30, 2019

- Update `requirements.psd1` to install modules `Az.Resources` 1.3.1 and
  `Az.Accounts` 1.5.1.
- Change `requirements.psd1` to specify `minimumversion` of `Az.Resources`
  and `Az.Accounts`.
- Enabled tests and removed the warning when executing the function
  `Get-CosmosDbAccountConnectionString` because the underlying REST API
  has been fixed and now functions correctly - fixes [Issue #291](https://github.com/PlagueHO/CosmosDB/issues/291).
- Added parameter `MasterKeyType` to function `Get-CosmosDbAccountConnectionString`
  to only return a specific connection string - fixes [Issue #291](https://github.com/PlagueHO/CosmosDB/issues/291).

## What is New in CosmosDB 3.2.3.358

April 5, 2019

- Fix incorrectly encoded strings being returned by `Get-CosmosDbDocument`
  when UTF-8 results are returned - fixes [Issues #282](https://github.com/PlagueHO/CosmosDB/issues/282).
- Rename `CosmosDb.psdepend.ps1` to `requirements.psd1` to be a more
  generic name.

## What is New in CosmosDB 3.2.2.348

March 19, 2019

- Added Azure Pipelines YAML definition for executing automated
  testing on a daily schedule - fixes [Issue #272](https://github.com/PlagueHO/CosmosDB/issues/272).
- Extend AppVeyor test automation to run on Windows Server 2012R2
  and Windows Server 2016.
- Update `cosmosdb.psdepend.psd1` to install modules `Az.Resources` 1.2.0 and
  `Az.Accounts` 1.4.0.
- Added 'Windows', 'Linux' and 'MacOS' tags to module manifest to
  improve searchability in PowerShell Gallery.

## What is New in CosmosDB 3.2.1.331

February 22, 2019

- Added support for `PartitionKey` in `*-CosmosDBAttachment`
  functions - fixes [Issue #274](https://github.com/PlagueHO/CosmosDB/issues/274).
- Update `cosmosdb.psdepend.psd1` to install modules `Az.Resources` 1.1.2 and
  `Az.Accounts` 1.3.0.
- Suppress verbose output when loading module during automated
  testing to reduce output.

## What is New in CosmosDB 3.2.0.320

February 6, 2019

- Convert module name to be a variable in PSake file to make it more
  easily portable between projects.
- Fix `Notes` display in Readme Markdown - fixes [Issue #269](https://github.com/PlagueHO/CosmosDB/issues/269).
- Update `cosmosdb.psdepend.psd1` to install modules `Az` 1.2.1 and
  `Pester` 4.7.0.
- Deprecate `Hash` index policy kind and throw exception when used
  in `New-CosmosDbCollectionIncludedPathIndex`. See [this page](https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-kind)
  for more information - fixes [Issue #271](https://github.com/PlagueHO/CosmosDB/issues/271).

## What is New in CosmosDB 3.1.0.289

December 26, 2018

- Updated manifest to include required modules `Az.Accounts` 1.0.0
  and `Az.Resources` 1.0.0.
- Updated manifest to include `CompatiblePSEditions` of 'Desktop' and
  'Core'.
- Updated minimum supported PowerShell version to 5.1.
- Updated `cosmosdb.depend.psd1` to ensure `Az` modules are installed
  when running 'Deploy' PSake task.
- Improve build task code to ensure Git tag is correctly set.

## What is New in CosmosDB 3.0.0.279

December 23, 2018

- BREAKING CHANGE: Converted to use `Az` PowerShell Module from
  `AzureRm` and `AzureRm.NetCore` PowerShell Module - fixes [Issue #190](https://github.com/PlagueHO/CosmosDB/issues/190).
- Renamed `build.ps1` to `psake.ps1` to indicate that it is used
  to execute `Psake` tasks.
- Add Codacy Code Quality badge to `README.MD`.
- Configure PSScriptAnalyzer to show errors, warnings and informational
  violations in Visual Studio Code.
- Fix generic tests to validate PSScriptAnalyzer errors, warnings and
  informational rules.
- Converted use of alias `Add-AzAccount` to `Connect-AzAccount`.
- Updated to use `Az` PowerShell Module 1.0.1.
- Correct `AliasesToExport` in manifest.
- Minor corrections to markdown to improve best practice adherence.
- Minor corrections to CI support files to improve best practice
  adherence.
- Added ShouldProcess support to `New-CosmosDbAccountMasterKey` and
  `New-CosmosDbContext`.
- Added ShouldProcess support TestHelper functions.
- Updated CONTRIBUTING.MD to more accurately reflect current process of
  contributing to the module.
- Updated STYLEGUIDELINES.MD to match current standards and best practices.
- Added support for setting and updating Cross-Origin Resource Sharing (CORS)
  allowed origins in `New-CosmosDbAccount` and `Set-CosmosDbAccount`
  respectively - fixes [Issue #249](https://github.com/PlagueHO/CosmosDB/issues/249).
- Changed `Remove-CosmosDbAccount` to prevent second confirmation prompt
  when removing account.
- Enabled `*-CosmosDbAccount` tests to run in AppVeyor.

## What is New in CosmosDB 2.1.15.237

November 17, 2018

- Added support for Continuation Tokens to `Get-CosmosDbCollection`
  to support getting more than 100 collections - fixes [Issue #244](https://github.com/PlagueHO/CosmosDB/issues/244).
- Updated markdown documentation with PlatyPs 0.11.1.
- Corrected markdown documentation for `Get-CosmosDbCollectionSize`.
- Corrected continuation token examples for `Get-CosmosDbDocument`.
- Updated CI pipeline to use Pester 4.4.2.
- Updated CI pipeline to use PlatyPS 0.12.
- Renamed `ResultHeaders` parameter to `ResponseHeader` in
  `Get-CosmosDbDocuments` function to adhere to PowerShell standards,
  but included alias for `ResultHeaders` to prevent breaking change.

## What is New in CosmosDB 2.1.14.220

November 15, 2018

- Extended maximum length of Account Name parameter to be 50 characters - fixes
  [Issue #201](https://github.com/PlagueHO/CosmosDB/issues/201).

## What is New in CosmosDB 2.1.13.214

November 4, 2018

- Added new integration tests for testing simple index policies.
- Split the multiple functions scripts into single functions and
  change the build pipeline to combine them all during
  staging - fixes [Issue #201](https://github.com/PlagueHO/CosmosDB/issues/201).
- Temporarily suppressed running tests using MacOS in Azure Pipelines
  because the Hosted Agent has been updated with Az, preventing the
  AzureRM.NetCore modules from being installed.
- Improved validation on Name and ResourceGroupName parameters on
  `*-CosmosDBAccount*` functions - fixes [Issue #211](https://github.com/PlagueHO/CosmosDB/issues/211).
- Improved validation on Account parameter on `*-CosmosDBDatabase*` functions.
- Improved validation on Account and ResourceGroupName parameter on
  `New-CosmosDbContext` function.
- Improved validation on Database Id parameter on
  `*-CosmosDBDatabase*` functions - fixes [Issue #212](https://github.com/PlagueHO/CosmosDB/issues/212).
- Improved validation on Collection Id parameter on
  `*-CosmosDBCollection*` functions - fixes [Issue #213](https://github.com/PlagueHO/CosmosDB/issues/213).
- Improved validation on Account parameter on `*-CosmosDBCollection*` functions.
- Improved validation on Database parameter on `*-CosmosDBCollection*` functions.
- Improved validation on Stored Procedure Id parameter on
  `*-CosmosDBStoredProcedure*` functions - fixes [Issue #214](https://github.com/PlagueHO/CosmosDB/issues/214).
- Improved validation on Account parameter on `*-CosmosDBStoredProcedure*` functions.
- Improved validation on Database parameter on `*-CosmosDBStoredProcedure*` functions.
- Improved validation on Collection parameter on `*-CosmosDBStoredProcedure*` functions.
- Improved validation on Trigger Id parameter on
  `*-CosmosDBTrigger*` functions - fixes [Issue #215](https://github.com/PlagueHO/CosmosDB/issues/215).
- Improved validation on Account parameter on `*-CosmosDBTrigger*` functions.
- Improved validation on Database parameter on `*-CosmosDBTrigger*` functions.
- Improved validation on Collection parameter on `*-CosmosDBTrigger*` functions.
- Improved validation on User Defined Function Id parameter on
  `*-CosmosDBUserDefinedFunction*` functions - fixes [Issue #216](https://github.com/PlagueHO/CosmosDB/issues/216).
- Improved validation on Account parameter on `*-CosmosDBUserDefinedFunction*` functions.
- Improved validation on Database parameter on `*-CosmosDBUserDefinedFunction*` functions.
- Improved validation on Collection parameter on `*-CosmosDBUserDefinedFunction*` functions.
- Improved validation on User Id parameter on
  `*-CosmosDBUser*` functions - fixes [Issue #217](https://github.com/PlagueHO/CosmosDB/issues/217).
- Improved validation on Account parameter on `*-CosmosDBUser*` functions.
- Improved validation on Database parameter on `*-CosmosDBUser*` functions.
- Improved validation on Document Id parameter on
  `*-CosmosDBDocument*` functions - fixes [Issue #227](https://github.com/PlagueHO/CosmosDB/issues/227).
- Improved validation on Account parameter on `*-CosmosDBDocument*` functions.
- Improved validation on Database parameter on `*-CosmosDBDocument*` functions.
- Improved validation on Collection parameter on `*-CosmosDBDocument*` functions.
- Improved validation on Permission Id parameter on
  `*-CosmosDBPermission*` functions - fixes [Issue #218](https://github.com/PlagueHO/CosmosDB/issues/218).
- Improved validation on Account parameter on `*-CosmosDBPermission*` functions.
- Improved validation on Database parameter on `*-CosmosDBPermission*` functions.
- Improved validation on User parameter on `*-CosmosDBPermission*` functions.
- Improved validation on Attachment Id parameter on
  `*-CosmosDBAttachment*` functions - fixes [Issue #228](https://github.com/PlagueHO/CosmosDB/issues/228).
- Improved validation on Account parameter on `*-CosmosDBAttachment*` functions.
- Improved validation on Database parameter on `*-CosmosDBAttachment*` functions.
- Improved validation on Collection parameter on `*-CosmosDBAttachment*` functions.
- Improved validation on Document parameter on `*-CosmosDBAttachment*` functions.
- Added tests to validate module manifest is valud - fixes [Issue #236](https://github.com/PlagueHO/CosmosDB/issues/236).

## What is New in CosmosDB 2.1.12.137

October 30, 2018

- Added support for setting Collection uniqueKeyPolicy in
  `New-CosmosDbCollection` and `Set-CosmosDbCollection` - fixes [Issue #197](https://github.com/PlagueHO/CosmosDB/issues/197).

## What is New in CosmosDB 2.1.11.130

October 27, 2018

- Renamed `ResourceGroup` parameter to `ResourceGroupName` in
  `New-CosmosDbContext` function - fixes [Issue #158](https://github.com/PlagueHO/CosmosDB/issues/158).
- Correct `*-CosmosDbAccount` functions examples in README.MD to show
  `ResourceGroupName` parameter.
- Added `Get-CosmosDbAccountMasterKey` function for retrieving the keys
  of an existing account in Azure - fixes [Issue #162](https://github.com/PlagueHO/CosmosDB/issues/162).
- Added `New-CosmosDbAccountMasterKey` function for regenerating the keys
  of an existing account in Azure - fixes [Issue #164](https://github.com/PlagueHO/CosmosDB/issues/164).

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
- Fixed 'Unable to find type \[Microsoft.PowerShell.Commands.HttpResponseException\]' exception
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
  leading '/' characters in the partition key - fixes [Issue #153](https://github.com/PlagueHO/CosmosDB/issues/153)
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

December 6, 2017

- Added support for managing Documents.

## What is New in CosmosDB 1.0.9

November 5, 2017

- Added support for managing User Defined Functions.

## What is New in CosmosDB 1.0.8

November 5, 2017

- Added support for managing Stored Procedures.

## What is New in CosmosDB 1.0.7

November 3, 2017

- Added support for managing Triggers.

## What is New in CosmosDB 1.0.6

November 1, 2017

- First release containing support for managing
  Databases, Collections, Users and Permissions.

## Feedback

Please send your feedback to [http://github.com/PlagueHO/CosmosDB/issues](http://github.com/PlagueHO/CosmosDB/issues).
