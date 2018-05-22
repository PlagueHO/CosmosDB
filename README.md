[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/PlagueHO/CosmosDB/blob/dev/LICENSE)
[![Documentation - CosmosDB](https://img.shields.io/badge/Documentation-CosmosDB-blue.svg)](https://github.com/PlagueHO/CosmosDB/wiki)
[![PowerShell Gallery - CosmosDB](https://img.shields.io/badge/PowerShell%20Gallery-CosmosDB-blue.svg)](https://www.powershellgallery.com/packages/CosmosDB)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-4.0-blue.svg)](https://github.com/PlagueHO/CosmosDB)
[![Minimum Supported PowerShell Core Version](https://img.shields.io/badge/PowerShell_Core-6.0-blue.svg)](https://github.com/PlagueHO/CosmosDB)

# CosmosDB PowerShell Module

## Module Build Status

| Branch | Build Status | Code Coverage |
| --- | --- | --- |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/dev?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/dev) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev) |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/master) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master) |

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Working with Contexts](#working-with-contexts)
    - [Create a Context specifying the Key Manually](#create-a-context-specifying-the-key-manually)
    - [Use CosmosDB Module to Retrieve Key from Azure Management Portal](#use-cosmosdb-module-to-retrieve-key-from-azure-management-portal)
    - [Create a Context for a CosmosDB Emulator](#create-a-context-for-a-cosmosdb-emulator)
    - [Create a Context from Resource Authorization Tokens](#create-a-Context-from-resource-authorization-tokens)
  - [Working with Databases](#working-with-databases)
  - [Working with Offers](#working-with-offers)
  - [Working with Collections](#working-with-collections)
    - [Creating a Collection with a custom Indexing Policy](#creating-a-collection-with-a-custom-indexing-policy)
  - [Working with Documents](#working-with-documents)
    - [Working with Documents in a Partitioned Collection](#working-with-documents-in-a-partitioned-collection)
  - [Using Resource Authorization Tokens](#using-resource-authorization-tokens)
  - [Working with Attachments](#working-with-attachments)
  - [Working with Users](#working-with-users)
  - [Stored Procedures](#working-with-stored-procedures)
  - [Working with Triggers](#working-with-triggers)
  - [Working with User Defined Functions](#working-with-user-defined-functions)
- [Contributing](#contributing)
- [Cmdlets](#cmdlets)
- [Change Log](#change-log)
- [Links](#links)

## Introduction

This PowerShell module provides cmdlets for working with Azure Cosmos DB.

The CosmosDB PowerShell module enables management of:

- [Attachments](#working-with-attachments)
- [Collections](#working-with-collections)
- [Databases](#working-with-databases)
- [Documents](#working-with-documents)
- [Offers](#working-with-offers)
- [Permissions](#working-with-permissions)
- [Stored Procedures](#working-with-stored-procedures)
- [Triggers](#working-with-triggers)
- [User Defined Functions](#working-with-user-defined-functions)
- [Users](#working-with-users)

The module uses the CosmosDB (DocumentDB) Rest APIs.

For more information on the CosmosDB Rest APIs, see [this link](https://docs.microsoft.com/en-us/rest/api/documentdb/restful-interactions-with-documentdb-resources).

## Requirements

This module supports the following:

- Windows PowerShell 5.x:
  - **AzureRM.Profile** and **AzureRM.Resources** PowerShell modules
    are required if using `New-CosmosDbContext -ResourceGroup $resourceGroup`

or:

- PowerShell Core 6.x:
  - **AzureRM.NetCore.Profile** and **AzureRM.NetCore.Resources** PowerShell
    modules are required if using `New-CosmosDbContext -ResourceGroup $resourceGroup`

## Installation

To install the module from PowerShell Gallery, use the PowerShell Cmdlet:

```powershell
Install-Module -Name CosmosDB
```

## Getting Started

The easiest way to use this module is to first create a context
object using the `New-CosmosDbContext` cmdlet which you can then
use to pass to the other CosmosDB cmdlets in the module.

To create the context object you will either need access to the
primary primary or secondary keys from your CosmosDB account or allow
the CosmosDB module to retrieve the keys directly from the Azure
management portal for you.

### Working with Contexts

#### Create a Context specifying the Key Manually

First convert your key into a secure string:

```powershell
$primaryKey = ConvertTo-SecureString -String 'GFJqJesi2Rq910E0G7P4WoZkzowzbj23Sm9DUWFX0l0P8o16mYyuaZBN00Nbtj9F1QQnumzZKSGZwknXGERrlA==' -AsPlainText -Force
```

Use the key secure string, Azure CosmosDB account name and database to
create a context variable:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey
```

#### Use CosmosDB Module to Retrieve Key from Azure Management Portal

To create a context object so that the CosmosDB module retrieves the
primary or secondary key from the Azure Management Portal, use the
following command:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -ResourceGroup 'MyCosmosDbResourceGroup' -MasterKeyType 'SecondaryMasterKey'
```

_Note: if PowerShell is not connected to Azure then an interactive
Azure login will be initiated. If PowerShell is already connected to
an account that doesn't contain the CosmosDB you wish to connect to then
you will first need to connect to the correct account using the
`Add-AzureRmAccount` cmdlet._

#### Create a Context for a CosmosDB Emulator

Microsoft provides a [CosmosDB emulator](https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator) that
you can run locally to enable testing and debugging scenarios. To create
a context for a CosmosDB emulator installed on the localhost use the
following command:

```powershell
$cosmosDbContext = New-CosmosDbContext -Emulator -Database 'MyDatabase'
```

#### Create a Context from Resource Authorization Tokens

See the section [Using Resource Authorization Tokens](#using-resource-authorization-tokens)
for instructions on how to create a Context object containing one or more _Resource
Authorization Tokens_.

### Working with Databases

Create a new database in the CosmosDB account:

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id 'AnotherDatabase'
```

Get a list of databases in the CosmosDB account:

```powershell
Get-CosmosDbDatabase -Context $cosmosDbContext
```

Get the specified database from the CosmosDB account:

```powershell
Get-CosmosDbDatabase -Context $cosmosDbContext -Id 'MyDatabase'
```

### Working with Offers

Get a list of offers in the CosmosDB account:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext
```

Query the offers in the CosmosDB account:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext -Query 'SELECT * FROM root WHERE (root["id"] = "lyiu")'
```

Update an existing V2 offer to set a different throughput:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext -Id 'lyiu' |
    Set-CosmosDbOffer -Context $cosmosDbContext -OfferThroughput 1000 -OfferIsRUPerMinuteThroughputEnabled $true
```

Update all existing V2 offers to set a different throughput:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext -Query 'SELECT * FROM root WHERE (root["offerVersion"] = "V2")' |
    Set-CosmosDbOffer -Context $cosmosDbContext -OfferThroughput 10000 -OfferIsRUPerMinuteThroughputEnabled $false
```

### Working with Collections

Get a list of collections in a database:

```powershell
Get-CosmosDbCollection -Context $cosmosDbContext
```

Create a collection in the database with the offer throughput of 2500 RU/s:

```powershell
New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -OfferThroughput 2500
```

Create a collection in the database with the partition key 'account' and
the offer throughput of 50000 RU/s:

```powershell
New-CosmosDbCollection -Context $cosmosDbContext -Id 'PartitionedCollection' -PartitionKey 'account' -OfferThroughput 50000
```

Get a specified collection from a database:

```powershell
Get-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection'
```

Delete a collection from the database:

```powershell
Remove-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection'
```

#### Creating a Collection with a custom Indexing Policy

You can create a collection with a custom indexing policy by assembling
an Indexing Policy object using the functions:

- New-CosmosDbCollectionIncludedPathIndex
- New-CosmosDbCollectionIncludedPath
- New-CosmosDbCollectionExcludedPath
- New-CosmosDbCollectionIndexingPolicy

For example, to create a string range and number range index on the '/*'
path using consistent indexing mode with no excluded paths:

```powershell
$indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String -Precision -1
$indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
$indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $indexStringRange, $indexNumberRange
$indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath
New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -PartitionKey 'account' -IndexingPolicy $indexingPolicy
```

For more information on how CosmosDB indexes documents, see [this page](https://docs.microsoft.com/en-us/azure/cosmos-db/indexing-policies).

### Working with Documents

Create 10 new documents in a collection in the database:

```powershell
0..9 | Foreach-Object {
    $document = @"
{
    `"id`": `"$([Guid]::NewGuid().ToString())`",
    `"content`": `"Some string`",
    `"more`": `"Some other string`"
}
"@
New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentBody $document
}
```

Get the first 5 documents from the collection in the database:

```powershell
$resultHeaders = ''
$documents = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -MaxItemCount 5 -ResultHeaders $resultHeaders
$continuationToken = $resultHeaders.value.'x-ms-continuation'
```

Get the next 5 documents from a collection in the database using
the continuation token found in the headers from the previous
request:

```powershell
$documents = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -MaxItemCount 5 -ContinuationToken $continuationToken
```

Replace the content of a document in a collection in the database:

```powershell
$newDocument = @"
{
    `"id`": `"$($documents[0].id)`",
    `"content`": `"New string`",
    `"more`": `"Another new string`"
}
"@
Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id $documents[0].id -DocumentBody $newDocument
```

Return a document with a specific Id from a collection in
the database:

```powershell
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id $documents[0].id
```

Querying a collection in a database:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Query $query
```

Querying a collection in a database using a parameterized query:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = @id)"
$queryParameters = @(
    @{ name = "@id"; value="user@contoso.com"; }
)
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Query $query -QueryParameters $queryParameters
```

Delete a document from a collection in the database:

```powershell
Remove-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id $documents[0].id
```

#### Working with Documents in a Partitioned Collection

Creating a document in a collection that has a Partition Key requires the
`PartitionKey` parameter to be specified for the document:

```powershell
$document = @"
{
    `"id`": `"en-us`",
    `"locale`": `"English (US)`"
}
"@
New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -DocumentBody $document -PartitionKey 'en-us'
```

Get a document from a partitioned collection with a specific Id:

```powershell
$document = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -Id 'en-us' -PartitionKey 'en-us'
```

Delete a document from a partitioned collection in the database:

```powershell
Remove-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -Id 'en-us' -PartitionKey 'en-us'
```

### Working with Attachments

Create an attachment on a document in a collection:

```powershell
New-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1' -ContentType 'image/jpg' -Media 'www.bing.com'
```

Get _all_ attachments for a document in a collection:

```powershell
Get-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentId $documents[0].id
```

Get an attachment by Id for a document in a collection:

```powershell
Get-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1'
```

Rename an attachment for a document in a collection:

```powershell
Set-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1' -NewId 'Image_2'
```

Delete an attachment from a document in collection:

```powershell
Remove-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id $documents[0].id -Id 'Image_2'
```

### Working with Users

Get a list of users in the database:

```powershell
Get-CosmosDbUser -Context $cosmosDbContext
```

Create a user in the database:

```powershell
New-CosmosDbUser -Context $cosmosDbContext -Id 'dscottraynsford@contoso.com'
```

Delete a user from the database:

```powershell
Remove-CosmosDbUser -Context $cosmosDbContext -Id 'dscottraynsford@contoso.com'
```

### Working with Permissions

Get a list of permissions for a user in the database:

```powershell
Get-CosmosDbPermission -Context $cosmosDbContext -UserId 'dscottraynsford@contoso.com'
```

Create a permission for a user in the database with read access to a collection:

```powershell
$collectionId = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
New-CosmosDbPermission -Context $cosmosDbContext -UserId 'dscottraynsford@contoso.com' -Id 'r_mynewcollection' -Resource $collectionId -PermissionMode Read
```

Remove a permission for a user from the database:

```powershell
Remove-CosmosDbPermission -Context $cosmosDbContext -UserId 'dscottraynsford@contoso.com' -Id 'r_mynewcollection'
```

### Using Resource Authorization Tokens

Cosmos DB supports using _resource authorization tokens_ to grant
access to individual resources (eg. documents, collections, triggers)
to a specific user. A user in this context can also be used to represent
an application that needs access to specific data.
This can be used to reduce the need to provide access to master keys
to end users.

To use a resource authorization token, first a permission must be assigned
to the user for the resource using the `New-CosmosDbPermission`. A user
can be created using the `New-CosmosDbUser` function.

**Note: By default, Resource Authorization Tokens expire after an hour.
This can be extended to a maximum of 5 hours or reduced to minimum of 10
minutes. Use the `TokenExpiry` parameter to control the length of time
that the resource authorization tokens will be valid for.**

The typical pattern for using _resource authorization tokens_ is to
have a **token broker app** that provides some form of user authentication
and then returns the _resource authorization tokens_ assigned to that
user. This removes the requirement for the user to be given access to
the **master** key for the CosmosDB database.

For more information on using _resource authorization tokens_ or the
**token broker app* pattern, please see [this document](https://docs.microsoft.com/en-us/azure/cosmos-db/secure-access-to-data#resource-tokens).

The following is an example showing how to create a resource context object
that contains a _resource authorization token_ granting access to read
the collection `MyNewCollection`. It is assumed that the permission for
the user `dscottraynsford@contoso.com` has been created as per the
previous section. The resource context object is then used to retrieve
the `MyNewCollection`.

The _resource authorization token_ is stored in the context object with an
expiration date/time matching what was returned in the permission so that
the validity of a token can be validated and reported on without making
a request to the Cosmos DB server.

```powershell
$collectionId = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
$permission = Get-CosmosDbPermission -Context $cosmosDbContext -UserId 'dscottraynsford@contoso.com' -Id 'r_mynewcollection' -Resource $collectionId -TokenExpiry 7200
# Future features planned to make creation of a resource context token from a permission easier
$contextToken = New-CosmosDbContextToken `
    -Resource $collectionId `
    -TimeStamp $permission[0].Timestamp `
    -TokenExpiry 7200 `
    -Token (ConvertTo-SecureString -String $permission[0].Token -AsPlainText -Force)
$resourceContext = New-CosmosDbContext `
    -Account $cosmosDBContext.Account
    -Database 'MyDatabase' `
    -Token $contextToken
Get-CosmosDbCollection `
    -Context $resourceContext `
    -Id 'MyNewCollection' `
```

### Working with Triggers

Get a list of triggers for a collection in the database:

```powershell
Get-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection'
```

Create a trigger for a collection in the database that executes after all operations:

```powershell
$body = @'
function updateMetadata() {
    var context = getContext();
    var collection = context.getCollection();
    var response = context.getResponse();
    var createdDocument = response.getBody();

    // query for metadata document
    var filterQuery = 'SELECT * FROM root r WHERE r.id = "_metadata"';
    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery, updateMetadataCallback);
    if(!accept) throw "Unable to update metadata, abort";

    function updateMetadataCallback(err, documents, responseOptions) {
        if(err) throw new Error("Error" + err.message);

        if(documents.length != 1) throw 'Unable to find metadata document';
        var metadataDocument = documents[0];

        // update metadata
        metadataDocument.createdDocuments += 1;
        metadataDocument.createdNames += " " + createdDocument.id;

        var accept = collection.replaceDocument(metadataDocument._self, metadataDocument, function(err, docReplaced) {
            if(err) throw "Unable to update metadata, abort";
        });

        if(!accept) throw "Unable to update metadata, abort";
        return;
    }
}
'@
New-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'MyTrigger' -TriggerBody $body -TriggerOperation All -TriggerType Post
```

Update an existing trigger for a collection in the database to execute before
all operations:

```powershell
$body = @'
function updateMetadata() {
    var context = getContext();
    var collection = context.getCollection();
    var response = context.getResponse();
    var createdDocument = response.getBody();

    // query for metadata document
    var filterQuery = 'SELECT * FROM root r WHERE r.id = "_metadata"';
    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery, updateMetadataCallback);
    if(!accept) throw "Unable to update metadata, abort";

    function updateMetadataCallback(err, documents, responseOptions) {
        if(err) throw new Error("Error" + err.message);

        if(documents.length != 1) throw 'Unable to find metadata document';
        var metadataDocument = documents[0];

        // update metadata
        metadataDocument.createdDocuments += 1;
        metadataDocument.createdNames += " " + createdDocument.id;

        var accept = collection.replaceDocument(metadataDocument._self, metadataDocument, function(err, docReplaced) {
            if(err) throw "Unable to update metadata, abort";
        });

        if(!accept) throw "Unable to update metadata, abort";
        return;
    }
}
'@
Set-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'MyTrigger' -Body $body -TriggerOperation All -TriggerType Pre
```

Remove a trigger for a collection from the database:

```powershell
Remove-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'MyTrigger'
```

### Working with Stored Procedures

Get a list of stored procedures for a collection in the database:

```powershell
Get-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection'
```

Create a stored procedure for a collection in the database:

```powershell
$body = @'
function () {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, World");
}
'@
New-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $body
```

Update an existing stored procedure for a collection in the database:

```powershell
$body = @'
function (personToGreet) {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, " + personToGreet);
}
'@
Set-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $body
```

Execute a stored procedure for a collection from the database:

```powershell
Invoke-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureParameters @('PowerShell')
```

Remove a stored procedure for a collection from the database:

```powershell
Remove-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld'
```

### Working with User Defined Functions

Get a list of user defined functions for a collection in the database:

```powershell
Get-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection'
```

Create a user defined function for a collection in the database:

```powershell
$Body = @'
function tax(income) {
    if(income == undefined) throw 'no input';
    if (income < 1000)
        return income * 0.1;
    else if (income < 10000)
        return income * 0.2;
    else
        return income * 0.4;
}
'@
New-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax' -UserDefinedFunctionBody $Body
```

Update an existing user defined function for a collection in the database:

```powershell
$body = @'
function tax(income) {
    if(income == undefined) throw 'no input';
    if (income < 1000)
        return income * 0.2;
    else if (income < 10000)
        return income * 0.3;
    else
        return income * 0.4;
}
'@
Set-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax' -Body $body
```

Remove a user defined function for a collection from the database:

```powershell
Remove-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax'
```

## Contributing

If you wish to contribute to this project, please read the [Contributing.md](/.github/CONTRIBUTING.md)
document first. We would be very grateful of any contributions.

## Cmdlets

A list of Cmdlets in the CosmosDB module can be found by running the
following PowerShell commands:

```PowerShell
Import-Module CosmosDB
Get-Command -Module CosmosDB
```

Help on individual Cmdlets can be found in the built-in Cmdlet help:

```PowerShell
Get-Help -Name Get-CosmosDBUser
```

The details of the cmdlets contained in this module can also be
found in the [wiki](https://github.com/PlagueHO/CosmosDB/wiki).

## Change Log

For a list of changes to versions, see the [CHANGELOG.md](CHANGELOG.md) file.

## Links

- [GitHub Repository](https://github.com/PlagueHO/CosmosDB/)
- [Blog](https://dscottraynsford.wordpress.com/)
