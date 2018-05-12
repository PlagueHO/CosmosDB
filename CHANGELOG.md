# Change Log

## Unreleased

- Added PowerShell Core version support badge.
- Prevent integration tests from running if Azure connection
  environment variables are not set.
- Added Code of Conduct to project.
- Fixed error returned by `Get-CosmosDbDocument` when getting documents
  from a partitioned collection without specifying an Id or Query - See
  [Issue #97](https://github.com/PlagueHO/CosmosDB/issues/97).
  Thanks [jasonchester](https://github.com/jasonchester)

## 2.0.10.388

- Added basic integration test support.
- Fixed 401 error returned by `Set-CosmosDbOffer` when
  updating offer - See [Issue #85](https://github.com/PlagueHO/CosmosDB/issues/85).
  Thanks [dl8on](https://github.com/dl8on)

## 2.0.9.360

- Added `Get-CosmosDbCollectionSize` function to return
  data about size and object counts of collections -
  See [Issue #79](https://github.com/PlagueHO/CosmosDB/issues/79).
  Thanks [WatersJohn](https://github.com/WatersJohn).

## 2.0.8.350

- Fixed `New-CosmosDbAuthorizationToken` function to support
  generating authorization tokens for case sensitive resource
  names - See [Issue #76](https://github.com/PlagueHO/CosmosDB/issues/76).
  Thanks [MWL88](https://github.com/MWL88).

## 2.0.7.288

- Updated CI process to use PSDepend for dependencies.
- Updated CI process to use PSake for tasks.
- Changes AppVeyor.yml to call PSake tasks.

## 2.0.6.247

- Added `PSEdition_Desktop` tag to manifest.
- Added cmdlet help examples for utils.
- Converted help to MAML file CosmosDB-help.xml.
- Updated AppVeyor build to generate MAML help.
- Added more README.MD badges.

## 2.0.5.216

- Added `*-CosmosDbOffer` cmdlets.

## 2.0.4.202

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

## 2.0.3.190

- Added support for configuring custom indexing policies when
  creating a new collection.

## 2.0.2.184

- Converted all `connection` function names and parameter names
  over to `context`. Aliases were implemented for old `connection`
  function and parameter names to reduce possibility of breakage.

## 2.0.1.173

- Added support for CosmosDB Emulator.

## 2.0.0.163

- Fixed `New-CosmosDbConnection` error message when
  creating connection but not connected to Azure.
- Added support for specifying token expiry length to
  `Get-cosmosDbPermission`.

## 2.0.0.146

- BREAKING CHANGE: Converted all cmdlets to return custom types
  and added support for custom formats.

## 1.0.12.126

- Added `*-CosmosDbAttachment` cmdlets.

## 1.0.11.117

- Fixed `Get-CosmosDbDocument` returning (400) Bad Request error
  when executed with Query - See [Issue #22](https://github.com/PlagueHO/CosmosDB/issues/22).

## 1.0.10.108

- Added `*-CosmosDbDocument` cmdlets.

## 1.0.9.100

- Added `*-CosmosDbUserDefinedFunction` cmdlets.

## 1.0.8.91

- Added `*-CosmosDbStoredProcedure` cmdlets.

## 1.0.7.85

- Added `*-CosmosDbTrigger` cmdlets.

## 1.0.6.79

- Added `New-CosmosDbDatabase` and `Remove-CosmosDbDatabase` cmdlets.
- Improved unit tests.

## 1.0.5.73

- Added `Get-CosmosDbDatabase` and `Get-CosmosDbDatabaseResourcePath`
  cmdlets.

## 1.0.4.67

- Fixed bug in `New-CosmosDbConnection` detecting Azure connection.

## 1.0.4.63

- Fixed bug in `New-CosmosDbConnection` connecting to Azure and
  improved tests.
- Changed `New-CosmosDbAuthorizationToken` to replaced `Connection`
  parameter with `Key` and `KeyType` parameter.
- Fixed bug in `Invoke-CosmosDbRequest` that can cause connection
  object to be changed.

## 1.0.2.59

- Added `PartitionKey`, `OfferThroughput` and `OfferType` parameters to
  cmdlet `New-CosmosDBCollection`.
- Added support for retrieving key from Azure Management Portal.

## 1.0.2.53

- Updated manifest to show all cmdlets.

## 1.0.2.47

- Improved unit test coverage.
- Added cmdlet `Set-CosmosDBUser` for setting the user Id of an
  existing user.

## 1.0.1.40

- Minor bugfixes.
- Improved unit test coverage.

## 1.0.0.30

- Initial Release.









