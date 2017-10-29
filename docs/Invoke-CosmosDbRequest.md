---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Invoke-CosmosDbRequest

## SYNOPSIS
Create a new Authorization Token to be used with in a
Rest API request to CosmosDB.

## SYNTAX

### Connection (Default)
```
Invoke-CosmosDbRequest -Connection <PSObject> [-Method <String>] -ResourceType <String>
 [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
```

### Account
```
Invoke-CosmosDbRequest -Account <String> -Database <String> -Key <SecureString> [-KeyType <String>]
 [-Method <String>] -ResourceType <String> [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
```

## DESCRIPTION
{{Fill in the Description}}

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

### -Method
This is the Rest API method that will be made to the CosmosDB.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Get
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceType
This is type of resource being accessed in the CosmosDB.
For example: users, colls

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

### -ResourcePath
This is the path to the resource that should be accessed in
the CosmosDB.
This will be appended to the path after the
resourceId in the URI that will be used to access the resource.

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

### -Body
This is the body of the request that will be submitted if the
method is 'Put', 'Post' or 'Patch'.

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

### -ApiVersion
This is the version of the Rest API that will be called.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 2017-02-22
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

