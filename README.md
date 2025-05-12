[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/PlagueHO/CosmosDB/blob/dev/LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-CosmosDB-blue.svg)](https://github.com/PlagueHO/CosmosDB/wiki)
[![PowerShell Gallery](https://img.shields.io/badge/PowerShell%20Gallery-CosmosDB-blue.svg)](https://www.powershellgallery.com/packages/CosmosDB)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/cosmosdb.svg)](https://www.powershellgallery.com/packages/CosmosDB)
[![Minimum Supported Windows PowerShell Version](https://img.shields.io/badge/WindowsPowerShell-5.1-blue.svg)](https://github.com/PlagueHO/CosmosDB)
[![Minimum Supported PowerShell Core Version](https://img.shields.io/badge/PSCore-6.0-blue.svg)](https://github.com/PlagueHO/CosmosDB)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PS-7.0-blue.svg)](https://github.com/PlagueHO/CosmosDB)

# CosmosDB PowerShell Module

## Module Build Status

| Branch | Azure Pipelines                    | Automated Tests                    | Code Quality                       |
| ------ | ---------------------------------- | -----------------------------------| ---------------------------------- |
| main   | [![ap-image-main][]][ap-site-main] | [![ts-image-main][]][ts-site-main] | [![cq-image-main][]][cq-site-main] |

## Introduction

This PowerShell module provides cmdlets for accessing Cosmos DB collections via the
[Azure Cosmos DB REST API](https://learn.microsoft.com/rest/api/cosmos-db/).
It makes it easy to perform CRUD operations on Cosmos DB collections and documents
and related entities while also implementing role-based access control or token-based
authentication.

> [!IMPORTANT]
> The _CosmosDB PowerShell module_ is **not** intended to be a replacement for the
> [Az.CosmosDB](https://www.powershellgallery.com/packages/Az.CosmosDB), rather it
> **complements** it by providing functionality to access the documents within
> collections.
>
> There is some cross-over between the two modules, but the _CosmosDB PowerShell
> module_ is primarily intended to be used for accessing the documents within
> collections.

The _CosmosDB PowerShell module_ enables management of:

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

The module uses the Cosmos DB (DocumentDB) Rest APIs. For more information on
the Cosmos DB Rest APIs, see [this link](https://learn.microsoft.comrest/api/cosmos-db/restful-interactions-with-cosmosdb-resources).

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Recommended Knowledge](#recommended-knowledge)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Working with Contexts](#working-with-contexts)
    - [Create a Context using an Entra ID Authorization Token](create-a-context-using-an-entra-id-authorization-token)
      - [Configuring Role-Based Access Control (RBAC) with Entra ID](#configuring-role-based-access-control-rbac-with-entra-id)
      - [Database Operations allowed by Role-Based Access Control](#database-operations-allowed-by-role-based-access-control)
    - [Create a Context specifying the Key Manually](#create-a-context-specifying-the-key-manually)
    - [Use CosmosDB Module to Retrieve Key from Azure Management Portal](#use-cosmosdb-module-to-retrieve-key-from-azure-management-portal)
    - [Create a Context from Resource Authorization Tokens](#create-a-context-from-resource-authorization-tokens)
    - [Create a Context for a Cosmos DB in Azure US Government Cloud](#create-a-context-for-a-cosmos-db-in-azure-us-government-cloud)
    - [Create a Context for a Cosmos DB in Azure China Cloud (Mooncake)](#create-a-context-for-a-cosmos-db-in-azure-china-cloud-mooncake)
    - [Create a Context for a Cosmos DB with a Custom Endpoint](#create-a-context-for-a-cosmos-db-with-a-custom-endpoint)
    - [Create a Context for a Cosmos DB Emulator](#create-a-context-for-a-cosmos-db-emulator)
  - [Working with Accounts](#working-with-accounts)
  - [Working with Databases](#working-with-databases)
  - [Working with Offers](#working-with-offers)
  - [Working with Collections](#working-with-collections)
    - [Creating a Collection with a custom Indexing Policy](#creating-a-collection-with-a-custom-indexing-policy)
    - [Creating a Collection with a custom Indexing Policy including Composite Indexes](#creating-a-collection-with-a-custom-indexing-policy-including-composite-indexes)
    - [Update an existing Collection with a new Indexing Policy](#update-an-existing-collection-with-a-new-indexing-policy)
    - [Creating a Collection with a custom Indexing Policy using JSON](#creating-a-collection-with-a-custom-indexing-policy-using-json)
    - [Creating a Collection with a custom Unique Key Policy](#creating-a-collection-with-a-custom-unique-key-policy)
    - [Update an existing Collection with a new Unique Key Policy](#update-an-existing-collection-with-a-new-unique-key-policy)
    - [Creating a Collection without a Partition Key](#creating-a-collection-without-a-partition-key)
  - [Working with Documents](#working-with-documents)
    - [Using a While Loop to get all Documents in a Collection](#using-a-while-loop-to-get-all-documents-in-a-collection)
    - [Working with Documents in a non-partitioned Collection](#working-with-documents-in-a-non-partitioned-collection)
  - [Using Resource Authorization Tokens](#using-resource-authorization-tokens)
  - [Working with Attachments](#working-with-attachments)
  - [Working with Users](#working-with-users)
  - [Stored Procedures](#working-with-stored-procedures)
  - [Working with Triggers](#working-with-triggers)
  - [Working with User Defined Functions](#working-with-user-defined-functions)
  - [How to Handle Exceeding Provisioned Throughput](#how-to-handle-exceeding-provisioned-throughput)
- [Compatibility and Testing](#compatibility-and-testing)
- [Contributing](#contributing)
- [Cmdlets](#cmdlets)
- [Change Log](#change-log)
- [Links](#links)

## Requirements

This module requires the following:

- Windows PowerShell 5.x, PowerShell Core 6.x or PowerShell 7.x

### PowerShell Module Dependencies

- **Az.Account**: v2.19.0 or newer.
- **Az.Resources**: 6.16.2 or newer.

These modules are required if using `New-CosmosDbContext -ResourceGroupName $resourceGroup`
or `*-CosmosDbAccount` functions.

## Recommended Knowledge

It is recommended that before using this module it is important to understand
the fundamental concepts of Cosmos DB. This will ensure you have an optimal
experience by adopting design patterns that align to Cosmos DB best practices.

Users new to Cosmos DB should familiarize themselves with the following
concepts:

- [Overview of Cosmos DB](https://docs.microsoft.com/bs-cyrl-ba/azure/cosmos-db/introduction)
- [NoSQL vs. Relational Databases](https://docs.microsoft.com/bs-cyrl-ba/azure/cosmos-db/relational-nosql)
- [Partitioning](https://docs.microsoft.com/bs-cyrl-ba/azure/cosmos-db/partitioning-overview)

It is also recommended to watch [this Ignite video](https://myignite.microsoft.com/sessions/1410edb6-204d-4c45-adbb-ccb49e8135cf?source=sessions)
on data modelling and partitioning in Cosmos DB.

## Installation

To install the module from PowerShell Gallery, use the PowerShell Cmdlet:

```powershell
Install-Module -Name CosmosDB
```

## Getting Started

The easiest way to use this module is to first create a context
object using the `New-CosmosDbContext` cmdlet which you can then
use to pass to the other Cosmos DB cmdlets in the module.

To create the context object you will either need access to the
primary or secondary keys from your Cosmos DB account or allow
the _CosmosDB Powershell module_ to retrieve the keys directly from
the Azure management portal for you.

### Working with Contexts

#### Create a Context Using an Entra ID Authorization Token

You can create a context object that can include use an _Entra ID Authorization Token_
that will be used to authenticate requests to Cosmos DB.

> [!IMPORTANT]
> This is a recommended security practice to use when you've
> [configured role-based access control with Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac)
> on your Azure Cosmos DB account. It will help you keep your account secure
> by not exposing the primary or secondary keys in your code.

To create a context object using an _Entra ID Authorization Token_ you will need
to set the `EntraIdToken` parameter to the token you have retrieved from Entra ID
for the identity that you have given appropriate permissions to the `account`,
`database` and/or `collection`. See [this page](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#concepts) for more information.

```powershell
# Get an OAuth2 resource token from Entra ID for the Cosmos DB account.
# This will use the currently logged in user to authenticate to Entra ID to
# get the token. There are many other ways of doing this.
$entraIdOAuthToken = Get-CosmosDbEntraIdToken -Endpoint 'https://MyAzureCosmosDB.documents.azure.com'

$newCosmosDbContextParams  = @{
    Account      = 'MyAzureCosmosDB'
    EntraIdToken = $entraIdOAuthToken
}
$accountContext = New-CosmosDbContext @newCosmosDbContextParams
Get-CosmosDbCollection -Context $accountContext -Id MyNewCollection
```

An alternate method is to allow the New-CosmosDbContext cmdlet to retrieve the
Entra ID token for you. This will require you to have already logged into Azure
and will use the base URI detected for the account as the resource URI for the
token request.

```powershell
$newCosmosDbContextParams  = @{
    Account      = 'MyAzureCosmosDB'
    AutoGenerateEntraIdToken = $true
}
$accountContext = New-CosmosDbContext @newCosmosDbContextParams
Get-CosmosDbCollection -Context $accountContext -Id MyNewCollection
```

> [!IMPORTANT]
> Using an Entra ID Authorization Token is only supported by setting it
> in a CosmosDB.Context object and passing that to the commands you want to execute.
> Not all commands support this method of authentication. If you need to use a command
> that doesn't support this method of authentication, you will need to use one
> of the other methods of authentication. See the
> [Database Operations allowed by Role-Based Access Control](#database-operations-allowed-by-role-based-access-control)
> section for more information.

##### Using Entra ID Authorization Token for a custom cloud environment

You can create a context with Entra ID Authorization Token for an Azure cloud
environment other than the ones listed in the `Environment` parameter.

To do this, you can use the `EndpointHostname` parameter to specify the custom
endpoint for the Cosmos DB account.

```powershell
$newCosmosDbContextParams  = @{
    Account      = 'MyAzureCosmosDB'
    AutoGenerateEntraIdToken = $true
    EndpointHostname = 'documents.azurecustomcloud.com'
}
$accountContext = New-CosmosDbContext @newCosmosDbContextParams
Get-CosmosDbCollection -Context $accountContext -Id MyNewCollection
```

##### Configuring Role-Based Access Control (RBAC) with Entra ID

There are several ways to configure a Cosmos DB Account with Role-Based Access Control,
including:

- _Azure Bicep_: An example can be found in the [\tests\TestHelper\AzureDeploy\CosmosDb.bicep](\tests\TestHelper\AzureDeploy\CosmosDb.bicep) file.
- _Azure PowerShell_: The integration tests use this method.
- _AzCli_.

> [!IMPORTANT]
> One thing I found when adding a SQL Role Assignment to the Cosmos DB
> Account (or Database or Container) is that the principal ID must be the Object ID of
> the user, group or service principal that you want to assign the role to. You can't use
> the Application ID for this value.

For more information on how to configure Role-Based Access Control with Entra ID, see the
[Configure role-based access control with Microsoft Entra ID for your Azure Cosmos DB account](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac)
page.

##### Database Operations allowed by Role-Based Access Control

Only a subset of all the operations that can be performed on a Cosmos DB account are
allowed by Role-Based Access Control. The following operations are allowed:
This permission model covers only database operations that involve reading and writing data. It does not cover any kind of management operations on management resources, including:

- Create/Replace/Delete Database
- Create/Replace/Delete Container
- Read/Replace Container Throughput
- Create/Replace/Delete/Read Stored Procedures
- Create/Replace/Delete/Read Triggers
- Create/Replace/Delete/Read User Defined Functions

For more information on this, please see the [Role-based access control (RBAC) with Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#permission-model) page.

#### Create a Context specifying the Key Manually

> [!NOTE]
> This method of authenticating to Cosmos DB is not recommended for
> production use. It is recommended to use the _Entra ID Authorization Token_
> method described above.

First convert your key into a secure string:

```powershell
$primaryKey = ConvertTo-SecureString -String 'GFJqJesi2Rq910E0G7P4WoZkzowzbj23Sm9DUWFX0l0P8o16mYyuaZBN00Nbtj9F1QQnumzZKSGZwknXGERrlA==' -AsPlainText -Force
```

Use the key secure string, Azure Cosmos DB account name and database to
create a context variable:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -Key $primaryKey
```

#### Use CosmosDB Module to Retrieve Key from Azure Management Portal

> [!NOTE]
> This method of authenticating to Cosmos DB is not recommended for
> production use. It is recommended to use the _Entra ID Authorization Token_
> method described above.

To create a context object so that the _CosmosDB PowerShell module_
retrieves the primary or secondary key from the Azure Management
Portal, use the following command:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -ResourceGroupName MyCosmosDbResourceGroup -MasterKeyType SecondaryMasterKey
```

> [!NOTE]
> If PowerShell is not connected to Azure then an interactive
> Azure login will be initiated. If PowerShell is already connected to
> an account that doesn't contain the Cosmos DB you wish to connect to then
> you will first need to connect to the correct account using the
> `Connect-AzAccount` cmdlet.

#### Create a Context from Resource Authorization Tokens

> [!NOTE]
> This method of authenticating to Cosmos DB is better than using master key
> authentication, as it provides the ability to limit access to specific resources.
> However, it is recommended to use the _Entra ID Authorization Token_ method
> described above if possible.

See the section [Using Resource Authorization Tokens](#using-resource-authorization-tokens)
for instructions on how to create a Context object containing one or more _Resource
Authorization Tokens_.

#### Create a Context for a Cosmos DB in Azure US Government Cloud

> [!NOTE]
> This method of authenticating to Cosmos DB is not recommended for
> production use. It is recommended to use the _Entra ID Authorization Token_
> method described above.

Use the key secure string, Azure Cosmos DB account name and database to
create a context variable and set the `Environment` parameter to
`AzureUSGovernment`:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -Key $primaryKey -Environment AzureUSGovernment
```

#### Create a Context for a Cosmos DB in Azure China Cloud (Mooncake)

> [!NOTE]
> This method of authenticating to Cosmos DB is not recommended for
> production use. It is recommended to use the _Entra ID Authorization Token_
> method described above.

Use the key secure string, Azure Cosmos DB account name and database to
create a context variable and set the `Environment` parameter to
`AzureChinaCloud`:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -Key $primaryKey -Environment AzureChinaCloud
```

#### Create a Context for a Cosmos DB with a Custom Endpoint

Use the key secure string, Azure Cosmos DB account name, database and
Cosmos DB custom endpoint hostname:

```powershell
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -Key $primaryKey -EndpointHostname documents.eassov.com
```

#### Create a Context for a Cosmos DB Emulator

Microsoft provides a [Cosmos DB emulator](https://docs.microsoft.com/azure/cosmos-db/local-emulator) that
you can run locally to enable testing and debugging scenarios. To create
a context for a Cosmos DB emulator installed on the localhost use the
following command:

```powershell
$cosmosDbContext = New-CosmosDbContext -Emulator -Database MyDatabase
```

You can also provide a custom URI if the emulator is hosted on another
machine or an alternate port as well as specifying an alternate Key to use:

```powershell
$primaryKey = ConvertTo-SecureString -String 'GFJqJesi2Rq910E0G7P4WoZkzowzbj23Sm9DUWFX0l0P8o16mYyuaZBN00Nbtj9F1QQnumzZKSGZwknXGERrlA==' -AsPlainText -Force
$cosmosDbContext = New-CosmosDbContext -Emulator -Database MyDatabase -Uri https://cosmosdbemulator.contoso.com:9081 -Key $primaryKey
```

### Working with Accounts

You can create, retrieve, update and remove Azure Cosmos DB accounts using
this module. To use these features you will need to ensure the **Az.Profile**
and **Az.Resources** modules installed - See [Requirements](#requirements)
above.

> [!NOTE]
> You must have first logged PowerShell into Azure using the
> `Connect-AzAccount` function before you can use these functions.

Create a new Cosmos DB account in Azure:

```powershell
New-CosmosDbAccount -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup -Location WestUS
```

Get the properties of an existing Cosmos DB account in Azure:

```powershell
Get-CosmosDbAccount -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup
```

Get a Secure String containing the Primary Master Key for an
account in Azure:

```powershell
$key = Get-CosmosDbAccountMasterKey -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup
```

Get a Secure String containing the Secondary Readonly Master Key for an
account in Azure:

```powershell
$key = Get-CosmosDbAccountMasterKey -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup -MasterKeyType SecondaryReadonlyMasterKey
```

Regenerate the Primary Readonly Master Key for an account in Azure:

```powershell
New-CosmosDbAccountMasterKey -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup -MasterKeyType PrimaryReadonlyMasterKey
```

Get the connection strings used to connect to an existing Cosmos DB
account in Azure:

> [!NOTE]
> This function is not currently working due to an issue in the Microsoft/DocumentDB
> Provider. See [this issue](https://github.com/Azure/azure-powershell/issues/3650)
> for more information.

```powershell
Get-CosmosDbAccountConnectionString -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup
```

Update an existing Cosmos DB account in Azure:

```powershell
Set-CosmosDbAccount -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup -Location WestUS -DefaultConsistencyLevel Strong
```

Delete an existing Cosmos DB account in Azure:

```powershell
Remove-CosmosDbAccount -Name MyAzureCosmosDB -ResourceGroupName MyCosmosDbResourceGroup
```

### Working with Databases

Create a new database in the Cosmos DB account with database throughput
provisioned at 1200 RU/s:

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id MyDatabase -OfferThroughput 1200
```

Create a new database in the Cosmos DB account with autoscaling throughput
with a maximum of 40,000 RU/s down to a minimum of 4,000 RU/s:

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id MyDatabase -AutoscaleThroughput 40000
```

Create a new database in the Cosmos DB account that will have throughput
provisioned at the collection rather than the database:

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id DatabaseWithCollectionThroughput
```

Get a list of databases in the Cosmos DB account:

```powershell
Get-CosmosDbDatabase -Context $cosmosDbContext
```

Get the specified database from the Cosmos DB account:

```powershell
Get-CosmosDbDatabase -Context $cosmosDbContext -Id MyDatabase
```

### Working with Offers

Get a list of offers in the Cosmos DB account:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext
```

Query the offers in the Cosmos DB account:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext -Query 'SELECT * FROM root WHERE (root["id"] = "lyiu")'
```

Update an existing V2 offer to set a different throughput:

```powershell
Get-CosmosDbOffer -Context $cosmosDbContext -Id lyiu |
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

Create a collection in the database with the partition key 'id' and
the offer throughput of 50,000 RU/s:

```powershell
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -OfferThroughput 50000
```

Create a collection in the database with the partition key 'id' using
autoscaling with the maximum throughput of 40,000 RU/s and a minimum of
4,000 RU/s:

```powershell
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -AutoscaleThroughput 40000
```

Get a specified collection from a database:

```powershell
Get-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection
```

Get the first 5 collections from a database with a continuation token to
allow retrieval of further collections:

```powershell
$ResponseHeader = $null
$collections = Get-CosmosDbCollection -Context $cosmosDbContext -MaxItemCount 5 -ResponseHeader ([ref] $ResponseHeader)
$continuationToken = Get-CosmosDbContinuationToken -ResponseHeader $ResponseHeader
```

Get the next 5 collections from a database using a continuation token:

```powershell
$collections = Get-CosmosDbCollection -Context $cosmosDbContext -MaxItemCount 5 -ContinuationToken $continuationToken
```

Delete a collection from the database:

```powershell
Remove-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection
```

#### Creating a Collection with a custom Indexing Policy

You can create a collection with a custom indexing policy by assembling
an Indexing Policy object using the functions:

- `New-CosmosDbCollectionCompositeIndexElement`
- `New-CosmosDbCollectionIncludedPathIndex`
- `New-CosmosDbCollectionIncludedPath`
- `New-CosmosDbCollectionExcludedPath`
- `New-CosmosDbCollectionIndexingPolicy`

For example, to create a string range, a number range index and a point
spatial index on the '/*' path using consistent indexing mode with no
excluded paths:

```powershell
$indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String
$indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number
$indexPointSpatial = New-CosmosDbCollectionIncludedPathIndex -Kind Spatial -DataType Point
$indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $indexStringRange, $indexNumberRange, $indexPointSpatial
$indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -IndexingPolicy $indexingPolicy
```

> **Important Index Notes**
>
> The _Hash_ index Kind is no longer supported by Cosmos DB.
> A warning will be displayed if the Hash index Kind is used.
> The Hash index Kind will be removed in a future BREAKING release of the Cosmos
> DB module.
> See [this page](https://docs.microsoft.com/azure/cosmos-db/index-types#index-kind)
> for more information.
>
> The _Precision_ parameter is no longer supported by Cosmos DB and will be
> ignored. The maximum precision of -1 will always be used for Range indexes.
> A warning will be displayed if the Precision parameter is passed.
> The Precision parameter will be removed in a future BREAKING release of the
> Cosmos DB module.
> See [this page](https://docs.microsoft.com/azure/cosmos-db/index-types#index-precision)
> for more information.
>
> It is recommended to remove the use of the _Hash_ index Kind and any instances
> of the _Precision_ parameter and any automation or scripts to avoid being affected
> by future BREAKING CHANGES.

For more information on how Cosmos DB indexes documents, see [this page](https://docs.microsoft.com/azure/cosmos-db/indexing-policies).

#### Creating a Collection with a custom Indexing Policy including Composite Indexes

To create a custom indexing policy that automatically indexes all paths but
also includes two composite indexes, each consisting of two paths:

```powershell
$compositeIndex = @(
    @(
        (New-CosmosDbCollectionCompositeIndexElement -Path /name -Order Ascending ),
        (New-CosmosDbCollectionCompositeIndexElement -Path /age -Order Ascending )
    ),
    @(
        (New-CosmosDbCollectionCompositeIndexElement -Path /name -Order Ascending ),
        (New-CosmosDbCollectionCompositeIndexElement -Path /age -Order Descending )
    )
)
$indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*'
$indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath -CompositeIndex $compositeIndex
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -IndexingPolicy $indexingPolicy
```

#### Update an existing Collection with a new Indexing Policy

You can update an existing collection with a custom indexing policy by
assembling an Indexing Policy using the method in the previous section
and then applying it using the `Set-CosmosDbCollection` function:

```powershell
$indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String
$indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $indexStringRange
$indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath
Set-CosmosDbCollection -Context $cosmosDbContext -Id MyExistingCollection -IndexingPolicy $indexingPolicy
```

After updating a collection with an indexing policy it will take some
time to transform the index. To retrieve the progress of the index
transformation, call the `Get-CosmosDbCollection` function and then
evaluate the value of the

```powershell
PS C:\> $ResponseHeader = $null
PS C:\> $collections = Get-CosmosDbCollection -Context $cosmosDbContext -Id MyExistingCollection -ResponseHeader ([ref] $ResponseHeader)
PS C:\> $indexUpdateProgress = Get-CosmosDbResponseHeaderAttribute -ResponseHeader $ResponseHeader -HeaderName x-ms-documentdb-collection-index-transformation-progress
```

#### Creating a Collection with a custom Indexing Policy using JSON

If the `New-CosmosDbCollection*` functions don't enable you to build
the index policy to your requirements, you can also pass the raw index
policy JSON to the function using the `IndexingPolicyJson` parameter:

```powershell
$indexingPolicyJson = @'
{
    "automatic":true,
    "indexingMode":"Consistent",
    "includedPaths":[
        {
            "path":"/*"
        }
    ],
    "excludedPaths":[],
    "compositeIndexes":[
        [
            {
                "path":"/name",
                "order":"ascending"
            },
            {
                "path":"/age",
                "order":"descending"
            }
        ]
    ]
}
'@
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -IndexingPolicyJson $indexingPolicyJson
```

#### Creating a Collection with a custom Unique Key Policy

You can create a collection with a custom unique key policy by assembling
a Unique Key Policy object using the functions:

- `New-CosmosDbCollectionUniqueKey`
- `New-CosmosDbCollectionUniqueKeyPolicy`

For example, to create a unique key policy that contains two unique keys,
with the first unique key combining '/name' and '/address' and the second
unique key is set to '/email'.

```powershell
$uniqueKeyNameAddress = New-CosmosDbCollectionUniqueKey -Path /name, /address
$uniqueKeyEmail = New-CosmosDbCollectionUniqueKey -Path /email
$uniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $uniqueKeyNameAddress, $uniqueKeyEmail
New-CosmosDbCollection -Context $cosmosDbContext -Id MyNewCollection -PartitionKey id -UniqueKeyPolicy $uniqueKeyPolicy
```

For more information on how Cosmos DB indexes documents, see [this page](https://docs.microsoft.com/azure/cosmos-db/unique-keys).

#### Update an existing Collection with a new Unique Key Policy

You can update an existing collection with a custom unique key policy by
assembling a Unique Key Policy using the method in the previous section
and then applying it using the `Set-CosmosDbCollection` function:

```powershell
$uniqueKeyNameAddress = New-CosmosDbCollectionUniqueKey -Path /name, /address
$uniqueKeyEmail = New-CosmosDbCollectionUniqueKey -Path /email
$uniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $uniqueKeyNameAddress, $uniqueKeyEmail
Set-CosmosDbCollection -Context $cosmosDbContext -Id MyExistingCollection -IndexingPolicy $indexingPolicy
```

#### Creating a Collection without a Partition Key

> **Warning:** It is not recommended to create a collection without a partition
key. It may result in reduced performance and increased cost. This
functionality is included for backwards compatibility only.

It is only possible to create non-partitioned collection in a database that has
not got provisioned throughput at the database level enabled.

Create a collection in the database with the offer throughput of 2500 RU/s
and without a partition key:

```powershell
New-CosmosDbCollection -Context $cosmosDbContext -Id NonPartitionedCollection -OfferThroughput 2500
```

### Working with Documents

Create 10 new documents in a collection in the database using the `id` as
the partition key:

```powershell
0..9 | Foreach-Object {
    $id = $([Guid]::NewGuid().ToString())
    $document = @{
        id      = $id
        content = "Some string"
        more    = "Some other string"
    } | ConvertTo-Json
    New-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentBody $document -PartitionKey $id
}
```

Create a new document containing non-ASCII characters in a collection in the
database using the `id` as the partition key:

```powershell
$id = $([Guid]::NewGuid().ToString())
$document = @{
    id      = $id
    content = "杉本 司"
} | ConvertTo-Json
New-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentBody $document -Encoding 'UTF-8' -PartitionKey $id
```

Return a document with a specific Id from a collection in the database using
the document ID as the partition key:

```powershell
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -Id $documents[0].id -PartitionKey $documents[0].id
```

> [!NOTE]
> Because this is a partitioned collection, if you don't specify a partition
> key you will receive a `(400) Bad Request` exception.

Get the first 5 documents from the collection in the database:

```powershell
$ResponseHeader = $null
$documents = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -MaxItemCount 5 -ResponseHeader ([ref] $ResponseHeader)
$continuationToken = Get-CosmosDbContinuationToken -ResponseHeader $ResponseHeader
```

> [!NOTE]
> You don't need to specify the partition key here because you are just
> getting the first 5 documents in whatever order they are available so going to
> a specific partition is not required.

Get the next 5 documents from a collection in the database using
the continuation token found in the headers from the previous
request:

```powershell
$documents = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -MaxItemCount 5 -ContinuationToken $continuationToken
```

Replace the content of a document in a collection in the database:

```powershell
$newDocument = @{
    id      = $documents[0].id
    content = "New string"
    more    = "Another new string"
} | ConvertTo-Json
Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -Id $documents[0].id -DocumentBody $newDocument -PartitionKey $documents[0].id
```

Querying a collection in a database:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -Query $query
```

Querying a collection in a database using a parameterized query:

```powershell
$query = "SELECT * FROM customers c WHERE (c.id = @id)"
$queryParameters = @(
    @{
        name  = "@id"
        value = "user@contoso.com"
    }
)
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -Query $query -QueryParameters $queryParameters
```

Delete a document from a collection in the database:

```powershell
Remove-CosmosDbDocument -Context $cosmosDbContext -CollectionId MyNewCollection -Id $documents[0].id -PartitionKey $documents[0].id
```

> [!NOTE]
> Because this is a partitioned collection, if you don't specify a partition
> key you will receive a `(400) Bad Request` exception.

#### Using a While Loop to get all Documents in a Collection

The Cosmos DB REST APIs have a maximum response size of 4MB. Therefore, to
get a set of documents from a collection that will be larger than 4MB the
request will need to be broken down into blocks using continuation tokens.

The following is an example of how that could be implemented.

```powershell
$documentsPerRequest = 20
$continuationToken = $null
$documents = $null

do {
    $responseHeader = $null
    $getCosmosDbDocumentParameters = @{
        Context = $cosmosDbContext
        CollectionId = 'MyNewCollection'
        MaxItemCount = $documentsPerRequest
        ResponseHeader = ([ref] $responseHeader)
    }

    if ($continuationToken) {
        $getCosmosDbDocumentParameters.ContinuationToken = $continuationToken
    }

    $documents += Get-CosmosDbDocument @getCosmosDbDocumentParameters
    $continuationToken = Get-CosmosDbContinuationToken -ResponseHeader $responseHeader
} while (-not [System.String]::IsNullOrEmpty($continuationToken))
```

#### Working with Documents in a non-partitioned Collection

> **Warning:** It is not recommended to use a collection without a partition
key. It may result in reduced performance and increased cost. This
functionality is included for backwards compatibility only.
>
> Creating a document in a collection that has a Partition Key requires the
`PartitionKey` parameter to be specified for the document:

```powershell
$document = @{
    id      = "en-us"
    locale  = "English (US)"
} | ConvertTo-Json
New-CosmosDbDocument -Context $cosmosDbContext -CollectionId NonPartitionedCollection -DocumentBody $document
```

Get a document from a partitioned collection with a specific Id:

```powershell
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId NonPartitionedCollection -Id 'en-us'
```

Delete a document from a partitioned collection in the database:

```powershell
Remove-CosmosDbDocument -Context $cosmosDbContext -CollectionId NonPartitionedCollection -Id 'en-us'
```

### Working with Attachments

Create an attachment on a document in a collection:

```powershell
New-CosmosDbAttachment -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentId $documents[0].id -PartitionKey $documents[0].id -Id image_1 -ContentType 'image/jpg' -Media www.bing.com
```

Get _all_ attachments for a document in a collection:

```powershell
Get-CosmosDbAttachment -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentId $documents[0].id -PartitionKey $documents[0].id
```

Get an attachment by Id for a document in a collection:

```powershell
Get-CosmosDbAttachment -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentId $documents[0].id -PartitionKey $documents[0].id -Id image_1
```

Rename an attachment for a document in a collection:

```powershell
Set-CosmosDbAttachment -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentId $documents[0].id -PartitionKey $documents[0].id -Id image_1 -NewId image_2
```

Delete an attachment from a document in collection:

```powershell
Remove-CosmosDbAttachment -Context $cosmosDbContext -CollectionId MyNewCollection -DocumentId $documents[0].id -PartitionKey $documents[0].id -Id image_2
```

### Working with Users

Get a list of users in the database:

```powershell
Get-CosmosDbUser -Context $cosmosDbContext
```

Create a user in the database:

```powershell
New-CosmosDbUser -Context $cosmosDbContext -Id dscottraynsford@contoso.com
```

Delete a user from the database:

```powershell
Remove-CosmosDbUser -Context $cosmosDbContext -Id dscottraynsford@contoso.com
```

### Working with Permissions

Get a list of permissions for a user in the database:

```powershell
Get-CosmosDbPermission -Context $cosmosDbContext -UserId dscottraynsford@contoso.com
```

Create a permission for a user in the database with read access to a collection:

```powershell
$collectionId = Get-CosmosDbCollectionResourcePath -Database MyDatabase -Id MyNewCollection
New-CosmosDbPermission -Context $cosmosDbContext -UserId dscottraynsford@contoso.com -Id r_mynewcollection -Resource $collectionId -PermissionMode Read
```

Remove a permission for a user from the database:

```powershell
Remove-CosmosDbPermission -Context $cosmosDbContext -UserId dscottraynsford@contoso.com -Id r_mynewcollection
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

> [!NOTE]
> By default, Resource Authorization Tokens expire after an hour.
> This can be extended to a maximum of 5 hours or reduced to minimum of 10
> minutes. Use the `TokenExpiry` parameter to control the length of time
> that the resource authorization tokens will be valid for.

The typical pattern for using _resource authorization tokens_ is to
have a **token broker app** that provides some form of user authentication
and then returns the _resource authorization tokens_ assigned to that
user. This removes the requirement for the user to be given access to
the **master** key for the Cosmos DB database.

For more information on using _resource authorization tokens_ or the
**token broker app** pattern, please see [this document](https://docs.microsoft.com/azure/cosmos-db/secure-access-to-data#resource-tokens).

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
$collectionId = Get-CosmosDbCollectionResourcePath -Database MyDatabase -Id MyNewCollection
$permission = Get-CosmosDbPermission -Context $cosmosDbContext -UserId dscottraynsford@contoso.com -Id r_mynewcollection -Resource $collectionId -TokenExpiry 7200
# Future features planned to make creation of a resource context token from a permission easier
$tokenParams = @{
    Resource    = $collectionId
    TimeStamp   = $permission[0].Timestamp
    TokenExpiry = 7200
    Token       = (ConvertTo-SecureString -String $permission[0].Token -AsPlainText -Force)
}
$contextToken = New-CosmosDbContextToken @tokenParams
$resourceParams = @{
    Account     = $cosmosDBContext.Account
    Database    = MyDatabase
    Token       = $contextToken
}
$resourceContext = New-CosmosDbContext @resourceParams
Get-CosmosDbCollection -Context $resourceContext -Id MyNewCollection
```

### Working with Triggers

Get a list of triggers for a collection in the database:

```powershell
Get-CosmosDbTrigger -Context $cosmosDbContext -CollectionId MyNewCollection
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
New-CosmosDbTrigger -Context $cosmosDbContext -CollectionId MyNewCollection -Id MyTrigger -TriggerBody $body -TriggerOperation All -TriggerType Post
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
Set-CosmosDbTrigger -Context $cosmosDbContext -CollectionId MyNewCollection -Id MyTrigger -Body $body -TriggerOperation All -TriggerType Pre
```

Remove a trigger for a collection from the database:

```powershell
Remove-CosmosDbTrigger -Context $cosmosDbContext -CollectionId MyNewCollection -Id MyTrigger
```

### Working with Stored Procedures

Get a list of stored procedures for a collection in the database:

```powershell
Get-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId MyNewCollection
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
New-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId MyNewCollection -Id spHelloWorld -StoredProcedureBody $body
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
Set-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId MyNewCollection -Id spHelloWorld -StoredProcedureBody $body
```

Execute a stored procedure for a collection from the database:

```powershell
Invoke-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId MyNewCollection -Id spHelloWorld -StoredProcedureParameters @('PowerShell')
```

Remove a stored procedure for a collection from the database:

```powershell
Remove-CosmosDbStoredProcedure -Context $cosmosDbContext -CollectionId MyNewCollection -Id spHelloWorld
```

### Working with User Defined Functions

Get a list of user defined functions for a collection in the database:

```powershell
Get-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId MyNewCollection
```

Create a user defined function for a collection in the database:

```powershell
$body = @'
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
New-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId MyNewCollection -Id udfTax -UserDefinedFunctionBody $body
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
Set-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId MyNewCollection -Id udfTax -Body $body
```

Remove a user defined function for a collection from the database:

```powershell
Remove-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId MyNewCollection -Id udfTax
```

### How to Handle Exceeding Provisioned Throughput

When using Azure Cosmos DB it is quite common to exceed the throughput
that has been provisioned against a collection (or across multiple collections).
See [this page](https://docs.microsoft.com/azure/cosmos-db/request-units)
for more information on request units and throughput provisioning.

When this happens requests will return a `Too Many Request` (error code 429).
Usually just waiting a small amount of time and trying again will result in the
request succeeding. However, the Cosmos DB PowerShell module provides a mechanism
for configuring an automatic back-off and retry policy.

This is configured within the Context object that is usually passed to each
Cosmos DB module function.

To configure a Back-off Policy, use the `New-CosmosDbBackoffPolicy` function:

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 5
$cosmosDbContext = New-CosmosDbContext -Account MyAzureCosmosDB -Database MyDatabase -Key $primaryKey -BackoffPolicy $backoffPolicy
```

This will cause any functions that use the Context to automatically retry up to
5 times if a 429 response code is returned. Any other type of response code will
throw an exception. The number of milliseconds to delay before retrying will be
determined automatically by using the `x-ms-retry-after-ms` header returned by
Cosmos DB.

Additional Back-off Policy options can be set to override or extend the value
returned in the `x-ms-retry-after-ms` header.

> [!NOTE]
> If the delay calculated by the policy is less than the value returned in
> the `x-ms-retry-after-ms` header, then the `x-ms-retry-after-ms` value will always
> be used.

The available Back-off Methods are:

- Default
- Additive
- Linear
- Exponential
- Random

The following show examples of alternative policy back-off types that can
implemented:

#### Default

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 10 -Method Default -Delay 100
```

The delay of 100ms will always be used unless it is less than `x-ms-retry-after-ms`.
The delay can be set to 0 and will cause the  `x-ms-retry-after-ms` to always be
used. It is the default Back-off Policy behavior.

#### Additive

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 10 -Method Additive -Delay 1000
```

This will create a policy that will retry 10 times with a delay equaling the
value of the returned `x-ms-retry-after-ms` header plus 1000ms.

#### Linear

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 3 -Method Linear -Delay 500
```

This will create a policy that will wait for 500ms on the first retry, 1000ms on
the second retry, 1500ms on final retry.

#### Exponential

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 4 -Method Exponential -Delay 1000
```

This will create a policy that will wait for 1000ms on the first retry, 4000ms on
the second retry, 9000ms on the 3rd retry and 16000ms on the final retry.

#### Random

```powershell
$backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 3 -Method Random -Delay 1000
```

A policy that adds or subtracts up to 50% of the delay period to the base delay
each time can also be applied. For example, the first delay might be 850ms, with
the second delay being 1424ms and final delay being 983ms.

## Compatibility and Testing

This PowerShell module is automatically tested and validated to run
on the following systems:

- Windows Server (using Windows PowerShell 5.1):
  - Windows Server 2019: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Windows Server 2022: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Windows Server 2025: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
- Windows Server (using Windows PowerShell 7.x):
  - Windows Server 2019: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Windows Server 2022: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Windows Server 2025: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
- Linux (using PowerShell 7.x):
  - Ubuntu 20.04: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Ubuntu 22.04: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - Ubuntu 24.04: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
- macOS (using PowerShell 7.x):
  - macOS 13: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - macOS 14: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).
  - macOS 15: Using [Azure Pipelines](https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4).

> This module is no longer tested on PowerShell Core 6.x as PowerShell 7.x
> should be used. It should still work, but will no longer be verified. Issues with
> this module that only exist on PowerShell Core 6.x but not PowerShell 7.x will
> not be fixed.

This module should function correctly on other systems and configurations
but is not automatically tested with them in every change.

## Contributing

If you wish to contribute to this project, please read the [Contributing.md](/.github/CONTRIBUTING.md)
document first. We would be very grateful of any contributions.

## Cmdlets

A list of Cmdlets in the _CosmosDB PowerShell module_ can be found by running the
following PowerShell commands:

```PowerShell
Import-Module -Name CosmosDB
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

[ap-image-main]: https://dev.azure.com/dscottraynsford/GitHub/_apis/build/status/PlagueHO.CosmosDB.main?branchName=main
[ap-site-main]: https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=4&_a=summary
[ts-image-main]: https://img.shields.io/azure-devops/tests/dscottraynsford/GitHub/4/main
[ts-site-main]: https://dev.azure.com/dscottraynsford/GitHub/_build/latest?definitionId=4&branchName=main
[cq-image-main]: https://api.codacy.com/project/badge/Grade/1ee50b5eb15b47c188b3bdf7a5f8ee1d
[cq-site-main]: https://www.codacy.com/app/PlagueHO/CosmosDB?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=PlagueHO/CosmosDB&amp;utm_campaign=Badge_Grade
