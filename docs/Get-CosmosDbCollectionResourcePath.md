---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbCollectionResourcePath

## SYNOPSIS

Return the resource path for a collection object.

## SYNTAX

```powershell
Get-CosmosDbCollectionResourcePath [-Database] <String> [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns the resource identifier for a collection
object.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
```

Generate a resource path for collection 'MyNewCollection' in database 'MyDatabase'.

## PARAMETERS

### -Database

This is the database containing the collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

This is the Id of the collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
