---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbDocumentJson

## SYNOPSIS

Return documents from a Cosmos DB database collection as a JSON string.

## SYNTAX

### Context (Default)

```powershell
Get-CosmosDbDocumentJson -Context <Context> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -CollectionId <String> [-Id <String>]
 [-PartitionKey <Object[]>] [-MaxItemCount <Int32>] [-ContinuationToken <String>]
 [-ConsistencyLevel <String>] [-SessionToken <String>]
 [-PartitionKeyRangeId <String>] [-Query <String>] [-QueryParameters <Hashtable[]>]
 [-QueryEnableCrossPartition <Boolean>] [-ResponseHeader <PSReference>] [<CommonParameters>]
```

### Account

```powershell
Get-CosmosDbDocumentJson -Account <String> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -CollectionId <String> [-Id <String>]
 [-PartitionKey <Object[]>] [-MaxItemCount <Int32>] [-ContinuationToken <String>]
 [-ConsistencyLevel <String>] [-SessionToken <String>]
 [-PartitionKeyRangeId <String>] [-Query <String>] [-QueryParameters <Hashtable[]>]
 [-QueryEnableCrossPartition <Boolean>] [-ResponseHeader <PSReference>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will return the documents for a specified collection in a
Cosmos DB database. If an Id is specified then only the specified
documents will be returned.

A maximum of 100 document will be returned if an Id is not
specified. To retrieve more than 100 documents a continuation
token will need to be used.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbDocumentJson -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'ac12345'
```

Return a document with a Id 'ac12345' from a collection in the database.

### Example 2

```powershell
PS C:\> $ResponseHeader = $null
PS C:\> $documents = Get-CosmosDbDocumentJson -Context $cosmosDbContext -CollectionId 'MyNewCollection' -MaxItemCount 5 -ResponseHeader ([ref] $ResponseHeader)
PS C:\> $continuationToken = Get-CosmosDbContinuationToken -ResponseHeader $ResponseHeader
```

Get the first 5 documents from the collection in the database
storing a continuation token.

### Example 3

```powershell
PS C:\> $documents = Get-CosmosDbDocumentJson -Context $cosmosDbContext -CollectionId 'MyNewCollection' -MaxItemCount 5 -ContinuationToken $continuationToken
```

Get the next 5 documents from a collection in the database using the
continuation token found in the headers from the previous example.

### Example 4

```powershell
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> Get-CosmosDbDocumentJson -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Query $query
```

Query the documents in a collection.

### Example 5

```powershell
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = @id)"
PS C:\> $queryParameters = @(
    @{ name = "@id"; value="user@contoso.com"; }
)
PS C:\> Get-CosmosDbDocumentJson -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Query $query -QueryParameters $queryParameters
```

Query the documents in a collection using a parameterized query.

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

### -CollectionId

This is the id of the collection to get the documents for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConsistencyLevel

This is the consistency level override.
The override must be the same or weaker than the account's
configured consistency level.
Should not be set if Id is set.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Strong, Bounded, Session, Eventual

Required: False
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

This is the id of the document to return.

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
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionKey

The partition key value(s) for the document to be read.
Must be included if and only if the collection is created
with a partitionKey definition.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionKeyRangeId

The partition key range Id for reading data.
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

### -Query

A SQL select query to execute to select the documents.
This should not be specified if Id is specified.

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

### -QueryEnableCrossPartition

If the collection is partitioned, this must be set to True to
allow execution across multiple partitions.
This should only be specified if Query is specified.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -QueryParameters

This is an array of key value pairs (Name, Value) that will be
passed into the SQL Query.
This should only be specified if Query is specified.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResponseHeader

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

### -SessionToken

A string token used with session level consistency.
Clients must echo the latest read value of this header during
read requests for session consistency.
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
