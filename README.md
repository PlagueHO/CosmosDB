# CosmosDB PowerShell Module

| Branch | Build Status | Code Coverage |
| --- | --- | --- |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/dev?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/dev) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/dev) |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/v5wqtt63nnmkm94j/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/cosmosdb/branch/master) | [![codecov](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master/graph/badge.svg)](https://codecov.io/gh/PlagueHO/CosmosDB/branch/master) |

## Introduction

This PowerShell module provides cmdlets for working with Azure Cosmos DB
databases, collections, users and permissions.

The module uses the CosmosDB (DocumentDB) Rest APIs.

For more information on the CosmosDB Rest APIs, see [this link](https://docs.microsoft.com/en-us/rest/api/documentdb/restful-interactions-with-documentdb-resources).

## Requirements

This module requires:

- PowerShell 5.0

It may work on PowerShell 6.0, but is currently untested.

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
$cosmosDbConnection = New-CosmosDbConnection -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -ResourceGroup 'MyCosmosDbResourceGroup' -MasterKeyType 'Secondary'
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
