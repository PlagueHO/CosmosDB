---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# New-CosmosDbConnection

## SYNOPSIS
Create a connection object containing the information required
to connect to a CosmosDB.

## SYNTAX

```
New-CosmosDbConnection [-Account] <String> [-Database] <String> [-Key] <SecureString> [[-KeyType] <String>]
```

## DESCRIPTION
This cmdlet is used to simplify the calling of the CosmosDB
cmdlets by providing all the connection information in an
object that can be passed to the CosmosDB cmdlets.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Account
The account name of the CosmosDB to access.

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

### -Database
The name of the database to access in the CosmosDB account.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
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

Required: True
Position: 3
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
Position: 4
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

