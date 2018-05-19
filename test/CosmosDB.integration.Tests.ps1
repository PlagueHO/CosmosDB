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

    Context 'Create a new collection' {
        It 'Should not throw an exception' {
            {
                $script:result = New-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
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
        }
    }

    Context 'Get existing collection' {
        It 'Should not throw an exception' {
            {
                $script:result = Get-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
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
        }
    }

    Context 'Add a permission for a user to the collection' {
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
                    -PermissionMode All `
                    -Verbose
            } | Should -Not -Throw
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testCollectionPermission
            $script:result.permissionMode | Should -Be 'All'
            $script:result.resource | Should -Be $script:collectionResourcePath
            $script:result.Token | Should -BeOfType [System.String]
        }
    }

    Context 'Get the permission for the user to the collection' {
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
            $script:result.permissionMode | Should -Be 'All'
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

    Context 'Remove existing permission for a user for the collection' {
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
                $script:result = New-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -PartitionKey $script:testPartitionKey -Verbose
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
