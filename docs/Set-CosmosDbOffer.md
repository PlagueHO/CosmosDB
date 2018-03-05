---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbOffer

## SYNOPSIS
Update an existing offer in a CosmosDB database.

## SYNTAX

### Context (Default)
```
Set-CosmosDbOffer -Context <Context> [-Database <String>] [-Key <SecureString>] -InputObject <Object[]>
 [-OfferVersion <String>] [-OfferType <String>] [-OfferThroughput <Int32>]
 [-OfferIsRUPerMinuteThroughputEnabled <Boolean>] [<CommonParameters>]
```

### Account
```
Set-CosmosDbOffer -Account <String> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 -InputObject <Object[]> [-OfferVersion <String>] [-OfferType <String>] [-OfferThroughput <Int32>]
 [-OfferIsRUPerMinuteThroughputEnabled <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will update an offer resource in CosmosDB.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Context
This is an object containing the context information of
the CosmosDB database that will be deleted.
It should be created
by \`New-CosmosDbContext\`.

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

### -Database
{{Fill Database Description}}

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
Parameter Sets: Account
Aliases:

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
{{Fill InputObject Description}}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OfferVersion
This can be V1 for pre-defined throughput levels and V2 for user-defined
throughput levels.

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

### -OfferType
This is a user settable property, which must be set to S1, S2, or S3 for
pre-defined performance levels, and Invalid for user-defined performance
levels.

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

### -OfferThroughput
This contains the throughput of the collection.
Applicable for V2 offers
only.

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

### -OfferIsRUPerMinuteThroughputEnabled
The offer is RU per minute throughput enabled.
Applicable for V2 offers
only.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
