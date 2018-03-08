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
  - [Working with Databases](#working-with-databases)
  - [Working with Offers](#working-with-offers)
  - [Working with Collections](#working-with-collections)
    - [Creating a Collection with a custom Indexing Policy](#creating-a-collection-with-a-custom-indexing-policy)
  - [Working with Documents](#working-with-documents)
    -[Working with Documents in a Partitioned Collection](#working-with-documents-in-a-partitioned-collection)
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

### Working with Databases

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

Get the next document from a collection in the database using
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
New-CosmosDbUser -Context $cosmosDbContext -Id 'MyApplication'
```

Delete a user from the database:

```powershell
Remove-CosmosDbUser -Context $cosmosDbContext -Id 'MyApplication'
```

### Working with Permissions

Get a list of permissions for a user in the database:

```powershell
Get-CosmosDbPermission -Context $cosmosDbContext -UserId 'MyApplication'
```

Create a permission for a user in the database with read access to a collection:

```powershell
$collectionId = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
New-CosmosDbPermission -Context $cosmosDbContext -UserId 'MyApplication' -Id 'r_mynewcollection' -Resource $$collectionId -PermissionMode Read
```

Remove a permission for a user from the database:

```powershell
Remove-CosmosDbPermission -Context $cosmosDbContext -UserId 'MyApplication' -Id 'r_mynewcollection'
```

### Working with Triggers

Get a list of triggers for a collection in the database:

```powershell
Get-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection'
```

Create a trigger for a collection in the database that executes after all operations:

```powershell
$Body = @'
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
New-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'MyTrigger' -TriggerBody $Body -TriggerOperation All -TriggerType Post
```

Update an existing trigger for a collection in the database to execute before
all operations:

```powershell
$Body = @'
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
New-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'MyTrigger' -Body $Body -TriggerOperation All -TriggerType Pre
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
$Body = @'
function () {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, World");
}
'@
New-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $Body
```

Update an existing stored procedure for a collection in the database:

```powershell
$Body = @'
function (personToGreet) {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, " + personToGreet);
}
'@
New-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $Body
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
$Body = @'
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
New-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax' -Body $Body
```

Remove a user defined function for a collection from the database:

```powershell
Remove-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax'
```

## Contributing

If you wish to contribute to this project, please read the [Contributing.md](/.github/CONTRIBUTING.md)
document first. We would be very grateful of any contributions.

## Cmdlets

Full details of the cmdlets contained in this module can be found in
the [docs](/docs/) folder.

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

## Change Log

For a list of changes to versions, see the [CHANGELOG.md](CHANGELOG.md) file.

## Links

- [GitHub Repository](https://github.com/PlagueHO/CosmosDB/)
- [Blog](https://dscottraynsford.wordpress.com/)
