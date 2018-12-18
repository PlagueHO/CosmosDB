[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"
$TestHelperPath = "$PSScriptRoot\..\TestHelper"

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name $TestHelperPath -Force

Get-AzureServicePrincipal

if ([String]::IsNullOrEmpty($env:azureSubscriptionId) -or `
        [String]::IsNullOrEmpty($env:azureApplicationId) -or `
        [String]::IsNullOrEmpty($env:azureApplicationPassword) -or `
        [String]::IsNullOrEmpty($env:azureTenantId))
{
    Write-Warning -Message 'Integration tests can not be run because one or more Azure connection environment variables are not set.'
    return
}

# Variables for use in tests
$script:testRandomName = [System.IO.Path]::GetRandomFileName() -replace '\.', ''
$buildSystem = $ENV:BHBuildSystem
if (-not $buildSystem)
{
    $buildSystem = 'local'
}
$script:testResourceGroupName = ('cdbtestrgp-{0}-{1}-{2}' -f $script:testRandomName,$buildSystem.Replace(' ',''),$ENV:BHBranchName)
$script:testAccountName = ('cdbtest{0}' -f $script:testRandomName)
$script:testLocation = 'East US'
$script:testOffer = 'testOffer'
$script:testDatabase = 'testDatabase'
$script:testDatabase2 = 'testDatabase2'
$script:testCollection = 'testCollection'
$script:testUser = 'testUser'
$script:testCollectionPermission = 'testCollectionPermission'
$script:testDocumentPermission = 'testDocumentPermission'
$script:testPartitionKey = 'id'
$script:testDocumentId = [Guid]::NewGuid().ToString()
$script:testDocumentBody = @"
{
    `"id`": `"$script:testDocumentId`",
    `"content`": `"Some string`",
    `"more`": `"Some other string`",
    `"uniquekey`": `"$([Guid]::NewGuid().ToString())`"
}
"@
$script:testDocumentUTF8Id = [Guid]::NewGuid().ToString()
$script:testDocumentUTF8Content = "我能吞下玻璃而不伤身"
$script:testDocumentUTF8Body = @"
{
    `"id`": `"$script:testDocumentUTF8Id`",
    `"content`": `"$script:testDocumentUTF8Content`"
}
"@
$script:testDocumentUTF8UpdateContent = "我能吞下玻璃而不伤身"
$script:testDocumentUTF8UpdateBody = @"
{
    `"id`": `"$script:testDocumentUTF8Id`",
    `"content`": `"$script:testDocumentUTF8UpdateContent`"
}
"@
$script:testAttachmentId = 'testAttachment'
$script:testAttachmentContentType = 'image/jpg'
$script:testAttachmentMedia = 'www.bing.com'
$script:testStoredProcedureId = 'testStoredProcedure'
$script:testStoredProcedureBody = @'
function () {
    var context = getContext();
    var response = context.getResponse();

    response.setBody("Hello, World");
}
'@
$script:testTriggerId = 'testTrigger'
$script:testTriggerBody = @'
function updateMetadata() {
    var context = getContext();
    var collection = context.getCollection();
    var response = context.getResponse();
    var createdDocument = response.getBody();

    // query for metadata document
    var filterQuery = 'SELECT * FROM root r WHERE r.id = "_metadata"';
    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery, updateMetadataCallback);
    if(!accept) throw "Unable to update metadata, abort";

    function updateMetadataCallback(err, documents, responseOptions) {
        if(err) throw new Error("Error" + err.message);

        if(documents.length != 1) throw 'Unable to find metadata document';
        var metadataDocument = documents[0];

        // update metadata
        metadataDocument.createdDocuments += 1;
        metadataDocument.createdNames += " " + createdDocument.id;

        var accept = collection.replaceDocument(metadataDocument._self, metadataDocument, function(err, docReplaced) {
            if(err) throw "Unable to update metadata, abort";
        });

        if(!accept) throw "Unable to update metadata, abort";
        return;
    }
}
'@
$script:testUserDefinedFunctionId = 'testUserDefinedFunction'
$script:testUserDefinedFunctionBody = @'
function tax(income) {
    if(income == undefined) throw 'no input';
    if (income < 1000)
        return income * 0.1;
    else if (income < 10000)
        return income * 0.2;
    else
        return income * 0.4;
}
'@
$script:testDefaultTimeToLive = 3600

# Connect to Azure
$secureStringAzureApplicationPassword = ConvertTo-SecureString `
    -String $env:azureApplicationPassword `
    -AsPlainText `
    -Force

Connect-AzureServicePrincipal `
    -SubscriptionId $env:azureSubscriptionId `
    -ApplicationId $env:azureApplicationId `
    -ApplicationPassword $secureStringAzureApplicationPassword `
    -TenantId $env:azureTenantId `
    -Verbose

# Create resource group
$null = New-AzureTestCosmosDbResourceGroup `
    -ResourceGroupName $script:testResourceGroupName `
    -Location $script:testLocation `
    -Verbose

$currentIpAddress = (Invoke-RestMethod -Uri 'http://ipinfo.io/json').ip

Describe 'Cosmos DB Module' -Tag 'Integration' {
    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        Write-Warning -Message (@(
            'New-AzureRmResource, Set-AzureRmResource and some Invoke-AzureRmResourceAction calls currently throws the following exception in AppVeyor:'
            'Method not found: ''Void Newtonsoft.Json.Serialization.JsonDictionaryContract.set_PropertyNameResolver(System.Func`2<System.String,System.String>)'''
            'due to an older version of Newtonsoft.Json being used.'
            'Therefore integration tests of New-CosmosDbAccount and Set-CosmosDbAccount are currently skipped when running in AppVeyor environment.'
        ) -join "`n`r")

        # Create Azure CosmosDB Account to use for testing
        New-AzureTestCosmosDbAccount `
            -ResourceGroupName $script:testResourceGroupName `
            -AccountName $script:testAccountName `
            -Verbose
    }

    Context 'When creating a new Azure Cosmos DB Account' {
        It 'Should not throw an exception' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            New-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'BoundedStaleness' `
                -MaxIntervalInSeconds 50 `
                -MaxStalenessPrefix 50 `
                -Verbose
        }
    }

    Context 'When getting the new Azure Cosmos DB Account' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Name | Should -Be $script:testAccountName
            $script:result.ResourceGroupName | Should -Be $script:testResourceGroupName
            $script:result.Location | Should -Be $script:testLocation
            $script:result.Properties.ProvisioningState | Should -Be 'Succeeded'
            $script:result.Properties.consistencyPolicy.defaultConsistencyLevel | Should -Be 'BoundedStaleness'
            $script:result.Properties.consistencyPolicy.maxIntervalInSeconds | Should -Be 50
            $script:result.Properties.consistencyPolicy.maxStalenessPrefix | Should -Be 50
            $script:result.Properties.ipRangeFilter | Should -BeNullOrEmpty
        }
    }

    Context 'When updating the new Azure Cosmos DB Account' {
        It 'Should not throw an exception' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            $script:result = Set-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'Session' `
                -IpRangeFilter "$currentIpAddress/32" `
                -Verbose
        }
    }

    Context 'When getting the new Azure Cosmos DB Account' {
        It 'Should not throw an exception' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            $script:result = Get-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Verbose
        }

        It 'Should return expected object' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            $script:result.Name | Should -Be $script:testAccountName
            $script:result.ResourceGroupName | Should -Be $script:testResourceGroupName
            $script:result.Location | Should -Be $script:testLocation
            $script:result.Properties.ProvisioningState | Should -Be 'Succeeded'
            $script:result.Properties.consistencyPolicy.defaultConsistencyLevel | Should -Be 'Session'
            $script:result.Properties.consistencyPolicy.maxIntervalInSeconds | Should -Be 5
            $script:result.Properties.consistencyPolicy.maxStalenessPrefix | Should -Be 100
            $script:result.Properties.ipRangeFilter | Should -Be "$currentIpAddress/32"
        }
    }

    Context 'When updating the new Azure Cosmos DB Account to remove IP Range filter' {
        It 'Should not throw an exception' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            $script:result = Set-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'Session' `
                -IpRangeFilter '' `
                -Verbose
        }
    }

    Context 'When getting the new Azure Cosmos DB Account Connection Strings' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccountConnectionString `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Verbose
        }

        It 'Should return expected object' {
            # Currently returns an empty string due to a bug in the Provider
        }
    }

    Context 'When getting the new Azure Cosmos DB Account Primary Master Key' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccountMasterKey `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'PrimaryMasterKey' `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result | Should -BeOfType [SecureString]
        }
    }

    Context 'When getting the new Azure Cosmos DB Account Primary Readonly Master Key' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccountMasterKey `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'PrimaryReadonlyMasterKey' `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result | Should -BeOfType [SecureString]
        }
    }

    Context 'When regenerating the new Azure Cosmos DB Account Primary Master Key' {
        It 'Should not throw an exception' -Skip:($ENV:BHBuildSystem -eq 'AppVeyor') {
            $script:result = New-CosmosDbAccountMasterKey `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'PrimaryMasterKey' `
                -Verbose
        }
    }

    Context 'When creating a new context from Azure using the PrimaryMasterKey Key' {
        It 'Should not throw an exception' {
            $script:testContext = New-CosmosDbContext `
                -Account $script:testAccountName `
                -Database $script:testDatabase `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'PrimaryMasterKey'
        }
    }

    Context 'When creating a new context from Azure using the PrimaryReadonlyMasterKey Key' {
        It 'Should not throw an exception' {
            $script:testReadOnlyContext = New-CosmosDbContext `
                -Account $script:testAccountName `
                -Database $script:testDatabase `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'PrimaryReadonlyMasterKey'
        }
    }

    Context 'When creating a new database using a readonly context' {
        It 'Should throw an exception' {
            {
                $script:result = New-CosmosDbDatabase `
                    -Context $script:testReadOnlyContext `
                    -Id $script:testDatabase `
                    -Verbose
            } | Should -Throw
        }
    }

    Context 'When creating a new database' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase
        }
    }

    Context 'When getting existing database' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase
        }
    }

    Context 'When getting existing database using readonly context' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDatabase -Context $script:testReadOnlyContext -Id $script:testDatabase -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase
        }
    }

    Context 'When creating second new database' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase2 -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase2
        }
    }

    Context 'When getting all existing databases' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDatabase -Context $script:testContext -Verbose
        }

        It 'Should return expected object' {
            $script:result.Count | Should -Be 2
        }
    }

    Context 'When removing second database' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase2 -Verbose
        }
    }

    Context 'When adding a user to a database' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbUser `
                -Context $script:testContext `
                -Id $script:testUser `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUser
            $script:result.Permissions | Should -Be 'permissions/'
        }
    }

    Context 'When getting the user from a database' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbUser `
                -Context $script:testContext `
                -Id $script:testUser `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUser
            $script:result.Permissions | Should -Be 'permissions/'
        }
    }

    Context 'When creating a new simple indexing policy' {
        It 'Should not throw an exception' {
            $script:indexingPolicySimple = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent
        }
    }

    Context 'When creating a new collection with a simple IndexingPolicy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicySimple `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
        }
    }

    Context 'When removing existing collection with a simple indexing policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new indexing policy' {
        It 'Should not throw an exception' {
            $script:indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
            $script:indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Hash -DataType String -Precision 3
            $script:indexSpatialPoint = New-CosmosDbCollectionIncludedPathIndex -Kind Spatial -DataType Point
            $script:indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $script:indexNumberRange, $script:indexStringRange, $script:indexSpatialPoint
            $script:indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $script:indexIncludedPath
        }
    }

    Context 'When creating a new unique key policy' {
        It 'Should not throw an exception' {
            $script:uniqueKey = New-CosmosDbCollectionUniqueKey -Path '/uniquekey'
            $script:uniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $script:uniqueKey
        }
    }

    Context 'When creating a new collection with an IndexingPolicy and UniqueKeyPolicy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicy `
                -UniqueKeyPolicy $script:uniqueKeyPolicy `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
            $script:result.uniqueKeyPolicy.uniqueKeys[0].paths[0] | Should -Be '/uniquekey'
        }
    }

    Context 'When getting existing collection with an IndexingPolicy and UniqueKeyPolicy' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
            $script:result.uniqueKeyPolicy.uniqueKeys[0].paths[0] | Should -Be '/uniquekey'
        }
    }

    Context 'When updating an existing collection with an IndexingPolicy and UniqueKeyPolicy' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -IndexingPolicy $script:indexingPolicy `
                -UniqueKeyPolicy $script:uniqueKeyPolicy `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
            $script:result.uniqueKeyPolicy.uniqueKeys[0].paths[0] | Should -Be '/uniquekey'
        }
    }

    Context 'When adding a read collection permission for a user' {
        It 'Should not throw an exception' {
            $script:collectionResourcePath = Get-CosmosDbCollectionResourcePath `
                -Database $script:testDatabase `
                -Id $script:testCollection
            $script:result = New-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testCollectionPermission `
                -Resource $script:collectionResourcePath `
                -PermissionMode Read `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollectionPermission
            $script:result.permissionMode | Should -Be 'Read'
            $script:result.resource | Should -Be $script:collectionResourcePath
            $script:result.Token | Should -BeOfType [System.String]
        }
    }

    Context 'When getting the read collection permission for the user' {
        It 'Should not throw an exception' {
            $script:collectionResourcePath = Get-CosmosDbCollectionResourcePath `
                -Database $script:testDatabase `
                -Id $script:testCollection
            $script:result = Get-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testCollectionPermission `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollectionPermission
            $script:result.permissionMode | Should -Be 'Read'
            $script:result.resource | Should -Be $script:collectionResourcePath
            $script:result.Token | Should -BeOfType [System.String]
        }
    }

    Context 'When getting existing collection using resource token for user permission as context' {
        It 'Should not throw an exception' {
            $script:collectionResourcePath = Get-CosmosDbCollectionResourcePath `
                -Database $script:testDatabase `
                -Id $script:testCollection `
                -Verbose
            $permission = Get-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testCollectionPermission `
                -Verbose
            $contextToken = New-CosmosDbContextToken `
                -Resource $script:collectionResourcePath `
                -TimeStamp $permission[0].Timestamp `
                -Token (ConvertTo-SecureString -String $permission[0].Token -AsPlainText -Force) `
                -Verbose
            $resourceContext = New-CosmosDbContext `
                -Account $script:testAccountName `
                -Database $script:testDatabase `
                -Token $contextToken `
                -Verbose
            $script:result = Get-CosmosDbCollection `
                -Context $resourceContext `
                -Id $script:testCollection `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
        }
    }

    Context 'When getting existing offers' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 400
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
        }
    }

    Context 'When updating existing offer throughput' {
        It 'Should not throw an exception' {
            $script:result = `
                Get-CosmosDbOffer -Context $script:testContext -Verbose |
                Set-CosmosDbOffer -Context $script:testContext -OfferThroughput 800 -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 800
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
        }
    }

    Context 'When adding a document to a collection' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentBody $script:testDocumentBody `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentId
            $script:result.Content | Should -Be 'Some string'
            $script:result.More | Should -Be 'Some other string'
        }
    }

    Context 'When adding an attachment to the document in a collection' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbAttachment `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentId $script:testDocumentId `
                -Id $script:testAttachmentId `
                -ContentType $script:testAttachmentContentType `
                -Media $script:testAttachmentMedia `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testAttachmentId
            $script:result.ContentType | Should -Be $script:testAttachmentContentType
            $script:result.Media | Should -Be $script:testAttachmentMedia
        }
    }

    Context 'When getting an attachment from the document in a collection' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAttachment `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentId $script:testDocumentId `
                -Id $script:testAttachmentId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testAttachmentId
            $script:result.ContentType | Should -Be $script:testAttachmentContentType
            $script:result.Media | Should -Be $script:testAttachmentMedia
        }
    }

    Context 'When adding a read document permission for a user' {
        It 'Should not throw an exception' {
            $script:documentResourcePath = Get-CosmosDbDocumentResourcePath `
                -Database $script:testDatabase `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId
            $script:result = New-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testDocumentPermission `
                -Resource $script:documentResourcePath `
                -PermissionMode Read `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentPermission
            $script:result.permissionMode | Should -Be 'Read'
            $script:result.resource | Should -Be $script:documentResourcePath
            $script:result.Token | Should -BeOfType [System.String]
        }
    }

    Context 'When getting the read document permission for the user' {
        It 'Should not throw an exception' {
            $script:documentResourcePath = Get-CosmosDbDocumentResourcePath `
                -Database $script:testDatabase `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId
            $script:result = Get-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testDocumentPermission `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentPermission
            $script:result.permissionMode | Should -Be 'Read'
            $script:result.resource | Should -Be $script:documentResourcePath
            $script:result.Token | Should -BeOfType [System.String]
        }
    }

    Context 'When getting existing document using resource token for user permission as context' {
        It 'Should not throw an exception' {
            $script:documentResourcePath = Get-CosmosDbDocumentResourcePath `
                -Database $script:testDatabase `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId
            $permission = Get-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testDocumentPermission `
                -Verbose
            $contextToken = New-CosmosDbContextToken `
                -Resource $script:documentResourcePath `
                -TimeStamp $permission[0].Timestamp `
                -Token (ConvertTo-SecureString -String $permission[0].Token -AsPlainText -Force) `
                -Verbose
            $resourceContext = New-CosmosDbContext `
                -Account $script:testAccountName `
                -Database $script:testDatabase `
                -Token $contextToken `
                -Verbose
            $script:result = Get-CosmosDbDocument `
                -Context $resourceContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId `
                -Verbose
        }
    }

    Context 'When adding a stored procedure to the collection' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbStoredProcedure `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testStoredProcedureId `
                -StoredProcedureBody $script:testStoredProcedureBody `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testStoredProcedureId
        }
    }

    Context 'When getting the stored procedure from the collection' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbStoredProcedure `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testStoredProcedureId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testStoredProcedureId
        }
    }

    Context 'When removing the stored procedure from the collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbStoredProcedure `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testStoredProcedureId `
                -Verbose
        }
    }

    foreach ($operation in 'All', 'Create', 'Replace', 'Delete')
    {
        Context "When adding a $operation trigger to the collection" {
            It 'Should not throw an exception' {
                $script:result = New-CosmosDbTrigger `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testTriggerId `
                    -TriggerBody $script:testTriggerBody `
                    -TriggerOperation $operation `
                    -TriggerType 'Pre' `
                    -Verbose
            }

            It 'Should return expected object' {
                $script:result.Timestamp | Should -BeOfType [System.DateTime]
                $script:result.Etag | Should -BeOfType [System.String]
                $script:result.ResourceId | Should -BeOfType [System.String]
                $script:result.Uri | Should -BeOfType [System.String]
                $script:result.Id | Should -Be $script:testTriggerId
                $script:result.TriggerOperation | Should -Be $operation
                $script:result.TriggerType | Should -Be 'Pre'
            }
        }

        Context "When getting the $operation trigger from the collection" {
            It 'Should not throw an exception' {
                $script:result = Get-CosmosDbTrigger `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testTriggerId `
                    -Verbose
            }

            It 'Should return expected object' {
                $script:result.Timestamp | Should -BeOfType [System.DateTime]
                $script:result.Etag | Should -BeOfType [System.String]
                $script:result.ResourceId | Should -BeOfType [System.String]
                $script:result.Uri | Should -BeOfType [System.String]
                $script:result.Id | Should -Be $script:testTriggerId
                $script:result.TriggerOperation | Should -Be $operation
                $script:result.TriggerType | Should -Be 'Pre'
            }
        }

        Context "When removing the $operation trigger from the collection" {
            It 'Should not throw an exception' {
                $script:result = Remove-CosmosDbTrigger `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testTriggerId `
                    -Verbose
            }
        }
    }

    Context 'When adding a user defined function to the collection' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbUserDefinedFunction `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testUserDefinedFunctionId `
                -UserDefinedFunctionBody $script:testUserDefinedFunctionBody `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUserDefinedFunctionId
        }
    }

    Context 'When getting the user defined function from the collection' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbUserDefinedFunction `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testUserDefinedFunctionId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUserDefinedFunctionId
        }
    }

    Context 'When removing the user defined function from the collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbUserDefinedFunction `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testUserDefinedFunctionId `
                -Verbose
        }
    }

    Context 'When removing the existing read collection permission for the user' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbPermission `
                -Context $script:testContext `
                -UserId $script:testUser `
                -Id $script:testCollectionPermission `
                -Verbose
        }
    }

    Context 'When removing an attachment from the document in a collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbAttachment `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentId $script:testDocumentId `
                -Id $script:testAttachmentId `
                -Verbose
        }
    }

    Context 'When removing a document from a collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId `
                -Verbose
        }
    }

    Context 'When adding a UTF-8 document to a collection' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentBody $script:testDocumentUTF8Body `
                -Encoding 'UTF-8' `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
        }
    }

    Context 'When getting newly created UTF-8 document from a collection by using the Id' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentUTF8Id `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
        }
    }

    Context 'When updating an existing UTF-8 document to a collection' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentUTF8Id `
                -DocumentBody $script:testDocumentUTF8UpdateBody `
                -Encoding 'UTF-8' `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
        }
    }

    Context 'When getting updated UTF-8 document from a collection by using the Id' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentUTF8Id `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
        }
    }

    Context 'When removing a existing UTF-8 document from a collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentUTF8Id `
                -Verbose
        }
    }

    Context 'When removing existing collection with an IndexingPolicy and UniqueKeyPolicy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new collection with a partition key' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -PartitionKey $script:testPartitionKey `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.partitionKey.kind | Should -Be 'Hash'
            $script:result.partitionKey.paths[0] | Should -Be ('/{0}' -f $script:testPartitionKey)
        }
    }

    Context 'When adding a document to a collection with a partition key' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -DocumentBody $script:testDocumentBody `
                -PartitionKey $script:testDocumentId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentId
            $script:result.Content | Should -Be 'Some string'
            $script:result.More | Should -Be 'Some other string'
        }
    }

    Context 'When getting the document in a collection by using the Id with a partition key' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Id $script:testDocumentId `
                -PartitionKey $script:testDocumentId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentId
            $script:result.Content | Should -Be 'Some string'
            $script:result.More | Should -Be 'Some other string'
        }
    }

    Context 'When getting all the documents in a collection with a partition key' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -PartitionKey $script:testDocumentId `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Attachments | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDocumentId
            $script:result.Content | Should -Be 'Some string'
            $script:result.More | Should -Be 'Some other string'
        }
    }

    Context 'When removing existing collection with a partition key' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When removing existing user' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbUser -Context $script:testContext -Id $script:testUser -Verbose
        }
    }

    Context 'When creating a new collection with IndexingMode set to None' {
        It 'Should not throw an exception' {
            $script:indexingPolicyNone = New-CosmosDbCollectionIndexingPolicy -Automatic $false -IndexingMode None

            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicyNone `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'None'
            $script:result.indexingPolicy.automatic | Should -Be $false
        }
    }

    Context 'When removing existing collection with a None indexing Policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context "When creating a new collection with a DefaultTimeToLive set to $($script:testDefaultTimeToLive)" {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -DefaultTimeToLive $script:testDefaultTimeToLive `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.defaultTtl | Should -Be $script:testDefaultTimeToLive
        }
    }

    Context "When updating an existing collection changing the DefaultTimeToLive to $($script:testDefaultTimeToLive + 1)" {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -DefaultTimeToLive ($script:testDefaultTimeToLive + 1) `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.defaultTtl | Should -Be ($script:testDefaultTimeToLive + 1)
        }
    }

    Context "When updating an existing collection removing the DefaultTimeToLive" {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -RemoveDefaultTimeToLive `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.defaultTtl | Should -BeNullOrEmpty
        }
    }

    Context "When updating an existing collection changing the DefaultTimeToLive set to $($script:testDefaultTimeToLive + 2) and IndexingPolicy" {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -IndexingPolicy $script:indexingPolicy `
                -DefaultTimeToLive ($script:testDefaultTimeToLive + 2) `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
            $script:result.defaultTtl | Should -Be ($script:testDefaultTimeToLive + 2)
        }
    }

    Context 'When updating an existing collection changing nothing' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Conflicts | Should -BeOfType [System.String]
            $script:result.Documents | Should -BeOfType [System.String]
            $script:result.StoredProcedures | Should -BeOfType [System.String]
            $script:result.Triggers | Should -BeOfType [System.String]
            $script:result.UserDefinedFunctions | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollection
            $script:result.indexingPolicy.indexingMode | Should -Be 'Consistent'
            $script:result.indexingPolicy.automatic | Should -Be $true
            $script:result.indexingPolicy.includedPaths.Indexes[0].DataType | Should -Be 'Number'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Kind | Should -Be 'Range'
            $script:result.indexingPolicy.includedPaths.Indexes[0].Precision | Should -Be -1
            $script:result.indexingPolicy.includedPaths.Indexes[1].DataType | Should -Be 'String'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Kind | Should -Be 'Hash'
            $script:result.indexingPolicy.includedPaths.Indexes[1].Precision | Should -Be 3
            $script:result.indexingPolicy.includedPaths.Indexes[2].DataType | Should -Be 'Point'
            $script:result.indexingPolicy.includedPaths.Indexes[2].Kind | Should -Be 'Spatial'
            $script:result.defaultTtl | Should -Be ($script:testDefaultTimeToLive + 2)
        }
    }

    Context 'When removing existing collection' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    # Test retrieval of collections using maximum item count and continuation token
    Context 'When creating two new collections' {
        It 'Should not throw an exception' {
            $null = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id "$($script:testCollection)1" `
                -Verbose

            $null = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id "$($script:testCollection)2" `
                -Verbose
        }
    }

    $script:ResponseHeader = $null

    Context 'When getting collections using a maximum item count of 1' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbCollection `
                -Context $script:testContext `
                -MaxItemCount 1 `
                -ResponseHeader ([ref] $script:ResponseHeader) `
                -Verbose
        }

        It 'Should return expected object' {
            <#
                The order of the collections will be returned in is non-deterministic.
                Make sure we got one of them.
            #>
            $script:result.Id | Should -BeIn @("$($script:testCollection)1", "$($script:testCollection)2")
        }

        It 'Should have a continuation token in headers' {
            $script:ResponseHeader.'x-ms-continuation' | Should -Not -BeNullOrEmpty
        }

    }

    Context 'When getting collections using a maximum item count of 1 and a continuation token' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbCollection `
                -Context $script:testContext `
                -MaxItemCount 1 `
                -ContinuationToken ([String] $script:ResponseHeader.'x-ms-continuation') `
                -Verbose
        }

        It 'Should return expected object' {
            <#
                The order of the collections will be returned in is non-deterministic.
                Make sure we got one of them.
            #>
            $script:result.Id | Should -BeIn @("$($script:testCollection)1", "$($script:testCollection)2")
        }
    }

    Context 'When removing the two new collections' {
        It 'Should not throw an exception' {
            Remove-CosmosDbCollection `
                -Context $script:testContext `
                -Id "$($script:testCollection)1" `
                -Verbose

            Remove-CosmosDbCollection `
                -Context $script:testContext `
                -Id "$($script:testCollection)2" `
                -Verbose
        }
    }

    Context 'When removing existing database' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
        }
    }

    Context 'When removing the Azure Cosmos DB Account' {
        It 'Should not throw an exception' {
            Remove-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Force `
                -Verbose
        }
    }

    Context 'When getting the deleted Azure Cosmos DB Account' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -ErrorAction SilentlyContinue `
                -Verbose
        }

        It 'Should return null' {
            $script:result | Should -BeNullOrEmpty
        }
    }
}

# Remove test Resource Group
Remove-AzureTestCosmosDbResourceGroup `
    -ResourceGroupName $script:testResourceGroupName
