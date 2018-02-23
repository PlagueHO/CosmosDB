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

### Context (Default)
```
Invoke-CosmosDbRequest -Context <Context> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 [-Method <String>] -ResourceType <String> [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
 [-Headers <Hashtable>] [-UseWebRequest] [-ContentType <String>] [<CommonParameters>]
```

### Account
```
Invoke-CosmosDbRequest -Account <String> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 [-Method <String>] -ResourceType <String> [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
 [-Headers <Hashtable>] [-UseWebRequest] [-ContentType <String>] [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Context
This is an object containing the context information of
the CosmosDB database that will be accessed.
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

### -Database
If specified will override the value in the context.
If an empty database is specified then no dbs will be specified
in the Rest API URI which will allow working with database
objects.

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

### -Headers
This parameter can be used to provide any additional headers
to the Rest API.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseWebRequest
This parameter forces the request to be made using
the Invoke-WebRequest cmdlet and to return the object that
it returns.
This will enable extraction of the headers
from the result, which is required for some requests.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentType
This parameter allows the ContentType to be overridden
which can be required for some types of requests.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Application/json
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
