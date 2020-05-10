---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Invoke-CosmosDbRequest

## SYNOPSIS

Execute a new request to a Cosmos DB REST endpoint.

## SYNTAX

### Context (Default)

```powershell
Invoke-CosmosDbRequest -Context <Context> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 [-Method <String>] -ResourceType <String> [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
 [-Headers <Hashtable>] [-ContentType <String>] [-Encoding <String>] [<CommonParameters>]
```

### Account

```powershell
Invoke-CosmosDbRequest -Account <String> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 [-Method <String>] -ResourceType <String> [-ResourcePath <String>] [-Body <String>] [-ApiVersion <String>]
 [-Headers <Hashtable>] [-ContentType <String>] [-Encoding <String>] [<CommonParameters>]
```

## DESCRIPTION

Invokes a REST request against the specified Cosmos DB
context or account.

## EXAMPLES

### Example 1

```powershell
PS C:\> $result = Invoke-CosmosDbRequest -Context $context -ResourceType 'colls' -ResourcePath 'dbs/mydatabase'
```

Execute a request to the Cosmos DB specified by the context
$context to Get the collections in the database mydatabase.

### Example 2

```powershell
PS C:\> $result = Invoke-CosmosDbRequest -Context $context -ResourceType 'docs' -ResourcePath 'dbs/mydatabase/colls/mycollection/docs/ac12345' -Method 'Put' -Body $body
```

Execute a request to the Cosmos DB specified by the context
$context to Put document 'ac12345' into collection mycollection
in database mydatabase.

## PARAMETERS

### -Context

This is an object containing the context information of the Cosmos DB database
that will be deleted. It should be created by \`New-CosmosDbContext\`.

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

The account name of the Cosmos DB to access.

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

The key to be used to access this Cosmos DB.

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

The type of key that will be used to access ths Cosmos DB.

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

This is the Rest API method that will be made to the Cosmos DB.

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

This is type of resource being accessed in the Cosmos DB.
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
the Cosmos DB.
This will be appended to the path after the resourceId in the URI
that will be used to access the resource.

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
Default value: 2018-09-17
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

### -Encoding

This parameter allows the Encoding to be set in the ContentType of the
request to allow other encoding formats. Currently only UTF-8 is supported.
If this parameter is not specified the default encoding is used.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
