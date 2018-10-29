---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbCollection

## SYNOPSIS

Update an existing collection in a Cosmos DB database.

## SYNTAX

### Context (Default)

```powershell
Set-CosmosDbCollection -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -Id <String> [-IndexingPolicy <CosmosDB.IndexingPolicy.Policy>] [-DefaultTimeToLive <Int32>]
 [-RemoveDefaultTimeToLive <Switch>] [-UniqueKeyPolicy <CosmosDB.UniqueKeyPolicy.Policy>] [<CommonParameters>]
```

### Account

```powershell
Set-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -Id <String> [-IndexingPolicy <CosmosDB.IndexingPolicy.Policy>] [-DefaultTimeToLive <Int32>]
 [-RemoveDefaultTimeToLive <Switch>] [-UniqueKeyPolicy <CosmosDB.UniqueKeyPolicy.Policy>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will update an existing collection in a Cosmos DB.
Only the indexing policy on a collection can be updated.

## EXAMPLES

### Example 1

```powershell
PS C:\> $indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String -Precision -1
PS C:\> $indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
PS C:\> $indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $indexStringRange, $indexNumberRange
PS C:\> $newIndexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath
PS C:\> Set-CosmosDbCollection -Context $cosmosDbContext -Id 'MyExistingCollection' -IndexingPolicy $newIndexingPolicy
```

Update a collection in the database with the a new indexing policy.

### Example 2

```powershell
PS C:\> Set-CosmosDbCollection -Context $cosmosDbContext -Id 'MyExistingCollection' -DefaultTimeToLive 7200
```

Update a collection in the database with the a new default time to live
of 7200 seconds.

### Example 3

```powershell
PS C:\> Set-CosmosDbCollection -Context $cosmosDbContext -Id 'MyExistingCollection' -RemoveDefaultTimeToLive
```

Update a collection in the database by removing the default time to live
setting.

## PARAMETERS

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

Required: False
Position: Named
Default value: Master
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

This is the Id of the collection to update.

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

### -IndexingPolicy

This is an Indexing Policy object that was created by the
Set-CosmosDbCollectionIndexingPolicy function.

```yaml
Type: CosmosDB.IndexingPolicy.Policy
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

### -RemoveDefaultTimeToLive

If this switch is set then the default time to live
setting on the collection will be removed if it is set.
This switch should not be set if the DefaultTimeToLive
parameter is specified.

```yaml
Type: Switch
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
Type: CosmosDB.UniqueKeyPolicy.Policy
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
