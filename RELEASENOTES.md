# Release Notes

## What is New in CosmosDB Unreleased

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
