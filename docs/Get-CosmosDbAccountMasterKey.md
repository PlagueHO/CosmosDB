---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbAccountMasterKey

## SYNOPSIS

Get a master key for a Cosmos DB account in Azure.

## SYNTAX

```powershell
Get-CosmosDbAccountMasterKey -Name <String> -ResourceGroupName <String> [-MasterKeyType <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This will return a specific master key for an existing Cosmos DB account
in Azure.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbAccountMasterKey -Name 'MyCosmosDBAccount' -ResourceGroupName 'MyResourceGroup'
```

Retrun the Primary Master Key for the 'MyCosmosDBAccount' in the resource group
'MyResourceGroup'.

### Example 2

```powershell
PS C:\> Get-CosmosDbAccountMasterKey -Name 'MyCosmosDBAccount' -ResourceGroupName 'MyResourceGroup' -MasterKeyType 'SecondaryReadonlyMasterKey'
```

Retrun the Secondary Readonly Master Key for the 'MyCosmosDBAccount' in the resource group
'MyResourceGroup'.

## PARAMETERS

### -MasterKeyType

The type of Master Key to return.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: PrimaryMasterKey, SecondaryMasterKey, PrimaryReadonlyMasterKey, SecondaryReadonlyMasterKey

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the Cosmos DB account to return the connection strings for.

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

### -ResourceGroupName

The resource group containing the Cosmos DB account.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Security.SecureString

## NOTES

## RELATED LINKS
