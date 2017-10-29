# CosmosDB

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

To use this module you will require either the primary or secondary
keys from your CosmosDB account.

First convert your key into a secure string:

```powershell
$primaryKey = ConvertTo-SecureString -String 'GFJqJesi2Rq910E0G7P4WoZkzowzbj23Sm9DUWFX0l0P8o16mYyuaZBN00Nbtj9F1QQnumzZKSGZwknXGERrlA==' -AsPlainText -Force
```

Use the key secure string, Azure CosmosDB account name and database to create a connection variable:

```powershell
$cosmosDbConnection = New-CosmosDbConnection -Acccount 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey
```

### Working with Collections

Get a list of collections in the database:

```powershell
Get-CosmosDbCollection -Connection $cosmosDbConnection
```

Create a collection in the database:

```powershell
New-CosmosDbCollection -Connection $cosmosDbConnection -Id 'MyNewCollection'
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
the `docs` folder.

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
