---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbDatabase

## SYNOPSIS

Create a new database in a Cosmos DB account.

## SYNTAX

### Context (Default)

```powershell
New-CosmosDbDatabase -Context <Context> [-Key <SecureString>] [-KeyType <String>] -Id <String>
 [-OfferThroughput <Int32>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

### Account

```powershell
New-CosmosDbDatabase -Account <String> [-Key <SecureString>] [-KeyType <String>] -Id <String>
 [-OfferThroughput <Int32>] [-AutoscaleThroughput <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a database in Cosmos DB.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-CosmosDbDatabase -Context $cosmosDbContext -Id 'AnotherDatabase'
```

Create a new database in the Cosmos DB account.

### Example 2

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id 'DatabaseWithOffer' -OfferThroughput 1200
```

Create a new database in the Cosmos DB account with a
custom offer throughput of 1200 RU/s.

### Example 3

```powershell
New-CosmosDbDatabase -Context $cosmosDbContext -Id 'DatabaseWithOffer' -AutoscaleThroughput 40000
```

Create a new database in the Cosmos DB account using autoscale provisioned
throughput of 40,000 RU/s.

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

### -Id

This is the Id of the database to create.

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

The user specified throughput for the database expressed in RU/s.
This can be between 400 and 100,000 and should be specified in increments
of 100 RU/s.
If not specified the offer throughput will be set to 400 RU/s.
This parameter can not be specified in AutoscaleThroughput is specified.

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

### -AutoscaleThroughput

The user specified autoscale throughput for the database expressed in RU/s.
This can be between 4000 and 1,000,000 and should be specified in increments
of 100 RU/s.
This parameter can not be specified in OfferThroughput is specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: AutopilotThroughput, AutoscaleMaxThroughput, AutopilotMaxThroughput

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see
about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
