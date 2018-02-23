---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Invoke-CosmosDbStoredProcedure

## SYNOPSIS
Execute a new stored procedure for a collection in a CosmosDB database.

## SYNTAX

### Context (Default)
```
Invoke-CosmosDbStoredProcedure -Context <Context> [-KeyType <String>] [-Key <SecureString>]
 [-Database <String>] -CollectionId <String> -Id <String> [-StoredProcedureParameter <String[]>]
 [<CommonParameters>]
```

### Account
```
Invoke-CosmosDbStoredProcedure -Account <String> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -CollectionId <String> -Id <String> [-StoredProcedureParameter <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will execute a stored procedure contained in a collection
in a CosmosDB.

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

### -KeyType
The type of key that will be used to access ths CosmosDB.

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

### -Database
The name of the database to access in the CosmosDB account.

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

### -CollectionId
This is the Id of the collection that contains the stored procedure
to execute.

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

### -Id
This is the Id of the stored procedure to execute.

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

### -StoredProcedureParameter
{{Fill StoredProcedureParameter Description}}

```yaml
Type: String[]
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
