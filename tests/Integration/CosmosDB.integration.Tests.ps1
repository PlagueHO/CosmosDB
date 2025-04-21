[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module -Name $ProjectName -Force

$testHelperPath = "$PSScriptRoot\..\TestHelper"
Import-Module -Name $testHelperPath -Force

Get-AzureServicePrincipal -Verbose

if ([System.String]::IsNullOrEmpty($env:azureSubscriptionId) -or `
        [System.String]::IsNullOrEmpty($env:azureApplicationId) -or `
        [System.String]::IsNullOrEmpty($env:azureApplicationPassword) -or `
        [System.String]::IsNullOrEmpty($env:azureTenantId) -or `
        [System.String]::IsNullOrEmpty($env:azureApplicationObjectId) -or `
        $env:azureSubscriptionId -eq '$(azureSubscriptionId)' -or `
        $env:azureApplicationId -eq '$(azureApplicationId)' -or `
        $env:azureApplicationPassword -eq '$(azureApplicationPassword)' -or `
        $env:azureTenantId -eq '$(azureTenantId)' -or `
        $env:azureApplicationObjectId -eq '$(azureApplicationObjectId)'
    )
{
    Write-Warning -Message 'Integration tests can not be run because one or more Azure connection environment variables are not set.'
    return
}

# Variables for use in tests
$script:testRandomName = [System.IO.Path]::GetRandomFileName() -replace '\.', ''
$script:testBuildBranch = $ENV:BUILD_SOURCEBRANCHNAME

if ([System.String]::IsNullOrEmpty($script:testBuildBranch))
{
    $script:testBuildBranch = & git branch --show-current
}

$script:testBuildSystem = $ENV:SYSTEM

if ([System.String]::IsNullOrEmpty($script:testBuildSystem))
{
    $script:testBuildSystem = 'local'
}

$script:testResourceGroupName = ('cdbtestrgp-{0}-{1}-{2}' -f $script:testRandomName,$script:testBuildSystem,$script:testBuildBranch)
$script:testAccountName = ('cdbtest{0}' -f $script:testRandomName)
$script:testLocation = 'Australia East'
$script:testCorsAllowedOrigins = @('https://www.contoso.com', 'https://www.fabrikam.com')
$script:testOffer = 'testOffer'
$script:testDatabase = 'testDatabase'
$script:testDatabase2 = 'testDatabase2'
$script:testDatabase3 = 'testDatabase3'
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
$script:testDocumentUTF8UpdateContent = "sdsføæå"
$script:testDocumentUTF8UpdateBody = @"
{
    `"id`": `"$script:testDocumentUTF8Id`",
    `"content`": `"$script:testDocumentUTF8UpdateContent`"
}
"@
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
$script:cosmosDbRoleDefinitionIdReader = '00000000-0000-0000-0000-000000000001'
$script:cosmosDbRoleDefinitionIdContributor = '00000000-0000-0000-0000-000000000002'

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

# Get the Entra ID token for the logged in Service Principal to use
# for testing Cosmos DB secured with RBAC.
$script:entraIdTokenForSP = Get-AzureEntraIdToken -Verbose
$script:entraIdTokenForSPSecureString = ConvertTo-SecureString -String $script:entraIdTokenForSP -AsPlainText -Force

# Create resource group
$null = New-AzureTestCosmosDbResourceGroup `
    -ResourceGroupName $script:testResourceGroupName `
    -Location $script:testLocation `
    -Verbose

$currentIpAddress = (Invoke-RestMethod -Uri 'http://ipinfo.io/json').ip

Describe 'Cosmos DB Module' -Tag 'Integration' {
    function Test-GenericResult
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $GenericResult
        )

        $GenericResult.Timestamp | Should -BeOfType [System.DateTime]
        $GenericResult.Etag | Should -BeOfType [System.String]
        $GenericResult.ResourceId | Should -BeOfType [System.String]
        $GenericResult.Uri | Should -BeOfType [System.String]
    }

    function Test-CollectionResult
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $CollectionResult
        )

        Test-GenericResult -GenericResult $CollectionResult
        $CollectionResult.Conflicts | Should -BeOfType [System.String]
        $CollectionResult.Documents | Should -BeOfType [System.String]
        $CollectionResult.StoredProcedures | Should -BeOfType [System.String]
        $CollectionResult.Triggers | Should -BeOfType [System.String]
        $CollectionResult.UserDefinedFunctions | Should -BeOfType [System.String]
    }

    function Test-CollectionDefaultIndexingPolicy
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $CollectionResult
        )

        Test-CollectionResult -CollectionResult $CollectionResult
        $CollectionResult.indexingPolicy.indexingMode | Should -Be 'Consistent'
        $CollectionResult.indexingPolicy.automatic | Should -Be $true
        $CollectionResult.indexingPolicy.includedPaths[0].path | Should -Be '/*'
        $CollectionResult.indexingPolicy.includedPaths[0].Indexes | Should -BeNullOrEmpty
        $CollectionResult.indexingPolicy.excludedPaths[0].path | Should -Be '/"_etag"/?'
    }

    function Test-CollectionResultComplexAutomaticIndexingPolicy
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $CollectionResult
        )

        Test-CollectionResult -CollectionResult $CollectionResult
        $CollectionResult.indexingPolicy.indexingMode | Should -Be 'Consistent'
        $CollectionResult.indexingPolicy.automatic | Should -Be $true
        $CollectionResult.indexingPolicy.includedPaths.Count | Should -Be 2
        $CollectionResult.indexingPolicy.includedPaths[0].path | Should -Be '/*'
        $CollectionResult.indexingPolicy.includedPaths[1].path | Should -Be '/Location/*'
        $CollectionResult.indexingPolicy.excludedPaths[0].path | Should -Be '/"_etag"/?'
        $CollectionResult.indexingPolicy.spatialIndexes.Count | Should -Be 2
        $CollectionResult.indexingPolicy.spatialIndexes[0].path | Should -Be '/*'
        $CollectionResult.indexingPolicy.spatialIndexes[1].path | Should -Be '/Location/*'
    }

    function Test-CollectionCompositeIndexingPolicy
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $CollectionResult
        )

        Test-CollectionResult -CollectionResult $CollectionResult
        $CollectionResult.indexingPolicy.indexingMode | Should -Be 'Consistent'
        $CollectionResult.indexingPolicy.automatic | Should -Be $true
        $CollectionResult.indexingPolicy.includedPaths[0].path | Should -Be '/*'
        $CollectionResult.indexingPolicy.compositeIndexes[0][0].Path | Should -Be '/name'
        $CollectionResult.indexingPolicy.compositeIndexes[0][0].Order | Should -Be 'ascending'
        $CollectionResult.indexingPolicy.compositeIndexes[0][1].Path | Should -Be '/age'
        $CollectionResult.indexingPolicy.compositeIndexes[0][1].Order | Should -Be 'ascending'
        $CollectionResult.indexingPolicy.compositeIndexes[1][0].Path | Should -Be '/name'
        $CollectionResult.indexingPolicy.compositeIndexes[1][0].Order | Should -Be 'ascending'
        $CollectionResult.indexingPolicy.compositeIndexes[1][1].Path | Should -Be '/age'
        $CollectionResult.indexingPolicy.compositeIndexes[1][1].Order | Should -Be 'descending'
    }

    Context 'When creating a new Azure Cosmos DB Account' {
        It 'Should not throw an exception' {
            New-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'BoundedStaleness' `
                -MaxIntervalInSeconds 50 `
                -MaxStalenessPrefix 50 `
                -AllowedOrigin $script:testCorsAllowedOrigins `
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
            $script:result.Properties.cors[0].allowedOrigins | Should -Be ($script:testCorsAllowedOrigins -join ',')
        }
    }

    Context 'When updating the new Azure Cosmos DB Account' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'Session' `
                -IpRangeFilter "$currentIpAddress/32" `
                -AllowedOrigin '*' `
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
            $script:result.Properties.consistencyPolicy.defaultConsistencyLevel | Should -Be 'Session'
            $script:result.Properties.consistencyPolicy.maxIntervalInSeconds | Should -Be 5
            $script:result.Properties.consistencyPolicy.maxStalenessPrefix | Should -Be 100
            $script:result.Properties.ipRangeFilter | Should -Be "$currentIpAddress/32"
            $script:result.Properties.cors[0].allowedOrigins | Should -Be '*'
        }
    }

    Context 'When updating the new Azure Cosmos DB Account to remove IP Range filter' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbAccount `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Location $script:testLocation `
                -DefaultConsistencyLevel 'Session' `
                -IpRangeFilter '' `
                -Verbose
        }
    }

    Context 'When getting the new Azure Cosmos DB Account SecondaryReadonlyMasterKey connection string' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbAccountConnectionString `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -MasterKeyType 'SecondaryReadonlyMasterKey' `
                -Verbose
        }

        It 'Should return connection string' {
            $script:result | Should -BeLike 'AccountEndpoint=*'
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
        It 'Should not throw an exception' {
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

    Context 'When creating second new database with a specified offer throughput' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase2 -OfferThroughput 800 -Verbose
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

    Context 'When checking offer has been created for second database' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 800
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
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

    Context 'When creating third new database with a specified autoscale throughput' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase3 -AutoscaleThroughput 1000 -Verbose
        }

        It 'Should return expected object' {
            $script:result.Timestamp | Should -BeOfType [System.DateTime]
            $script:result.Etag | Should -BeOfType [System.String]
            $script:result.ResourceId | Should -BeOfType [System.String]
            $script:result.Uri | Should -BeOfType [System.String]
            $script:result.Collections | Should -BeOfType [System.String]
            $script:result.Users | Should -BeOfType [System.String]
            $script:result.Id | Should -Be $script:testDatabase3
        }
    }

    Context 'When checking offer has been created for third database' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -BeExactly 100
            $script:result.content.offerMinimumThroughputParameters.maxThroughputEverProvisioned | Should -BeExactly 1000
            $script:result.content.offerAutopilotSettings.maxThroughput | Should -BeExactly 1000
        }
    }

    Context 'When getting a collection that does not exist from a database' {
        It 'Should throw expected CosmosDb.ResponseException' {
            $script:cosmosDbResponseException = $null

            {
                try
                {
                    $script:result = New-CosmosDbCollection `
                        -Context $script:testContext `
                        -Database $script:testDatabase3 `
                        -Id 'doesnotexist' `
                        -Verbose
                }
                catch [CosmosDb.ResponseException]
                {
                    $script:cosmosDbResponseException = $_.Exception
                }
            } | Should -Not -Throw

            $script:cosmosDbResponseException | Should -BeOfType [CosmosDb.ResponseException]
            $script:cosmosDbResponseException.Message | Should -Be 'Response status code does not indicate success: 400 (Bad Request).'
            $script:cosmosDbResponseException.StatusCode | Should -Be 400
        }
    }

    Context 'When removing third database' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbDatabase -Context $script:testContext -Id $script:testDatabase3 -Verbose
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testUser
            $script:result.Permissions | Should -Be 'permissions/'
        }
    }

    Context 'When creating a new collection with no indexing policy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionDefaultIndexingPolicy -CollectionResult $script:result
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'When removing existing collection with no indexing policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new simple automatic indexing policy' {
        It 'Should not throw an exception' {
            $script:indexingPolicySimpleAutomatic = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent
        }
    }

    Context 'When creating a new collection with a simple automatic indexing policy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicySimpleAutomatic `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionDefaultIndexingPolicy -CollectionResult $script:result
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'When removing existing collection with a simple automatic indexing policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new collection with a simple automatic indexing policy using JSON' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicyJson (ConvertTo-Json -InputObject $script:indexingPolicySimpleAutomatic -Depth 10) `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionDefaultIndexingPolicy -CollectionResult $script:result
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'When removing existing collection with a simple automatic indexing policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new composite index indexing policy' {
        It 'Should not throw an exception' {
            $script:compositeIndexElements = @(
                @(
                    (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                    (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Ascending')
                ),
                @(
                    (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                    (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Descending')
                )
            )
            $script:indexIncludedPathOnly = New-CosmosDbCollectionIncludedPath -Path '/*'
            $script:indexingPolicyComposite = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $script:indexIncludedPathOnly -CompositeIndex $script:compositeIndexElements
        }
    }

    Context 'When creating a new collection with a composite indexing policy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicyComposite `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionCompositeIndexingPolicy -CollectionResult $script:result
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'When removing existing collection with a composite indexing policy' {
        It 'Should not throw an exception' {
            $script:result = Remove-CosmosDbCollection -Context $script:testContext -Id $script:testCollection -Verbose
        }
    }

    Context 'When creating a new complex automatic indexing policy' {
        It 'Should not throw an exception' {
            $script:indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
            $script:indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String -Precision -1
            $script:indexSpatialPoint = New-CosmosDbCollectionIncludedPathIndex -Kind Spatial -DataType Point
            $script:indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $script:indexNumberRange, $script:indexStringRange, $script:indexSpatialPoint
            $script:indexIncludedPathLocation = New-CosmosDbCollectionIncludedPath -Path '/Location/*' -Index $script:indexSpatialPoint
            $script:indexingPolicyComplexAutomatic = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $script:indexIncludedPath,$script:indexIncludedPathLocation
        }
    }

    Context 'When creating a new unique key policy' {
        It 'Should not throw an exception' {
            $script:uniqueKey = New-CosmosDbCollectionUniqueKey -Path '/uniquekey'
            $script:uniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $script:uniqueKey
        }
    }

    Context 'When creating a new collection with a complex automatic indexing policy and unique key policy' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -OfferThroughput 400 `
                -IndexingPolicy $script:indexingPolicyComplexAutomatic `
                -UniqueKeyPolicy $script:uniqueKeyPolicy `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
            $script:result.uniqueKeyPolicy.uniqueKeys[0].paths[0] | Should -Be '/uniquekey'
        }
    }

    Context 'When getting existing collection with an indexing policy and unique key policy' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
            $script:result.uniqueKeyPolicy.uniqueKeys[0].paths[0] | Should -Be '/uniquekey'
        }
    }

    Context 'When updating an existing collection with a complex IndexingPolicy and UniqueKeyPolicy' {
        It 'Should not throw an exception' {
            $script:result = Set-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -IndexingPolicy $script:indexingPolicyComplexAutomatic `
                -UniqueKeyPolicy $script:uniqueKeyPolicy `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
        }
    }

    Context 'When getting existing offers' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbOffer -Context $script:testContext -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
            $script:result.OfferVersion | Should -BeOfType [System.String]
            $script:result.OfferType | Should -BeOfType [System.String]
            $script:result.OfferResourceId | Should -BeOfType [System.String]
            $script:result.Id | Should -BeOfType [System.String]
            $script:result.content.offerThroughput | Should -Be 800
            $script:result.content.offerIsRUPerMinuteThroughputEnabled | Should -Be $false
        }
    }

    Context 'When testing RBAC access using an Entra ID token' {
        Context 'When assigning an RBAC contributor role to the account for the principal' {
            It 'Should not throw an exception' {
                New-AzCosmosDBSqlRoleAssignment `
                    -AccountName $script:testAccountName `
                    -ResourceGroupName $script:testResourceGroupName `
                    -RoleDefinitionId $script:cosmosDbRoleDefinitionIdContributor `
                    -Scope "/" `
                    -PrincipalId $env:azureApplicationObjectId
            }
        }

        Context 'When retrieving the RBAC contributor role from the account for the principal' {
            It 'Should not throw an exception' {
                $script:Result = Get-AzCosmosDBSqlRoleAssignment `
                    -AccountName $script:testAccountName `
                    -ResourceGroupName $script:testResourceGroupName

                Write-Verbose -Message ($script:Result | Out-String)
            }

            It 'Should return at least one SQL Role Assignement' {
                $script:Result | Should -Not -BeNullOrEmpty
            }
        }

        # RBAC access testing using a Entra ID token generated via the test harness
        Context 'When creating a new context from Azure using an Entra ID Token for the Service Principal' {
            It 'Should not throw an exception' {
                $script:testEntraIdContext = New-CosmosDbContext `
                    -Account $script:testAccountName `
                    -Database $script:testDatabase `
                    -EntraIdToken $script:entraIdTokenForSPSecureString
            }
        }

        Context 'When adding a document to a collection using an Entra ID Token' {
            It 'Should not throw an exception' {
                $script:result = New-CosmosDbDocument `
                    -Context $script:testEntraIdContext `
                    -CollectionId $script:testCollection `
                    -DocumentBody $script:testDocumentBody `
                    -Verbose
            }

            It 'Should return expected object' {
                Test-GenericResult -GenericResult $script:result
                $script:result.Id | Should -Be $script:testDocumentId
                $script:result.Content | Should -Be 'Some string'
                $script:result.More | Should -Be 'Some other string'
            }
        }

        Context 'When removing a document from a collection using an Entra ID Token' {
            It 'Should not throw an exception' {
                $script:result = Remove-CosmosDbDocument `
                    -Context $script:testEntraIdContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId `
                    -Verbose
            }
        }

        # RBAC access testing using a Entra ID token generated via the test harness
        Context 'When creating a new context from Azure using an automatically generated Entra ID Token for the Service Principal' {
            It 'Should not throw an exception' {
                $script:testEntraIdContext = New-CosmosDbContext `
                    -Account $script:testAccountName `
                    -Database $script:testDatabase `
                    -AutoGenerateEntraIdToken
            }
        }

        Context 'When adding a document to a collection using an Entra ID Token' {
            It 'Should not throw an exception' {
                $script:result = New-CosmosDbDocument `
                    -Context $script:testEntraIdContext `
                    -CollectionId $script:testCollection `
                    -DocumentBody $script:testDocumentBody `
                    -Verbose
            }

            It 'Should return expected object' {
                Test-GenericResult -GenericResult $script:result
                $script:result.Id | Should -Be $script:testDocumentId
                $script:result.Content | Should -Be 'Some string'
                $script:result.More | Should -Be 'Some other string'
            }
        }

        Context 'When getting a document in a collection using an Entra ID Token' {
            It 'Should not throw an exception' {
                $script:result = Get-CosmosDbDocument `
                    -Context $script:testEntraIdContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId `
                    -Verbose
            }

            It 'Should return expected object' {
                Test-GenericResult -GenericResult $script:result
                $script:result.Id | Should -Be $script:testDocumentId
                $script:result.Content | Should -Be 'Some string'
                $script:result.More | Should -Be 'Some other string'
            }
        }

        Context 'When removing a document from a collection using an Entra ID Token' {
            It 'Should not throw an exception' {
                $script:result = Remove-CosmosDbDocument `
                    -Context $script:testEntraIdContext `
                    -CollectionId $script:testCollection `
                    -Id $script:testDocumentId `
                    -Verbose
            }
        }

        <#
            When a rquest to the CosmosDB is made, but it fails with an HttpResponseException
            the exception should be rethrown as a CosmosDb.ResponseException, otherwise the
            HttpResponseException will contain the Response.requestMessage which will contain
            the authorizationHeader.
        #>
        Context 'When getting a document that does not exist in a collection using an Entra ID Token' {
            It 'Should throw expected CosmosDb.ResponseException' {
                $script:cosmosDbResponseException = $null

                {
                    try
                    {
                        $script:result = Get-CosmosDbDocument `
                            -Context $script:testEntraIdContext `
                            -CollectionId $script:testCollection `
                            -Id 'doesnotexist' `
                            -Verbose
                    }
                    catch [CosmosDb.ResponseException]
                    {
                        $script:cosmosDbResponseException = $_.Exception
                    }
                } | Should -Not -Throw

                $script:cosmosDbResponseException | Should -BeOfType [CosmosDb.ResponseException]
                $script:cosmosDbResponseException.Message | Should -Be 'Response status code does not indicate success: 404 (Not Found).'
                $script:cosmosDbResponseException.StatusCode | Should -Be 404
            }
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
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentId
            $script:result.Content | Should -Be 'Some string'
            $script:result.More | Should -Be 'Some other string'
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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

    Context 'When getting existing document using connection string as context' {
        It 'Should not throw an exception' {
            $connectionString = Get-CosmosDbAccountConnectionString `
                -Name $script:testAccountName `
                -ResourceGroupName $script:testResourceGroupName `
                -Verbose

            $connectionStringContext = New-CosmosDbContext `
                -ConnectionString ($connectionString | ConvertTo-SecureString -AsPlainText -Force) `
                -Database $script:testDatabase `
                -Verbose

            $script:result = Get-CosmosDbDocument `
                -Context $connectionStringContext `
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
                Test-GenericResult -GenericResult $script:result
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
                Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
        }
    }

    Context 'When getting all newly created UTF-8 documents from a collection by using a query' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Query "SELECT * FROM docs c" `
                -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
            $script:result.Content | Should -Be $script:testDocumentUTF8Content
        }
    }

    Context 'When getting newly created UTF-8 document from a collection by using a query' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Query "SELECT * FROM docs c WHERE (c.id = '$testDocumentUTF8Id')" `
                -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
            $script:result.Content | Should -Be $script:testDocumentUTF8Content
        }
    }

    Context 'When getting newly created UTF-8 document from a collection by using a query with parameters' {
        It 'Should not throw an exception' {
            $script:result = Get-CosmosDbDocument `
                -Context $script:testContext `
                -CollectionId $script:testCollection `
                -Query 'SELECT * FROM docs c WHERE (c.id = @id)' `
                -QueryParameters @{
                    name = '@id'
                    value = $testDocumentUTF8Id
                } `
                -Verbose
        }

        It 'Should return expected object' {
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
            $script:result.Content | Should -Be $script:testDocumentUTF8Content
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
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
            $script:result.Content | Should -Be $script:testDocumentUTF8Content
        }
    }

    Context 'When updating an existing UTF-8 document in a collection' {
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
            $script:result.Id | Should -Be $script:testDocumentUTF8Id
            $script:result.Content | Should -Be $script:testDocumentUTF8UpdateContent
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

    Context 'When creating a new autoscale throughtput collection with a partition key' {
        It 'Should not throw an exception' {
            $script:result = New-CosmosDbCollection `
                -Context $script:testContext `
                -Id $script:testCollection `
                -PartitionKey $script:testPartitionKey `
                -AutoscaleThroughput 1000 `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionResult -CollectionResult $script:result
            $script:result.Id | Should -Be $script:testCollection
            $script:result.partitionKey.kind | Should -Be 'Hash'
            $script:result.partitionKey.paths[0] | Should -Be ('/{0}' -f $script:testPartitionKey)
        }
    }

    Context 'When removing existing autoscale throughtput collection with a partition key' {
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
            Test-CollectionResult -CollectionResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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
            Test-GenericResult -GenericResult $script:result
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

    <#
        When a rquest to the CosmosDB is made, but it fails with an HttpResponseException
        the exception should be rethrown as a CosmosDb.ResponseException, otherwise the
        HttpResponseException will contain the Response.requestMessage which will contain
        the authorizationHeader.
    #>
    Context 'When getting a document that does not exist in a collection' {
        It 'Should throw expected CosmosDb.ResponseException' {
            $script:cosmosDbResponseException = $null

            {
                try
                {
                    $script:result = Get-CosmosDbDocument `
                        -Context $script:testContext `
                        -CollectionId $script:testCollection `
                        -Id 'doesnotexist' `
                        -Verbose
                }
                catch [CosmosDb.ResponseException]
                {
                    $script:cosmosDbResponseException = $_.Exception
                }
            } | Should -Not -Throw

            $script:cosmosDbResponseException | Should -BeOfType [CosmosDb.ResponseException]
            $script:cosmosDbResponseException.Message | Should -Be 'The specified resource does not exist.'
            $script:cosmosDbResponseException.StatusCode | Should -Be 404
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
            Test-CollectionResult -CollectionResult $script:result
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
            Test-CollectionResult -CollectionResult $script:result
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
            Test-CollectionResult -CollectionResult $script:result
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
            Test-CollectionResult -CollectionResult $script:result
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
                -IndexingPolicy $script:indexingPolicyComplexAutomatic `
                -DefaultTimeToLive ($script:testDefaultTimeToLive + 2) `
                -Verbose
        }

        It 'Should return expected object' {
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
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
            Test-CollectionResultComplexAutomaticIndexingPolicy -CollectionResult $script:Result
            $script:result.Id | Should -Be $script:testCollection
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
                -ContinuationToken (Get-CosmosDbContinuationToken -ResponseHeader $script:ResponseHeader) `
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
    -ResourceGroupName $script:testResourceGroupName `
    -Verbose
