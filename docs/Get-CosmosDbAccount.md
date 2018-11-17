---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbAccount

## SYNOPSIS

Get the properties of a Cosmos DB account in Azure.

## SYNTAX

```
Get-CosmosDbAccount [-Name] <String> [-ResourceGroupName] <String> [<CommonParameters>]
```

## DESCRIPTION

This will return the properties of an existing Cosmos DB
account in Azure.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbAccount -Name 'MyCosmosDBAccount' -ResourceGroupName 'MyResourceGroup'
```

Return the properties of a Cosmos DB account named 'MyCosmosDBAccount' in
the resource group 'MyResourceGroup'.

## PARAMETERS

### -Name

The name of the Cosmos DB account to return the properties for.

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

### -ResourceGroupName

The resource group containing the Cosmos DB account.

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

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
