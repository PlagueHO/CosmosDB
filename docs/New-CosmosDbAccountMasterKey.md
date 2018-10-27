---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbAccountMasterKey

## SYNOPSIS

This will regenerate a specific master key for an existing Cosmos DB account
in Azure.

## SYNTAX

```powershell
New-CosmosDbAccountMasterKey -Name <String> -ResourceGroupName <String> [-MasterKeyType <String>]
 [<CommonParameters>]
```

## DESCRIPTION

You should change the access keys to your Azure Cosmos DB account periodically to help keep
your connections more secure. Two access keys are assigned to enable you to maintain connections
to the Azure Cosmos DB account using one access key while you regenerate the other access key.

This function will enable you to regenerate the master keys.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-CosmosDbAccountMasterKey -Name 'MyCosmosDBAccount' -ResourceGroupName 'MyResourceGroup'
```

Regenerate the Primary Master Key for the 'MyCosmosDBAccount' in the resource group
'MyResourceGroup'.

### Example 2

```powershell
PS C:\> Get-CosmosDbAccountMasterKey -Name 'MyCosmosDBAccount' -ResourceGroupName 'MyResourceGroup' -MasterKeyType 'SecondaryReadonlyMasterKey'
```

Regenerate the Secondary Readonly Master Key for the 'MyCosmosDBAccount' in the resource group
'MyResourceGroup'.

## PARAMETERS

### -MasterKeyType

The master key type to regenerate.

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
