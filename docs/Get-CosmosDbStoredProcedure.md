---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Get-CosmosDbStoredProcedure

## SYNOPSIS
Return the stored procedures for a CosmosDB database collection.

## SYNTAX

### Connection (Default)
```
Get-CosmosDbStoredProcedure -Connection <PSObject> [-Key <SecureString>] [-KeyType <String>]
 [-Database <String>] -CollectionId <String> [-Id <String>]
```

### Account
```
Get-CosmosDbStoredProcedure -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -CollectionId <String> [-Id <String>]
```

## DESCRIPTION
This cmdlet will return the stored procedures for a specified
collection in a CosmosDB database.
If an Id is specified then only
the specified stored procedures will be returned.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Connection
This is an object containing the connection information of
the CosmosDB database that will be accessed.
It should be created
by \`New-CosmosDbConnection\`.

```yaml
Type: PSObject
Parameter Sets: Connection
Aliases: 

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
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Master
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
This is the id of the collection to get the stored procedure for.

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
This is the id of the stored procedures to return.

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

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

