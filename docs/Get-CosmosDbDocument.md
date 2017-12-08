---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Get-CosmosDbDocument

## SYNOPSIS
Return the documents for a CosmosDB database collection.

## SYNTAX

### Connection (Default)
```
Get-CosmosDbDocument -Connection <PSObject> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -CollectionId <String> [-Id <String>] [-MaxItemCount <Int32>] [-ContinuationToken <String>]
 [-ConsistencyLevel <String>] [-SessionToken <String>] [-PartitionKeyRangeId <String>] [-Query <String>]
 [-QueryParameters <Hashtable[]>] [-QueryEnableCrossPartition <Boolean>] [<CommonParameters>]
```

### Account
```
Get-CosmosDbDocument -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -CollectionId <String> [-Id <String>] [-MaxItemCount <Int32>] [-ContinuationToken <String>]
 [-ConsistencyLevel <String>] [-SessionToken <String>] [-PartitionKeyRangeId <String>] [-Query <String>]
 [-QueryParameters <Hashtable[]>] [-QueryEnableCrossPartition <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will return the documents for a specified
collection in a CosmosDB database.
If an Id is specified then only
the specified documents will be returned.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Connection
This is an object containing the connection information of
the CosmosDB database that will be accessed.
It should be created
by \`New-CosmosDbConnection\`.

```yaml
Type: PSObject
Parameter Sets: Connection
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Account
The account name of the CosmosDB to access.

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

### -Key
The key to be used to access this CosmosDB.

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
The type of key that will be used to access ths CosmosDB.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
The name of the database to access in the CosmosDB account.

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

### -MaxItemCount
An integer indicating the maximum number of items to be
returned per page.
Should not be set if Id is set.

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

### -ContinuationToken
A string token returned for queries and read-feed operations
if there are more results to be read.
Should not be set if
Id is set.

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

### -ConsistencyLevel
This is the consistency level override.
The override must
be the same or weaker than the accountâ€™s configured consistency
level.
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

### -SessionToken
A string token used with session level consistency.
Clients
must echo the latest read value of this header during read
requests for session consistency.
Should not be set if Id is
set.

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

### -PartitionKeyRangeId
The partition key range Id for reading data.
Should not be set
if Id is set.

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
This
should not be specified if Id is specified.

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

### -QueryParameters
This is an array of key value pairs (Name, Value) that will be
passed into the SQL Query.
This should only be specified if
Query is specified.

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

### -QueryEnableCrossPartition
If the collection is partitioned, this must be set to True to
allow execution across multiple partitions.
This should only
be specified if Query is specified.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

