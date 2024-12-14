---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollection

## SYNOPSIS

Create a new collection in a Cosmos DB database.

## SYNTAX

### ContextIndexPolicy (Default)

```powershell
New-CosmosDbCollection -Context <Context> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -Id <String> [-OfferThroughput <Int32>] [-OfferType <String>]
 [-PartitionKey <String>] [-IndexingPolicy <Policy>] [-DefaultTimeToLive <Int32>]
 [-UniqueKeyPolicy <Policy>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

### ContextIndexPolicyJson

```powershell
New-CosmosDbCollection -Context <Context> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -Id <String> [-OfferThroughput <Int32>] [-OfferType <String>]
 [-PartitionKey <String>] [-IndexingPolicyJson <String>] [-DefaultTimeToLive <Int32>]
 [-UniqueKeyPolicy <Policy>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

### AccountIndexPolicyJson

```powershell
New-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -Id <String> [-OfferThroughput <Int32>] [-OfferType <String>]
 [-PartitionKey <String>] [-IndexingPolicyJson <String>] [-DefaultTimeToLive <Int32>]
 [-UniqueKeyPolicy <Policy>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

### AccountIndexPolicy

```powershell
New-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -Id <String> [-OfferThroughput <Int32>] [-OfferType <String>]
 [-PartitionKey <String>] [-IndexingPolicy <Policy>] [-DefaultTimeToLive <Int32>]
 [-UniqueKeyPolicy <Policy>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a collection in a Cosmos DB.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -OfferThroughput 2500
```

Create a collection in the database with the offer throughput of 2500 RU/s.

### Example 2

```powershell
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'PartitionedCollection' -PartitionKey 'account' -OfferThroughput 50000
```

Create a collection in the database with the partition key 'account' and
the offer throughput of 50,000 RU/s.

### Example 3

```powershell
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'PartitionedCollection' -DefaultTimeToLive 3600
```

Create a collection in the database with the a default time to live of 3600
seconds.

### Example 4

```powershell
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'PartitionedCollection' -PartitionKey 'account' -AutoscaleThroughput 50000
```

Create a collection in the database with the partition key 'account' and
an maximum throughput of 50,000 RU/s, autoscaling down to a minimum of
5,000 RU/s.

## PARAMETERS

### -Account

The account name of the Cosmos DB to access.

```yaml
Type: String
Parameter Sets: AccountIndexPolicyJson, AccountIndexPolicy
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
Parameter Sets: ContextIndexPolicy, ContextIndexPolicyJson
Aliases: Connection

Required: True
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

### -DefaultTimeToLive

Setting this value to a positive integer will enable the
time to live on all documents in this collection. If this is
set to -1 then the default time to live will be infinite.

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

### -Id

This is the Id of the collection to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexingPolicy

This is an Indexing Policy object that was created by the
New-CosmosDbCollectionIndexingPolicy function. It should not
be set if IndexingPolicyJson is set.

```yaml
Type: Policy
Parameter Sets: ContextIndexPolicy, AccountIndexPolicy
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexingPolicyJson

This is a JSON representation of an Indexing Policy. It should not
be set if IndexingPolicy is set.

```yaml
Type: String
Parameter Sets: ContextIndexPolicyJson, AccountIndexPolicyJson
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

### -OfferThroughput

The user specified throughput for the collection expressed
in units of 100 request units per second.
This can be between 400 and 250,000 (or higher by requesting a limit increase).
If specified OfferType should not be specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OfferType

The user specified performance level for pre-defined performance
levels S1, S2 and S3.
This is a legacy parameter and is only supported for backwards compatibility and
may be removed in future. It is recommended to use 'OfferThroughput' or
'AutopilotThroughput' instead.
If specified OfferThroughput or AutoscaleThroughput should not be specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: S1, S2, S3

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionKey

This value is used to configure the partition keys to be used
for partitioning data into multiple partitions.

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

### -UniqueKeyPolicy

This is a Unique Key Policy object that was created by the
New-CosmosDbCollectionUniquePolicy function.

```yaml
Type: Policy
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoscaleThroughput

The user specified autoscale throughput for the database expressed in RU/s.
This can be between 1000 and 1,000,000 and should be specified in increments
of 100 RU/s.
This parameter can not be specified in OfferThroughput or OfferType is specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: AutopilotThroughput

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
