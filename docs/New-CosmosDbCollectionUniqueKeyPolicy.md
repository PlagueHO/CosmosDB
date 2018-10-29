---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionUniqueKeyPolicy

## SYNOPSIS

Creates a unique key policy object that can be passed to the
New-CosmosDbCollection function.

## SYNTAX

```powershell
New-CosmosDbCollectionUniqueKeyPolicy [-UniqueKey] <CosmosDB.UniqueKeyPolicy.UniqueKey[]> [<CommonParameters>]
```

## DESCRIPTION

This function will return an unique key policy object that can
be passed to the New-CosmosDbCollection function to configure
custom unique key policies on a collection.

## EXAMPLES

### Example 1

```powershell
PS C:\> $uniqueKeyNameAddress = New-CosmosDbCollectionUniqueKey -Path '/name', '/address'
PS C:\> $uniqueKeyEmail = New-CosmosDbCollectionUniqueKey -Path '/email'
PS C:\> $uniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $uniqueKeyNameAddress, $uniqueKeyEmail
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -PartitionKey 'account' -UniqueKeyPolicy $uniqueKeyPolicy
```

Create a new collection with a custom unique key policy with two unique
keys. The first unique key combines '/name' and '/address' and the second
unique key is set to '/email'.

## PARAMETERS

### -UniqueKey

The array containing unique keys that will be enforced in the policy.
The New-CosmosDbCollectionUniqueKey function should be used to generate the unique key.

```yaml
Type: CosmosDB.UniqueKeyPolicy.UniqueKey[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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

### CosmosDB.UniqueKeyPolicy.Policy

## NOTES

## RELATED LINKS
