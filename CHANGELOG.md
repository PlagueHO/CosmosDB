# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fixed spelling errors in documentation.

## [4.6.0] - 2022-08-07

### Fixed

- Fix Azure DevOps build pipeline and update to latest sampler pattern.
- Fix exception being thrown when a 429 is returned by CosmosDB, but the
  `x-ms-retry-after-ms` header is not returned. This may occur in requests
  that follow large (> 1MB) insert or updates - Fixes [Issue #458](https://github.com/PlagueHO/CosmosDB/issues/458).

### Changed

- Update Azure DevOps pipeline Linux agent version for build task
  to be `ubuntu-latest` - Fixes [Issue #422](https://github.com/PlagueHO/CosmosDB/issues/422).
- Updated PSScriptAnalyzer tests to be skipped when PowerShell Core
  version is less than 7.0.3 - Fixes [Issue #431](https://github.com/PlagueHO/CosmosDB/issues/431).
- Updated the New-CosmosDbAccount command to add a new Capability
  parameter - Fixes [Issue #439](https://github.com/PlagueHO/CosmosDB/issues/439).
- Updated tests on PowerShell 6.x for MacOS 10.14 to 10.15 - Fixes [Issue #450](https://github.com/PlagueHO/CosmosDB/issues/450).
- Updated README.md to remove markdown issues.

### Added

- Added tests on PowerShell 7.x on Ubuntu 20.04 - Fixes [Issue #433](https://github.com/PlagueHO/CosmosDB/issues/433).
- Added tests on Windows PowerShell 5.1 on Windows Server 2022 - Fixes [Issue #436](https://github.com/PlagueHO/CosmosDB/issues/436).
- Added tests on PowerShell 6.x on MacOS 11 - Fixes [Issue #450](https://github.com/PlagueHO/CosmosDB/issues/450).

### Removed

- Removed tests against PowerShell Core 6.x as PowerShell 7.x is recommended - Fixes
  [Issue #434](https://github.com/PlagueHO/CosmosDB/issues/431).
- Removed all tests on Ubuntu 16.04 - Fixes [Issue #433](https://github.com/PlagueHO/CosmosDB/issues/433).
- Removed tests against Windows PowerShell 5.1 on Windows Server 2016 - Fixes
  [Issue #451](https://github.com/PlagueHO/CosmosDB/issues/451).

## [4.5.0] - 2021-05-29

### Changed

- Convert build pipeline to use GitTools Azure DevOps extension tasks
  instead of deprecated GitVersion extension.
- Correct value of `Environment` parameter in context object returned
  by `New-CosmosDbContext` - Fixes [Issue #411](https://github.com/PlagueHO/CosmosDB/issues/411).
- Update `requirements.psd1` to install modules `Az.Accounts`
  2.2.8 - Fixes [Issue #415](https://github.com/PlagueHO/CosmosDB/issues/415).
- Updated `ComsosDB.cs` to add getters and setters to properties - Fixes [Issue #417](https://github.com/PlagueHO/CosmosDB/issues/417).

### Fixed

- Fix CI pipeline deployment stage to ensure correctly detects running
  in Azure DevOps organization.
- Fix CI pipeline release stage by adding Sampler GitHub tasks which
  were moved out of the main sampler module into a new module
  `Sampler.GitHubTasks` - Fixes [Issue #418](https://github.com/PlagueHO/CosmosDB/issues/418).

### Added

- Added `ReturnJson` parameter to `New-CosmosDbDocument`, `Set-CosmosDbDocument`
  and `Get-CosmosDbDocument` functions to allow return of documents that can
  not be converted to objects due to duplicate key names that only differ in
  case - Fixes [Issue #413](https://github.com/PlagueHO/CosmosDB/issues/413).

## [4.4.3] - 2020-11-13

### Fixed

- Fix build problems preventing DLL and help from being compiled and added
  to the module.

## [4.4.2] - 2020-11-11

### Fixed

- Fix build problems preventing DLL and help from being compiled and added
  to the module.

### Changed

- Attachments are now a legacy feature and not supported when creating a
  new account. Remove integration tests for this feature. Add a warning
  when this feature is used.

## [4.4.1] - 2020-10-27

### Fixed

- Fix missing module help - Fixes [Issue #401](https://github.com/PlagueHO/CosmosDB/issues/401).

## [4.4.0] - 2020-08-30

### Fixed

- Fixed misspelling of 'Throughput' in `README.md` and tests - Fixes [Issue #396](https://github.com/PlagueHO/CosmosDB/issues/396).

### Changed

- Renamed `master` branch to `main` - Fixes [Issue #393](https://github.com/PlagueHO/CosmosDB/issues/393).

### Added

- Added support for specifying custom endpoint in `New-CosmosDbContext` to
  support alternative clouds - Fixes [Issue #395](https://github.com/PlagueHO/CosmosDB/issues/395).
- Added support for autoscaling throughput on database and collection in
  `New-CosmosDbDatabase` and `New-CosmosDbCollection` - Fixes [Issue #321](https://github.com/PlagueHO/CosmosDB/issues/321).

## [4.2.1] - 2020-06-15

### Fixed

- Fixed `Cannot bind argument to parameter 'Message' because it is null.` error
  message occurring when displaying messages on systems not using `en-US`
  UI culture - Fixes [Issue #373](https://github.com/PlagueHO/CosmosDB/issues/373).

## [4.2.0] - 2020-06-01

### Added

- Added `Get-CosmosDbDocumentJson` function - Fixes [Issue #370](https://github.com/PlagueHO/CosmosDB/issues/370).
- Added `IfMatch` alias for `Etag` parameter on `Set-CosmosDbDocument`
  function - Fixes [Issue #376](https://github.com/PlagueHO/CosmosDB/issues/376).
- Added `Get-CosmosDbCosmosDbResponseHeader` function and refactored
  `Get-CmosmosDbContinuationToken` to use it.
- Added documentation and examples showing how to get the progress of an
  index transformation - Fixes [Issue #369](https://github.com/PlagueHO/CosmosDB/issues/369).

### Changed

- Changed build jobs `Unit_Test_PSCore6_Ubuntu1604` and
  `Integration_Test_PSCore6_Ubuntu1604` to install PowerShell Core 6.2.4
  to support version of Az PowerShell modules that are installed - Fixes [Issue #371](https://github.com/PlagueHO/CosmosDB/issues/371).
- Pinned build to Pester v4.10.1 - Fixes [Issue #371](https://github.com/PlagueHO/CosmosDB/issues/378).
- Added `Name` as an alias for `Id` parameters in
  `*-CosmosDbCollection` functions - Fixes [Issue #375](https://github.com/PlagueHO/CosmosDB/issues/375).
- Added `Name` as an alias for `Id` parameters in
  `*-CosmosDbDatabase` functions - Fixes [Issue #374](https://github.com/PlagueHO/CosmosDB/issues/374).
- Refactored `Get-CosmosDbDocument` to be a wrapper for
  new function `Get-CosmosDbDocumentJson`.
- Added support for specifying a protocol and port in the `URI` parameter
  of the `New-CosmosDbContext` function - Fixes [Issue #381](https://github.com/PlagueHO/CosmosDB/issues/381).

### Fixed

- Fixed `Get-CosmosDbDocument` function partition key formatting
  when an `Id` parameter is passed.

## [4.1.0] - 2020-05-15

### Added

- Added support for AzureChinaCloud (Mooncake) - Fixes [Issue #365](https://github.com/PlagueHO/CosmosDB/issues/365).

### Changed

- Fix daily build by preventing deployment stage from running on
  anything build not named `*.master` - Fixes [Issue #366](https://github.com/PlagueHO/CosmosDB/issues/366).

## [4.0.0] - 2020-05-11

### Changed

- Change Azure DevOps Pipeline definition to include `source/*` - Fixes [Issue #350](https://github.com/PlagueHO/CosmosDB/issues/350).
- Updated pipeline to use `latest` version of `ModuleBuilder` - Fixes [Issue #350](https://github.com/PlagueHO/CosmosDB/issues/350).
- Merge `HISTORIC_CHANGELOG.md` into `CHANGELOG.md` - Fixes [Issue #351](https://github.com/PlagueHO/CosmosDB/issues/351).
- Added integration tests for executing document queries - Fixes [Issue #356](https://github.com/PlagueHO/CosmosDB/issues/356).
- Added support for composite indexes in indexing policy - Fixes [Issue #357](https://github.com/PlagueHO/CosmosDB/issues/357).
- BREAKING CHANGE: Updated module to default to Cosmos DB REST
  API version `2018-09-17`. This results in a change to the default
  indexes when custom index paths are not specified. Other changes
  in behavior of indexing policy are also expected. See
  [this page](https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes)
  for more information.
- Added `IndexingPolicyJson` parameter to `New-CosmosDbCollection`
  and `Set-CosmosDbCollection` functions to enable setting an index policy
  using JSON - Fixes [Issue #360](https://github.com/PlagueHO/CosmosDB/issues/360).
- Fixed build pipeline deployment skip function.
- Changed Build.yml to support `ModuleBuilder` version to `1.7.0` by changing
  `CopyDirectories` to `CopyPaths`.
- Added `Get-CosmosDbContinuationToken` helper function to get the continuation
  token from response headers returned by `Get-CosmosDbCollection` or
  `Get-CosmosDbDocument` - Fixes [Issue #355](https://github.com/PlagueHO/CosmosDB/issues/355).
- Added example to `README.md` showing how to loop through a document set
  to return more than 4MB of documents - Fixes [Issue #354](https://github.com/PlagueHO/CosmosDB/issues/354).

## [3.7.0] - 2020-03-24

### Changed

- Add warning to `New-CosmosDbCollection` to show when creating a collection
  without a partition key.
- Updated `README.MD` to documentation to reduce focus on collections without
  partition keys - fixes [Issue #342](https://github.com/PlagueHO/CosmosDB/issues/342).

### Added

- Added support for `Environment` parameter in `New-CosmosDbContext` to allow
  using Azure US Government Cloud - fixes [Issue #322](https://github.com/PlagueHO/CosmosDB/issues/322).

## [3.6.1] - 2020-03-19

### Changed

- Improved badge layout in README.MD and removed CodeCov.io badge - fixes [Issue #336](https://github.com/PlagueHO/CosmosDB/issues/336).
- Removed references to Gitter and Gitter badge - fixes [Issue #337](https://github.com/PlagueHO/CosmosDB/issues/337).
- Removed Azure Pipeline daily build YAML because the main
  pipeline build YAML will be used instead.
- Fix build badges in README.MD by correcting BuildID - [Issue #340](https://github.com/PlagueHO/CosmosDB/issues/340).

### Removed

- Remove AppVeyor CI pipeline - fixes [Issue #329](https://github.com/PlagueHO/CosmosDB/issues/329).

### Changed

- Restructure Azure Pipeline:
  - Add testing on Windows Server 2019 and separate module build process.
  - Convert to multi stage pipeline.

### Fixed

- Fix default culture case to fix error on module load in PS7
  on Ubuntu 18.04 - fixes [Issue #332](https://github.com/PlagueHO/CosmosDB/issues/332).

## [3.5.2.487] - 2020-03-14

### Changed

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

## [3.5.1.458] - 2019-11-12

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

## [3.5.0.426] - 2019-07-20

- Fix issue with integration test execution error in Azure DevOps
  when running against a pull request and the contributor has not
  set build environment variables for connecting to Azure - fixes [Issue #304](https://github.com/PlagueHO/CosmosDB/issues/304).
- Added `.markdownlint.json` to enable linting of markdown files.
- Added optional `ETag` parameter to `Set-CosmosDbDocument` to check if
  the document has been updated since last get.

## [3.4.0.411] - 2019-06-29

- Added `OfferThroughput` parameter to `New-CosmosDbDatabase`
  function - fixes [Issue #110](https://github.com/PlagueHO/CosmosDB/issues/110).

## [3.3.0.405] - 2019-06-22

- Moved CosmosDB namespace class definitions into C# project to be built
  into a .NET Standard 2.0 DLL that can be loaded instead of a CS file.
  This is to work around a problem with Azure Functions 2.0 where
  types can not be compiled in the runtime (see [this issue](https://github.com/Azure/azure-functions-powershell-worker/issues/220)) -
  fixes [Issue #290](https://github.com/PlagueHO/CosmosDB/issues/290).

## [3.2.4.376] - 2019-05-30

- Update `requirements.psd1` to install modules `Az.Resources` 1.3.1 and
  `Az.Accounts` 1.5.1.
- Change `requirements.psd1` to specify `minimumversion` of `Az.Resources`
  and `Az.Accounts`.
- Enabled tests and removed the warning when executing the function
  `Get-CosmosDbAccountConnectionString` because the underlying REST API
  has been fixed and now functions correctly - fixes [Issue #291](https://github.com/PlagueHO/CosmosDB/issues/291).
- Added parameter `MasterKeyType` to function `Get-CosmosDbAccountConnectionString`
  to only return a specific connection string - fixes [Issue #291](https://github.com/PlagueHO/CosmosDB/issues/291).
- Updated Style Guidelines.

## [3.2.3.359] - 2019-04-05

- Fix incorrectly encoded strings being returned by `Get-CosmosDbDocument`
  when UTF-8 results are returned - fixes [Issue #282](https://github.com/PlagueHO/CosmosDB/issues/282).

## [3.2.2.347] - 2019-03-20

- Added Azure Pipelines YAML definition for executing automated
  testing on a daily schedule - fixes [Issue #272](https://github.com/PlagueHO/CosmosDB/issues/272).
- Extend AppVeyor test automation to run on Windows Server 2012R2
  and Windows Server 2016.
- Update `cosmosdb.psdepend.psd1` to install modules `Az.Resources` 1.2.0 and
  `Az.Accounts` 1.4.0.
- Added 'Windows', 'Linux' and 'MacOS' tags to module manifest to
  improve searchability in PowerShell Gallery.

## [3.2.1.332] - 2019-02-22

- Added support for `PartitionKey` in `*-CosmosDBAttachment`
  functions - fixes [Issue #274](https://github.com/PlagueHO/CosmosDB/issues/274).
- Update `cosmosdb.psdepend.psd1` to install modules `Az.Resources` 1.1.2 and
  `Az.Accounts` 1.3.0.
- Suppress verbose output when loading module during automated
  testing to reduce output.

## [3.2.0.320] - 2019-02-07

- Convert module name to be a variable in PSake file to make it more
  easily portable between projects.
- Fix `Notes` display in Readme Markdown - fixes [Issue #269](https://github.com/PlagueHO/CosmosDB/issues/269).
- Update `cosmosdb.psdepend.psd1` to install modules `Az` 1.2.1 and
  `Pester` 4.7.0.
- Deprecate `Hash` index policy kind and throw exception when used
  in `New-CosmosDbCollectionIncludedPathIndex`. See [this page](https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-kind)
  for more information - fixes [Issue #271](https://github.com/PlagueHO/CosmosDB/issues/271).

## [3.1.0.293] - 2018-12-26

- Updated manifest to include required modules `Az.Accounts` 1.0.0
  and `Az.Resources` 1.0.0.
- Updated manifest to include `CompatiblePSEditions` of 'Desktop' and
  'Core'.
- Updated minimum supported PowerShell version to 5.1.
- Updated `cosmosdb.depend.psd1` to ensure `Az` modules are installed
  when running 'Deploy' PSake task.
- Improve build task code to ensure Git tag is correctly set.
- Fix bug in module manifest generation process to ensure module version
  is set correctly.
- Refactored module manifest generation process to be more reliable
  and robust.

## [3.0.0.279] - 2018-12-23

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

## [2.1.15.239] - 2018-11-18

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

## [2.1.14.222] - 2018-11-15

- Extended maximum length of Account Name parameter to be 50 characters - fixes
  [Issue #201](https://github.com/PlagueHO/CosmosDB/issues/201).

## [2.1.13.215] - 2018-11-06

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

## [2.1.12.137] - 2018-10-29

- Added support for setting Collection uniqueKeyPolicy in
  `New-CosmosDbCollection` and `Set-CosmosDbCollection` - fixes [Issue #197](https://github.com/PlagueHO/CosmosDB/issues/197).

## [2.1.11.130] - 2018-10-27

- Renamed `ResourceGroup` parameter to `ResourceGroupName` in
  `New-CosmosDbContext` function - fixes [Issue #158](https://github.com/PlagueHO/CosmosDB/issues/158).
- Correct `*-CosmosDbAccount` functions examples in README.MD to show
  `ResourceGroupName` parameter.
- Added `Get-CosmosDbAccountMasterKey` function for retrieving the keys
  of an existing account in Azure - fixes [Issue #162](https://github.com/PlagueHO/CosmosDB/issues/162).
- Added `New-CosmosDbAccountMasterKey` function for regenerating the keys
  of an existing account in Azure - fixes [Issue #164](https://github.com/PlagueHO/CosmosDB/issues/164).

## [2.1.10.103] - 2018-10-22

- Added support for creating and updating documents containing
  non-ASCII characters by adding Encoding parameter to `New-CosmosDbDocument`
  and `Set-CosmosDbDocument` functions - fixes [Issue #151](https://github.com/PlagueHO/CosmosDB/issues/151).
- Fix table of contents link in README.MD.

## [2.1.9.95] - 2018-10-21

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

## [2.1.8.59] - 2018-10-03

- Fixed RU display - fixes [Issue #168](https://github.com/PlagueHO/CosmosDB/issues/168)
- Fixed Powershell Core `Invoke-WebRequest` error handling.
- Fixed retry logic bug (`$fatal` initially set to `$true` instead of `$false`).
- Fixed stored procedure debug logging output.
- Rework CI process to simplify code.
- Enabled integration test execution in Azure DevOps Pipelines - fixes [Issue #179](https://github.com/PlagueHO/CosmosDB/issues/179)
- Added artifact publish tasks for Azure Pipeline.
- Refactored module deployment process to occur in Azure DevOps pipeline - fixes [Issue #181](https://github.com/PlagueHO/CosmosDB/issues/181)

## [2.1.7.675] - 2018-09-11

- Added support for running CI in Azure DevOps Pipelines - fixes [Issue #174](https://github.com/PlagueHO/CosmosDB/issues/174)

## [2.1.7.635] - 2018-09-10

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
- Skip integration tests for `New-CosmosDbAccount` and `Set-CosmosDbAccount`
  when run in AppVeyor due to exception occuring in `New-AzureRmResource` and
  `Set-AzureRmResource` cmdlets because of Newtonsoft.Json version conflict.

## [2.1.6.561] - 2018-08-24

- Updated partition key handling when creating collections to allow for
  leading '/' characters in the partition key - fixes [Issue #153](https://github.com/PlagueHO/CosmosDB/issues/153)
- Add support for setting URI and Key when using with a Cosmos DB
  Emulator - fixes [Issue #155](https://github.com/PlagueHO/CosmosDB/issues/155)

## [2.1.5.548] - 2018-08-04

- Changed references to `CosmosDB` to `Cosmos DB` in documentation - fixes [Issue #147](https://github.com/PlagueHO/CosmosDB/issues/147)

## [2.1.4.536] - 2018-07-25

- Added `RemoveDefaultTimeToLive` switch parameter to `Set-CosmosDbCollection`
  to allow removal of a default time to live setting on a collection - fixes [Issue #144](https://github.com/PlagueHO/CosmosDB/issues/144)

## [2.1.3.528] - 2018-07-12

- Changed `New-CosmosDbStoredProcedure` & `Set-CosmosDbStoredProcedure` to use serialization
  instead of tricky request body conversion - fixes
  [Issue #137](https://github.com/PlagueHO/CosmosDB/issues/137)
- Added parameter `DefaultTimeToLive` to `New-CosmosDbCollection` and
  `Set-CosmosDbCollection` - fixes [Issue #139](https://github.com/PlagueHO/CosmosDB/issues/139)
- Changed the `IndexingPolicy` parameter on`Set-CosmosDbCollection`
  to be optional - fixes [Issue #140](https://github.com/PlagueHO/CosmosDB/issues/140)

## [2.1.2.514] - 2018-07-03

- Changed `New-CosmosDBContext` so that Read Only keys will use the
  `readonlykeys` action endpoint instead of the `listKeys` action - fixes
  [Issue #133](https://github.com/PlagueHO/CosmosDB/issues/133)
- Fixed freeze occuring in functions when `-ErrorAction SilentlyContinue`
  parameter was used and error is returned - fixes [Issue #132](https://github.com/PlagueHO/CosmosDB/issues/132)

## [2.1.1.498] - 2018-06-26

- Changed trigger operation type `Insert` to `Create` in `New-CosmosDBTrigger`
  and `Set-CosmosDBTrigger` functions - fixes [Issue #129](https://github.com/PlagueHO/CosmosDB/issues/129)

## [2.1.0.487] - 2018-06-24

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

## [2.0.16.465] - 2018-06-20

- Added None as an IndexingMode - See [Issue #120](https://github.com/PlagueHO/CosmosDB/issues/120)

## [2.0.15.454] - 2018-06-15

- Fix creation of spatial index by `New-CosmosDbCollectionIncludedPathIndex`
  so that precision is not used when passing to `New-CosmosDbCollection`.
- Added support for `-PartitionKey` in `Invoke-CosmosDbStoredProcedure` - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)
- Changed -StoredProcedureParameter from string[] to object[] in `Invoke-CosmosDbStoredProcedure` - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)
- Updated `Invoke-CosmosDbStoredProcedure` to set `x-ms-documentdb-script-enable-logging: true` header and write stored procedure logs to the Verbose Stream when `-Debug` is set - See [Issue #116](https://github.com/PlagueHO/CosmosDB/issues/116)

## [2.0.14.439] - 2018-06-12

- Fixed Code Coverage upload to CodeCov.io.
- Fix `New-CosmosDbCollectionIncludedPathIndex` Kind parameter spelling
  of spacial - See [Issue #112](https://github.com/PlagueHO/CosmosDB/issues/112).
- Added parameter validation to `New-CosmosDbCollectionIncludedPathIndex`.

## [2.0.13.427] - 2018-06-03

- Added `Set-CosmosDbCollection` function for updating a collection - See
  [Issue #104](https://github.com/PlagueHO/CosmosDB/issues/104).
- Updated `Invoke-CosmosDbRequest` function to output additional exception
  information to the Verbose stream - See [Issue #103](https://github.com/PlagueHO/CosmosDB/issues/103).

## [2.0.12.418] - 2018-05-20

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

## [2.0.11.407] - 2018-05-12

- Added PowerShell Core version support badge.
- Prevent integration tests from running if Azure connection
  environment variables are not set.
- Added Code of Conduct to project.
- Fixed error returned by `Get-CosmosDbDocument` when getting documents
  from a partitioned collection without specifying an Id or Query - See
  [Issue #97](https://github.com/PlagueHO/CosmosDB/issues/97).
  Thanks [jasonchester](https://github.com/jasonchester)

## [2.0.10.388] - 2018-04-26

- Added basic integration test support.
- Fixed 401 error returned by `Set-CosmosDbOffer` when
  updating offer - See [Issue #85](https://github.com/PlagueHO/CosmosDB/issues/85).
  Thanks [dl8on](https://github.com/dl8on)

## [2.0.9.360] - 2018-04-09

- Added `Get-CosmosDbCollectionSize` function to return
  data about size and object counts of collections -
  See [Issue #79](https://github.com/PlagueHO/CosmosDB/issues/79).
  Thanks [WatersJohn](https://github.com/WatersJohn).

## [2.0.8.350] - 2018-04-05

- Fixed `New-CosmosDbAuthorizationToken` function to support
  generating authorization tokens for case sensitive resource
  names - See [Issue #76](https://github.com/PlagueHO/CosmosDB/issues/76).
  Thanks [MWL88](https://github.com/MWL88).

## [2.0.7.288] - 2018-03-11

- Updated CI process to use PSDepend for dependencies.
- Updated CI process to use PSake for tasks.
- Changes AppVeyor.yml to call PSake tasks.

## [2.0.6.247] - 2018-03-09

- Added `PSEdition_Desktop` tag to manifest.
- Added cmdlet help examples for utils.
- Converted help to MAML file CosmosDB-help.xml.
- Updated AppVeyor build to generate MAML help.
- Added more README.MD badges.

## [2.0.5.216] - 2018-03-05

- Added `*-CosmosDbOffer` cmdlets.

## [2.0.4.202] - 2018-02-27

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

## [2.0.3.190] - 2018-02-24

- Added support for configuring custom indexing policies when
  creating a new collection.

## [2.0.2.184] - 2018-02-24

- Converted all `connection` function names and parameter names
  over to `context`. Aliases were implemented for old `connection`
  function and parameter names to reduce possibility of breakage.

## [2.0.1.173] - 2018-01-27

- Added support for CosmosDB Emulator.

## [2.0.0.163] - 2018-01-14

- Fixed `New-CosmosDbConnection` error message when
  creating connection but not connected to Azure.
- Added support for specifying token expiry length to
  `Get-cosmosDbPermission`.

## [2.0.0.152] - 2017-12-23

- BREAKING CHANGE: Converted all cmdlets to return custom types
  and added support for custom formats.

## [1.0.12.126] - 2017-12-08

- Added `*-CosmosDbAttachment` cmdlets.

## [1.0.11.117] - 2017-12-08

- Fixed `Get-CosmosDbDocument` returning (400) Bad Request error
  when executed with Query - See [Issue #22](https://github.com/PlagueHO/CosmosDB/issues/22).

## [1.0.10.108] - 2017-12-06

- Added `*-CosmosDbDocument` cmdlets.

## [1.0.9.100] - 2017-11-05

- Added `*-CosmosDbUserDefinedFunction` cmdlets.

## [1.0.8.91] - 2017-11-05

- Added `*-CosmosDbStoredProcedure` cmdlets.

## [1.0.7.85] - 2017-11-03

- Added `*-CosmosDbTrigger` cmdlets.

## [1.0.6.79] - 2017-11-02

- Added `New-CosmosDbDatabase` and `Remove-CosmosDbDatabase` cmdlets.
- Improved unit tests.

## [1.0.5.73] - 2017-01-01

- Added `Get-CosmosDbDatabase` and `Get-CosmosDbDatabaseResourcePath`
  cmdlets.

## [1.0.4.67] - 2017-01-01

- Fixed bug in `New-CosmosDbConnection` detecting Azure connection.

## [1.0.4.63] - 2017-01-01

- Fixed bug in `New-CosmosDbConnection` connecting to Azure and
  improved tests.
- Changed `New-CosmosDbAuthorizationToken` to replaced `Connection`
  parameter with `Key` and `KeyType` parameter.
- Fixed bug in `Invoke-CosmosDbRequest` that can cause connection
  object to be changed.

## [1.0.2.59] - 2017-01-01

- Added `PartitionKey`, `OfferThroughput` and `OfferType` parameters to
  cmdlet `New-CosmosDBCollection`.
- Added support for retrieving key from Azure Management Portal.

## [1.0.2.53] - 2017-01-01

- Updated manifest to show all cmdlets.

## [1.0.2.47] - 2017-01-01

- Improved unit test coverage.
- Added cmdlet `Set-CosmosDBUser` for setting the user Id of an
  existing user.

## [1.0.1.40] - 2017-01-01

- Minor bugfixes.
- Improved unit test coverage.

## [1.0.0.30] - 2017-01-01

- Initial Release.
