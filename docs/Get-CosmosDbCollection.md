---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbCollection

## SYNOPSIS

Return the collections in a Cosmos DB database.

## SYNTAX

### Context (Default)

```powershell
Get-CosmosDbCollection -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [-MaxItemCount <Int32>] [-ContinuationToken <String>] [-ResultHeaders <PSReference>]
 [<CommonParameters>]
```

### Account

```powershell
Get-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [-MaxItemCount <Int32>] [-ContinuationToken <String>] [-ResultHeaders <PSReference>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will return the collections in a Cosmos DB database.
If the Id is specified then only the collection matching this
Id will be returned, otherwise all collections will be returned.

A maxiumum of 100 collections will be returned if an Id is not
specified. To retrieve more than 100 collections a continuation
token will need to be used.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbCollection -Context $cosmosDbContext
```

Gets a list of collections in a database.

### Example 2

```powershell
PS C:\> Get-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection'
```

Get a the MyNewCollection collection from a database.

### Example 3

```powershell
PS C:\> $resultHeaders = $null
PS C:\> $collections = Get-CosmosDbCollection -Context $cosmosDbContext -MaxItemCount 5 -ResultHeaders ([ref] $resultHeaders)
PS C:\> $continuationToken = $resultHeaders.'x-ms-continuation'
```

Get the first 5 collection from the the database storing a continuation
token that can be used to retrieve further blocks of collections.

### Example 4

```powershell
PS C:\> $collections = Get-CosmosDbCollection -Context $cosmosDbContext -MaxItemCount 5 -ContinuationToken $continuationToken
```

Get the next 5 collections in the database using the continuation token found
in the headers from the previous example.

## PARAMETERS

### -Account

The account name of the Cosmos DB to access.

```yaml
Type: String
Parameter Sets: Account
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Context

This is an object containing the context information of the Cosmos DB database
that will be deleted. It should be created by \`New-CosmosDbContext\`.

```yaml
Type: Context
Parameter Sets: Context
Aliases: Connection

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContinuationToken

A string token returned for queries and read-feed operations
if there are more results to be read.
Should not be set if Id is set.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database

The name of the database to access in the Cosmos DB account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

This is the id of the collection to get.
If not specified
all collections in the database will be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key

The key to be used to access this Cosmos DB.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyType

The type of key that will be used to access ths Cosmos DB.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: master, resource

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxItemCount

An integer indicating the maximum number of items to be
returned per page. Should not be set if Id is set.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResultHeaders

This is a reference variable that will be used to return the
hashtable that contains any headers returned by the request.

```yaml
Type: PSReference
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
