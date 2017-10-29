---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Get-CosmosDbUser

## SYNOPSIS
Return the users in a CosmosDB database.

## SYNTAX

### Connection (Default)
```
Get-CosmosDbUser -Connection <PSObject> [-Id <String>]
```

### Account
```
Get-CosmosDbUser -Account <String> -Database <String> -Key <SecureString> [-KeyType <String>] [-Id <String>]
```

## DESCRIPTION
This cmdlet will return the users in a CosmosDB database.
If the Id is specified then only the user matching this
Id will be returned, otherwise all users will be returned.

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

### -Database
The name of the database to access in the CosmosDB account.

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
Parameter Sets: Account
Aliases: 

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
This is the id of the collection to get.
If not specified
all collections in the database will be returned.

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

