---
Module Name: CosmosDB
Module Guid: 7d7aeb42-8ed9-4555-b5fd-020795a5aa01
Download Help Link:
Help Version: 2.0.0.0
Locale: en-US
---

# CosmosDB Module

## Description

This PowerShell module provides cmdlets for working with Azure Cosmos DB.

## CosmosDB Cmdlets

### [ConvertTo-CosmosDbTokenDateString](ConvertTo-CosmosDbTokenDateString.md)

Convert a DateTime object into the format required for use
in a Cosmos DB Authorization Token and request header.

### [Get-CosmosDbAccount](Get-CosmosDbAccount.md)

Get the properties of a Cosmos DB account in Azure.

### [Get-CosmosDbAccountConnectionString](Get-CosmosDbAccountConnectionString.md)

Get the connection strings for a Cosmos DB account in Azure.

### [Get-CosmosDbAccountMasterKey](Get-CosmosDbAccountMasterKey.md)

Get a master key for a Cosmos DB account in Azure.

### [Get-CosmosDbAttachment](Get-CosmosDbAttachment.md)

Return the attachments for a Cosmos DB document.

### [Get-CosmosDbAttachmentResourcePath](Get-CosmosDbAttachmentResourcePath.md)

Return the resource path for an attachment object.

### [Get-CosmosDbCollection](Get-CosmosDbCollection.md)

Return the collections in a Cosmos DB database.

### [Get-CosmosDbCollectionResourcePath](Get-CosmosDbCollectionResourcePath.md)

Return the resource path for a collection object.

### [Get-CosmosDbDatabase](Get-CosmosDbDatabase.md)

Return the databases in a Cosmos DB account.

### [Get-CosmosDbDatabaseResourcePath](Get-CosmosDbDatabaseResourcePath.md)

Return the resource path for a database object.

### [Get-CosmosDbDocument](Get-CosmosDbDocument.md)

Return the documents for a Cosmos DB database collection.

### [Get-CosmosDbDocumentResourcePath](Get-CosmosDbDocumentResourcePath.md)

Return the resource path for a document object.

### [Get-CosmosDbOffer](Get-CosmosDbOffer.md)

Return the offers in a Cosmos DB account.

### [Get-CosmosDbOfferResourcePath](Get-CosmosDbOfferResourcePath.md)

Return the resource path for a offer object.

### [Get-CosmosDbPermission](Get-CosmosDbPermission.md)

Return the permissions for a Cosmos DB database user.

### [Get-CosmosDbPermissionResourcePath](Get-CosmosDbPermissionResourcePath.md)

Return the resource path for a permission object.

### [Get-CosmosDbStoredProcedure](Get-CosmosDbStoredProcedure.md)

Return the stored procedures for a Cosmos DB database collection.

### [Get-CosmosDbStoredProcedureResourcePath](Get-CosmosDbStoredProcedureResourcePath.md)

Execute a new stored procedure for a collection in a Cosmos DB
database.

### [Get-CosmosDbTrigger](Get-CosmosDbTrigger.md)

Return the triggers for a Cosmos DB database collection.

### [Get-CosmosDbTriggerResourcePath](Get-CosmosDbTriggerResourcePath.md)

Return the resource path for a trigger object.

### [Get-CosmosDbUri](Get-CosmosDbUri.md)

Return the URI of the Cosmos DB that Rest APIs requests will
be sent to.

### [Get-CosmosDbUser](Get-CosmosDbUser.md)

Return the users in a Cosmos DB database.

### [Get-CosmosDbUserDefinedFunction](Get-CosmosDbUserDefinedFunction.md)

Return the user defined functions for a Cosmos DB database collection.

### [Get-CosmosDbUserDefinedFunctionResourcePath](Get-CosmosDbUserDefinedFunctionResourcePath.md)

Return the resource path for a user defined function object.

### [Get-CosmosDbUserResourcePath](Get-CosmosDbUserResourcePath.md)

Return the resource path for a user object.

### [Invoke-CosmosDbRequest](Invoke-CosmosDbRequest.md)

Execute a new request to a Cosmos DB REST endpoint.

### [Invoke-CosmosDbStoredProcedure](Invoke-CosmosDbStoredProcedure.md)

Execute a new stored procedure for a collection in a Cosmos DB database.

### [New-CosmosDbAccount](New-CosmosDbAccount.md)

Create a new Cosmos DB account in Azure.

### [New-CosmosDbAccountMasterKey](New-CosmosDbAccountMasterKey.md)

This will regenerate a specific master key for an existing Cosmos DB account
in Azure.

### [New-CosmosDbAttachment](New-CosmosDbAttachment.md)

Create a new attachment for a document in a Cosmos DB database.

### [New-CosmosDbAuthorizationToken](New-CosmosDbAuthorizationToken.md)

Create a new Authorization Token to be used with in a
Rest API request to Cosmos DB.

### [New-CosmosDbCollection](New-CosmosDbCollection.md)

Create a new collection in a Cosmos DB database.

### [New-CosmosDbCollectionExcludedPath](New-CosmosDbCollectionExcludedPath.md)

Creates an indexing policy excluded path object that can be
added to an Indexing Policy.

### [New-CosmosDbCollectionIncludedPath](New-CosmosDbCollectionIncludedPath.md)

Creates an indexing policy included path object that can be
added to an Indexing Policy.

### [New-CosmosDbCollectionIncludedPathIndex](New-CosmosDbCollectionIncludedPathIndex.md)

Creates an indexing policy included path index object that
can be added to an Included Path of an Indexing Policy.

### [New-CosmosDbCollectionUniqueKey](New-CosmosDbCollectionUniqueKey.md)

Creates a unique key object that can be passed to the
New-CosmosDbCollectionUniqueKeyPolicy function when generating a unique key
policy.

### [New-CosmosDbCollectionUniqueKeyPolicy](New-CosmosDbCollectionUniqueKeyPolicy.md)

Creates a unique key policy object that can be passed to the
New-CosmosDbCollection function.

### [New-CosmosDbCollectionIndexingPolicy](New-CosmosDbCollectionIndexingPolicy.md)

Creates an indexing policy object that can be passed to the
New-CosmosDbCollection function.

### [New-CosmosDbContext](New-CosmosDbContext.md)

Create a context object containing the information required
to connect to a Cosmos DB.

### [New-CosmosDbDatabase](New-CosmosDbDatabase.md)

Create a new database in a Cosmos DB account.

### [New-CosmosDbDocument](New-CosmosDbDocument.md)

Create a new document for a collection in a Cosmos DB database.

### [New-CosmosDbInvalidArgumentException](New-CosmosDbInvalidArgumentException.md)

Creates and throws an invalid argument exception.

### [New-CosmosDbInvalidOperationException](New-CosmosDbInvalidOperationException.md)

Creates and throws an invalid operation exception.

### [New-CosmosDbPermission](New-CosmosDbPermission.md)

Create a new permission for a user in a Cosmos DB database.

### [New-CosmosDbStoredProcedure](New-CosmosDbStoredProcedure.md)

Create a new stored procedure for a collection in a Cosmos DB database.

### [New-CosmosDbTrigger](New-CosmosDbTrigger.md)

Create a new trigger for a collection in a Cosmos DB database.

### [New-CosmosDbUser](New-CosmosDbUser.md)

Create a new user in a Cosmos DB database.

### [New-CosmosDbUserDefinedFunction](New-CosmosDbUserDefinedFunction.md)

Create a new user defined function for a collection in a Cosmos DB database.

### [Remove-CosmosDbAttachment](Remove-CosmosDbAttachment.md)

Delete an attachment from a Cosmos DB document.

### [Remove-CosmosDbCollection](Remove-CosmosDbCollection.md)

Delete a collection from a Cosmos DB database.

### [Remove-CosmosDbDatabase](Remove-CosmosDbDatabase.md)

Delete a database from a Cosmos DB account.

### [Remove-CosmosDbDocument](Remove-CosmosDbDocument.md)

Delete a document from a Cosmos DB collection.

### [Remove-CosmosDbPermission](Remove-CosmosDbPermission.md)

Delete a permission from a Cosmos DB user.

### [Remove-CosmosDbStoredProcedure](Remove-CosmosDbStoredProcedure.md)

Delete a stored procedure from a Cosmos DB collection.

### [Remove-CosmosDbTrigger](Remove-CosmosDbTrigger.md)

Delete a trigger from a Cosmos DB collection.

### [Remove-CosmosDbUser](Remove-CosmosDbUser.md)

Delete a user from a Cosmos DB database.

### [Remove-CosmosDbUserDefinedFunction](Remove-CosmosDbUserDefinedFunction.md)

Delete a user defined function from a Cosmos DB collection.

### [Set-CosmosDbAccount](Set-CosmosDbAccount.md)

Update the properties of an existing Azure Cosmos DB account.

### [Set-CosmosDbAttachment](Set-CosmosDbAttachment.md)

Update am attachment for a Cosmos DB document.

### [Set-CosmosDbAttachmentType](Set-CosmosDbAttachmentType.md)

Set the custom Cosmos DB Attachment types to the attachment
returned by an API call.

### [Set-CosmosDbCollectionType](Set-CosmosDbCollectionType.md)

Set the custom Cosmos DB Collection types to the collection
returned by an API call.

### [Set-CosmosDbDatabaseType](Set-CosmosDbDatabaseType.md)

Set the custom Cosmos DB Database types to the database
returned by an API call.

### [Set-CosmosDbDocument](Set-CosmosDbDocument.md)

Update a document from a Cosmos DB collection.

### [Set-CosmosDbDocumentType](Set-CosmosDbDocumentType.md)

Set the custom Cosmos DB document types to the document returned
by an API call.

### [Set-CosmosDbOffer](Set-CosmosDbOffer.md)

Update an existing offer in a Cosmos DB database.

### [Set-CosmosDbOfferType](Set-CosmosDbOfferType.md)

Set the custom Cosmos DB Offer types to the offer
returned by an API call.

### [Set-CosmosDbPermissionType](Set-CosmosDbPermissionType.md)

Set the custom Cosmos DB User types to the permission
returned by an API call.

### [Set-CosmosDbStoredProcedure](Set-CosmosDbStoredProcedure.md)

Update a stored procedure from a Cosmos DB collection.

### [Set-CosmosDbStoredProcedureType](Set-CosmosDbStoredProcedureType.md)

Set the custom Cosmos DB stored procedure types to the
stored procedure returned by an API call.

### [Set-CosmosDbTrigger](Set-CosmosDbTrigger.md)

Update a trigger from a Cosmos DB collection.

### [Set-CosmosDbTriggerType](Set-CosmosDbTriggerType.md)

Set the custom Cosmos DB trigger types to the trigger returned
by an API call.

### [Set-CosmosDbUser](Set-CosmosDbUser.md)

Set the user Id of an existing user in a Cosmos DB database.

### [Set-CosmosDbUserDefinedFunction](Set-CosmosDbUserDefinedFunction.md)

Update a user defined function from a Cosmos DB collection.

### [Set-CosmosDbUserDefinedFunctionType](Set-CosmosDbUserDefinedFunctionType.md)

Set the custom Cosmos DB User Defined Function types to the user
defined function returned by an API call.

### [Set-CosmosDbUserType](Set-CosmosDbUserType.md)

Set the custom Cosmos DB User types to the user
returned by an API call.
