---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbTransactionalBatch

## SYNOPSIS

Execute a transactional batch operation against a collection in a Cosmos DB database.

## SYNTAX

```powershell
New-CosmosDbTransactionalBatch -Context <Context> -PartitionKey <String> 
 -CollectionId <String> -Documents <Object[]> [-OperationType <String>] 
 [-NoAtomic <switch>] [-ReturnJson <switch>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will execute a transactional batch operation against a collection in
a Cosmos DB database.

All operations in the batch will target documents within the same partition key.

## EXAMPLES

### Example 1: Create multiple documents atomically

```powershell
PS C:\> $documents = @(
    @{ id = 'doc1'; name = 'Alice'; customerId = 'test' },
    @{ id = 'doc2'; name = 'Bob'; customerId = 'test' }
)
PS C:\> New-CosmosDbTransactionalBatch `
    -Context $context `
    -PartitionKey 'test' `
    -CollectionId 'Customers' `
    -Documents $documents `
    -OperationType 'Create'
```

### Example 2: Upsert documents with atomic behavior disabled

```powershell
PS C:\> $documents = @(
    @{ id = 'doc1'; name = 'Alice Updated'; customerId = 'test' },
    @{ id = 'doc2'; name = 'Bob Updated'; customerId = 'test' }
)
PS C:\> New-CosmosDbTransactionalBatch `
    -Context $context `
    -PartitionKey 'test' `
    -CollectionId 'Customers' `
    -Documents $documents `
    -OperationType 'Upsert' `
    -NoAtomic
```

### Example 3: Return raw JSON response

```powershell
PS C:\> $result = New-CosmosDbTransactionalBatch `
    -Context $context `
    -PartitionKey 'test' `
    -CollectionId `
    'Customers' `
    -Documents $documents `
    -ReturnJson
PS C:\> $result | ConvertFrom-Json
```

## PARAMETERS

### -Context

This is an object containing the context information of the Cosmos DB database
that will be accessed for the transactional batch operation.

It should be created by `New-CosmosDbContext`.

```yaml
Type: Context
Parameter Sets: (All)
Aliases: Connection

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionKey

This is the partition key value for all documents in the batch.

All documents must belong to the same partition.

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

### -CollectionId

This is the Id of the collection to execute the batch operation against.

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

### -Documents

An array of documents to include in the batch operation.

Each document will be processed using the specified OperationType.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperationType

The type of operation to perform on each document in the batch.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Create, Upsert, Read, Replace, Delete

Required: False
Position: Named
Default value: Create
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoAtomic

Determines whether the batch operation should not be atomic.

If set, individual operations can succeed or fail independently.

If not set, either all operations succeed or all are rolled back.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnJson

Return the raw JSON response from Cosmos DB instead of parsed objects.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object[]

Returns an array of batch operation results, one for each document in the batch.

## NOTES

- All documents in a batch must belong to the same partition key.
- Maximum of 100 operations per batch.

## RELATED LINKS
