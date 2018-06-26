[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
$TestHelperPath = "$PSScriptRoot\TestHelper"

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
$script:testResourceGroupName = 'cosmosdbpsmoduletestrgp'
$script:testAccountName = ('cdbtest{0}' -f [System.IO.Path]::GetRandomFileName() -replace '\.', '')
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
    `"more`": `"Some other string`"
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

# Connect to Azure
Connect-AzureServicePrincipal `
    -SubscriptionId $env:azureSubscriptionId `
    -ApplicationId $env:azureApplicationId `
    -ApplicationPassword $env:azureApplicationPassword `
    -TenantId $env:azureTenantId `
    -Verbose

# Create Azure CosmosDB Account to use for testing
New-AzureCosmosDbAccount `
    -ResourceGroupName $script:testResourceGroupName `
    -AccountName $script:testAccountName `
    -Verbose

$script:testContext = New-CosmosDbContext `
    -Account $script:testAccountName `
    -Database $script:testDatabase `
    -ResourceGroup $script:testResourceGroupName

Describe 'Cosmos DB Module' -Tag 'Integration' {
    Context 'Create a new database' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
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

    Context 'Get existing database' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
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

    Context 'Create second new database' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase2 -Verbose
            } | Should -Not -Throw
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

    Context 'Get all existing databases' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbDatabase -Context $script:testContext -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Count | Should -Be 2
        }
    }

    Context 'Remove second database' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase2 -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Add a user to a database' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbUser `
                    -Context $script:testContext `
                    -Id $script:testUser `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get the user from a database' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbUser `
                    -Context $script:testContext `
                    -Id $script:testUser `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Create a new indexing policy' {
        It 'Should not throw an exception' {
            {
                $script:indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
                $script:indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Hash -DataType String -Precision 3
                $script:indexSpatialPoint = New-CosmosDbCollectionIncludedPathIndex -Kind Spatial -DataType Point
                $script:indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $script:indexNumberRange, $script:indexStringRange, $script:indexSpatialPoint
                $script:indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $script:indexIncludedPath
            } | Should -Not -Throw
        }
    }

    Context 'Create a new collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbCollection `
                    -Context $script:testContext `
                    -Id $script:testCollection `
                    -OfferThroughput 400 `
                    -IndexingPolicy $script:indexingPolicy `
                    -Verbose
            } | Should -Not -Throw
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
            $script:result.indexingPolicy.indexingMode | Should -Be 'consistent'
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

    Context 'Get existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbCollection `
                    -Context $script:testContext `
                    -Id $script:testCollection `
                    -Verbose
            } | Should -Not -Throw
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
            $script:result.indexingPolicy.indexingMode | Should -Be 'consistent'
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

    Context 'Update an existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Set-CosmosDbCollection `
                    -Context $script:testContext `
                    -Id $script:testCollection `
                    -IndexingPolicy $script:indexingPolicy `
                    -Verbose
            } | Should -Not -Throw
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
            $script:result.indexingPolicy.indexingMode | Should -Be 'consistent'
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

    Context 'Add a read collection permission for a user' {
        It 'Should not throw an exception' {
            {
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
            } | Should -Not -Throw
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

    Context 'Get the read collection permission for the user' {
        It 'Should not throw an exception' {
            {
                $script:collectionResourcePath = Get-CosmosDbCollectionResourcePath `
                    -Database $script:testDatabase `
                    -Id $script:testCollection
                $script:result = Get-CosmosDbPermission `
                    -Context $script:testContext `
                    -UserId $script:testUser `
                    -Id $script:testCollectionPermission `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get existing collection using resource token for user permission as context' {
        It 'Should not throw an exception' {
            {
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
            } | Should -Not -Throw
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
            $script:result.indexingPolicy.indexingMode | Should -Be 'consistent'
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

    Context 'Get existing offers' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
            } | Should -Not -Throw
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

    Context 'Update existing offer throughput' {
        It 'Should not throw an exception' {
            {
                $script:result = `
                    Get-CosmosDbOffer -Context $script:testContext -Verbose |
                    Set-CosmosDbOffer -Context $script:testContext -OfferThroughput 800 -Verbose
            } | Should -Not -Throw
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

    Context 'Add a document to a collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbDocument `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -DocumentBody $script:testDocumentBody `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Add an attachment to the document in a collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbAttachment `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -DocumentId $script:testDocumentId `
                    -Id $script:testAttachmentId `
                    -ContentType $script:testAttachmentContentType `
                    -Media $script:testAttachmentMedia `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get an attachment from the document in a collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbAttachment `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -DocumentId $script:testDocumentId `
                    -Id $script:testAttachmentId `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Add a read document permission for a user' {
        It 'Should not throw an exception' {
            {
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
            } | Should -Not -Throw
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

    Context 'Get the read document permission for the user' {
        It 'Should not throw an exception' {
            {
                $script:documentResourcePath = Get-CosmosDbDocumentResourcePath `
                    -Database $script:testDatabase `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId
                $script:result = Get-CosmosDbPermission `
                    -Context $script:testContext `
                    -UserId $script:testUser `
                    -Id $script:testDocumentPermission `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get existing document using resource token for user permission as context' {
        It 'Should not throw an exception' {
            {
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
            } | Should -Not -Throw
        }
    }

    Context 'Add a stored procedure to the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbStoredProcedure `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testStoredProcedureId `
                    -StoredProcedureBody $script:testStoredProcedureBody `
                    -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testStoredProcedureId
        }
    }

    Context 'Get the stored procedure from the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbStoredProcedure `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testStoredProcedureId `
                    -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testStoredProcedureId
        }
    }

    Context 'Remove the stored procedure from the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbStoredProcedure `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testStoredProcedureId `
                    -Verbose
            } | Should -Not -Throw
        }
    }

    foreach ($operation in 'All', 'Create', 'Replace', 'Delete')
    {
        Context "Add a $operation trigger to the collection" {
            It 'Should not throw an exception' {
                {
                    $script:result = New-CosmosDbTrigger `
                        -Context $script:testContext `
                        -CollectionId $script:testCollection `
                        -Id $script:testTriggerId `
                        -TriggerBody $script:testTriggerBody `
                        -TriggerOperation 'Create' `
                        -TriggerType 'Pre' `
                        -Verbose
                } | Should -Not -Throw
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

        Context "Get the $operation trigger from the collection" {
            It 'Should not throw an exception' {
                {
                    $script:result = Get-CosmosDbTrigger `
                        -Context $script:testContext `
                        -CollectionId $script:testCollection `
                        -Id $script:testTriggerId `
                        -Verbose
                } | Should -Not -Throw
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

        Context "Remove the $operation trigger from the collection" {
            It 'Should not throw an exception' {
                {
                    $script:result = Remove-CosmosDbTrigger `
                        -Context $script:testContext `
                        -CollectionId $script:testCollection `
                        -Id $script:testTriggerId `
                        -Verbose
                } | Should -Not -Throw
            }
        }
    }

    Context 'Add a user defined function to the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbUserDefinedFunction `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testUserDefinedFunctionId `
                    -UserDefinedFunctionBody $script:testUserDefinedFunctionBody `
                    -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUserDefinedFunctionId
        }
    }

    Context 'Get the user defined function from the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbUserDefinedFunction `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testUserDefinedFunctionId `
                    -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testUserDefinedFunctionId
        }
    }

    Context 'Remove the user defined function from the collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbUserDefinedFunction `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testUserDefinedFunctionId `
                    -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove the existing read collection permission for the user' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbPermission `
                    -Context $script:testContext `
                    -UserId $script:testUser `
                    -Id $script:testCollectionPermission `
                    -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove an attachment from the document in a collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbAttachment `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -DocumentId $script:testDocumentId `
                    -Id $script:testAttachmentId `
                    -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove a document from a collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbDocument `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId `
                    -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Create a new collection with a partition key' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbCollection `
                    -Context $script:testContext `
                    -Id $script:testCollection `
                    -PartitionKey $script:testPartitionKey `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Add a document to a collection with a partition key' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbDocument `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -DocumentBody $script:testDocumentBody `
                    -PartitionKey $script:testDocumentId `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get the document in a collection by using the Id with a partition key' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbDocument `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId `
                    -PartitionKey $script:testDocumentId `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Get all the documents in a collection with a partition key' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbDocument `
                    -Context $script:testContext `
                    -CollectionId $script:testCollection `
                    -PartitionKey $script:testDocumentId `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Remove existing collection with a partition key' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove existing user' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbUser -Context $script:testContext -Id $script:testUser -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Create a new collection with IndexingMode set to None' {
        It 'Should not throw an exception' {
            {
                $script:indexingPolicyNone = New-CosmosDbCollectionIndexingPolicy -Automatic $false -IndexingMode None

                $script:result = New-CosmosDbCollection `
                    -Context $script:testContext `
                    -Id $script:testCollection `
                    -OfferThroughput 400 `
                    -IndexingPolicy $script:indexingPolicyNone `
                    -Verbose
            } | Should -Not -Throw
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

    Context 'Remove existing collection with a None indexing Policy' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
            } | Should -Not -Throw
        }
    }

    Context 'Remove existing database' {
        It 'Should not throw an exception' {
            {
                $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase -Verbose
            } | Should -Not -Throw
        }
    }
}

# Remove Azure CosmosDB Account after testing
Remove-AzureCosmosDbAccount `
    -ResourceGroupName $script:testResourceGroupName `
    -AccountName $script:testAccountName `
    -Verbose
