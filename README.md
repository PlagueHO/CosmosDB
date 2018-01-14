# CosmosDB PowerShell Module

| Branch | Build Status | Code Coverage |
| --- | --- | --- |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/dev?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/dev) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev) |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/master) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master) |

## Introduction

This PowerShell module provides cmdlets for working with Azure Cosmos DB.

The CosmosDB PowerShell module enables management of:

- Attachments
- Collections
- Databases
- Documents
- Permissions
- Stored procedures
- Triggers
- User Defined Functions
- Users

The module uses the CosmosDB (DocumentDB) Rest APIs.

For more information on the CosmosDB Rest APIs, see [this link](https://docs.microsoft.com/en-us/rest/api/documentdb/restful-interactions-with-documentdb-resources).

## Requirements

This module supports the following:

- Windows PowerShell 5.x:
  - **AzureRM.Profile** and **AzureRM.Resources** PowerShell modules
    are required if using `New-CosmosDbConnection -ResourceGroup $resourceGroup`

or:

- PowerShell Core 6.x:
  - **AzureRM.NetCore.Profile** and **AzureRM.NetCore.Resources** PowerShell
    modules are required if using `New-CosmosDbConnection -ResourceGroup $resourceGroup`

## Installation

To install the module from PowerShell Gallery, use the PowerShell Cmdlet:

```powershell
Install-Module -Name CosmosDB
```

## Quick Start

The easiest way to use this module is to first create a connection
object using the `New-CosmosDbConnection` cmdlet which you can then
use to pass to the other CosmosDB cmdlets in the module.

To create the connection object you will either need access to the
primary primary or secondary keys from your CosmosDB account or allow
the CosmosDB module to retrieve the keys directly from the Azure
management portal for you.

### Create a Connection specifying the Key Manually

First convert your key into a secure string:

```powershell
$primaryKey = ConvertTo-SecureString -String 'GFJqJesi2Rq910E0G7P4WoZkzowzbj23Sm9DUWFX0l0P8o16mYyuaZBN00Nbtj9F1QQnumzZKSGZwknXGERrlA==' -AsPlainText -Force
```

Use the key secure string, Azure CosmosDB account name and database to create a connection variable:

```powershell
$cosmosDbConnection = New-CosmosDbConnection -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey
```

### Use CosmosDB Module to Retrieve Key from Azure Management Portal

To create a connection object so that CosmosDB retrieves the primary or
secondary key from the Azure Management Portal, use the following command:

```powershell
$cosmosDbConnection = New-CosmosDbConnection -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -ResourceGroup 'MyCosmosDbResourceGroup' -MasterKeyType 'SecondaryMasterKey'
```

_Note: if PowerShell is not connected to Azure then an interactive
Azure login will be initiated. If PowerShell is already connected to
an account that doesn't contain the CosmosDB you wish to connect to then
you will first need to connect to the correct account using the
`Add-AzureRmAccount` cmdlet._

### Working with Databases

Get a list of databases in the CosmosDB account:

```powershell
Get-CosmosDbDatabase -Connection $cosmosDbConnection
```

Get the specified database from the CosmosDB account:

```powershell
Get-CosmosDbDatabase -Connection $cosmosDbConnection -Id 'MyDatabase'
```

### Working with Collections

Get a list of collections in a database:

```powershell
Get-CosmosDbCollection -Connection $cosmosDbConnection
```

Create a collection in the database with the partition key 'account' and the offer throughput of 50000 RU/s:

```powershell
New-CosmosDbCollection -Connection $cosmosDbConnection -Id 'MyNewCollection' -PartitionKey 'account' -OfferThroughput 50000
```

Get a specified collection from a database:

```powershell
Get-CosmosDbCollection -Connection $cosmosDbConnection -Id 'MyNewCollection'
```

Delete a collection from the database:

```powershell
Remove-CosmosDbCollection -Connection $cosmosDbConnection -Id 'MyNewCollection'
```

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
    New-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -DocumentBody $document
}
```

Get the first 5 documents from the collection in the database:

```powershell
$resultHeaders = ''
$documents = Get-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -MaxItemCount 5 -ResultHeaders $resultHeaders
$continuationToken = $resultHeaders.value.'x-ms-continuation'
```

Get the next document from a collection in the database using
the continuation token found in the headers from the previous
request:

```powershell
$documents = Get-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -MaxItemCount 5 -ContinuationToken $continuationToken
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
Set-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id $documents[0].id -DocumentBody $newDocument
```

Return a document with a specific Id from a collection in
the database:

```powershell
Get-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id $documents[0].id
```

Querying a collection in a database:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
Get-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Query $query
```

Querying a collection in a database using a parameterized query:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = @id)"
$queryParameters = @(
    @{ name = "@id"; value="user@contoso.com"; }
)
Get-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Query $query -QueryParameters $queryParameters
```

Delete a document from a collection in the database:

```powershell
Remove-CosmosDbDocument -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id $documents[0].id
```

### Working with Attachments

Create an attachment on a document in a collection:

```powershell
New-CosmosDbAttachment -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1' -ContentType 'image/jpg' -Media 'www.bing.com'
```

Get _all_ attachments for a document in a collection:

```powershell
Get-CosmosDbAttachment -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -DocumentId $documents[0].id
```

Get an attachment by Id for a document in a collection:

```powershell
Get-CosmosDbAttachment -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1'
```

Rename an attachment for a document in a collection:

```powershell
Set-CosmosDbAttachment -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -DocumentId $documents[0].id -Id 'image_1' -NewId 'Image_2'
```

Delete an attachment from a document in collection:

```powershell
Remove-CosmosDbAttachment -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id $documents[0].id -Id 'Image_2'
```

### Working with Users

Get a list of users in the database:

```powershell
Get-CosmosDbUser -Connection $cosmosDbConnection
```

Create a user in the database:

```powershell
New-CosmosDbUser -Connection $cosmosDbConnection -Id 'MyApplication'
```

Delete a user from the database:

```powershell
Remove-CosmosDbUser -Connection $cosmosDbConnection -Id 'MyApplication'
```

### Working with Permissions

Get a list of permissions for a user in the database:

```powershell
Get-CosmosDbPermission -Connection $cosmosDbConnection -UserId 'MyApplication'
```

Create a permission for a user in the database with read access to a collection:

```powershell
$collectionId = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
New-CosmosDbPermission -Connection $cosmosDbConnection -UserId 'MyApplication' -Id 'r_mynewcollection' -Resource $$collectionId -PermissionMode Read
```

Remove a permission for a user from the database:

```powershell
Remove-CosmosDbPermission -Connection $cosmosDbConnection -UserId 'MyApplication' -Id 'r_mynewcollection'
```

### Working with Triggers

Get a list of triggers for a collection in the database:

```powershell
Get-CosmosDbTrigger -Connection $cosmosDbConnection -CollectionId 'MyNewCollection'
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
New-CosmosDbTrigger -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'MyTrigger' -TriggerBody $Body -TriggerOperation All -TriggerType Post
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
New-CosmosDbTrigger -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'MyTrigger' -Body $Body -TriggerOperation All -TriggerType Pre
```

Remove a trigger for a collection from the database:

```powershell
Remove-CosmosDbTrigger -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'MyTrigger'
```

### Working with Stored procedures

Get a list of stored procedures for a collection in the database:

```powershell
Get-CosmosDbStoredProcedure -Connection $cosmosDbConnection -CollectionId 'MyNewCollection'
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
New-CosmosDbStoredProcedure -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $Body
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
New-CosmosDbStoredProcedure -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureBody $Body
```

Execute a stored procedure for a collection from the database:

```powershell
Invoke-CosmosDbStoredProcedure -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'spHelloWorld' -StoredProcedureParameters @('PowerShell')
```

Remove a stored procedure for a collection from the database:

```powershell
Remove-CosmosDbStoredProcedure -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'spHelloWorld'
```

### Working with User Defined Functions

Get a list of user defined functions for a collection in the database:

```powershell
Get-CosmosDbUserDefinedFunction -Connection $cosmosDbConnection -CollectionId 'MyNewCollection'
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
New-CosmosDbUserDefinedFunction -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'udfTax' -UserDefinedFunctionBody $Body
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
New-CosmosDbUserDefinedFunction -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'udfTax' -Body $Body
```

Remove a user defined function for a collection from the database:

```powershell
Remove-CosmosDbUserDefinedFunction -Connection $cosmosDbConnection -CollectionId 'MyNewCollection' -Id 'udfTax'
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
