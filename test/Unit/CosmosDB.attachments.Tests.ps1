[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$moduleManifestName = 'CosmosDB.psd1'
$moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $moduleManifestPath -Force -Verbose:$false

InModuleScope CosmosDB {
    $testHelperPath = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'TestHelper'
    Import-Module -Name $testHelperPath -Force

    # Variables for use in tests
    $script:testAccount = 'testAccount'
    $script:testDatabase = 'testDatabase'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testDocument = 'testDocument'
    $script:testPartitionKeys = 'testPartitionKey1', 'testPartitionKey2'
    $script:testAttachment1 = 'testAttachment1'
    $script:testAttachment2 = 'testAttachment2'
    $script:testContentType = 'image/jpg'
    $script:testMedia = 'www.bing.com'
    $script:testJsonMulti = @'
{
    "_rid": "Sl8fALN4sw4CAAAAAAAAAA==",
    "Attachments": [
        {
            "contentType": "image/jpg",
            "id": "testAttachment1",
            "media": "'www.bing.com",
            "_rid": "Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
            "_ts": 1449679020,
            "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/docs\/Sl8fALN4sw4CAAAAAAAAAA==\/attachments\/Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
            "_etag": "\"06007fe0-0000-0000-0000-566858ac0000\""
        },
        {
            "contentType": "image/jpg",
            "id": "testAttachment2",
            "media": "'www.bing.com",
            "_rid": "Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
            "_ts": 1449679020,
            "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/docs\/Sl8fALN4sw4CAAAAAAAAAA==\/attachments\/Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
            "_etag": "\"06007fe0-0000-0000-0000-566858ac0000\""
        }
    ],
    "_count": 2
}
'@
    $script:testGetAttachmentResultMulti = @{
        Content = $script:testJsonMulti
    }
    $script:testJsonSingle = @'
{
    "contentType": "image/jpg",
    "id": "testAttachment1",
    "media": "'www.bing.com",
    "_rid": "Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
    "_ts": 1449679020,
    "_self": "dbs\/Sl8fAA==\/colls\/Sl8fALN4sw4=\/docs\/Sl8fALN4sw4CAAAAAAAAAA==\/attachments\/Sl8fALN4sw4CAAAAAAAAAOo3S2U=",
    "_etag": "\"06007fe0-0000-0000-0000-566858ac0000\""
}
'@
    $script:testGetAttachmentResultSingle = @{
        Content = $script:testJsonSingle
    }
    $script:testResource = 'dbs/testDatabase/colls/testCollection/docs/testDocument/attachment/'

    Describe 'Assert-CosmosDbAttachmentIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbAttachmentIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbAttachmentIdValid -Id 'This is a valid attachment ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AttachmentIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbAttachmentIdValid -Id ('a' * 256)
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id containing invalid characters' {
            $testCases = @{ Id = 'a\b' }, @{ Id = 'a/b' }, @{ Id = 'a#b' }, @{ Id = 'a?b' }

            It 'Should throw expected exception when called with "<Id>"' -TestCases $testCases {
                param
                (
                    [System.String]
                    $Id
                )

                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AttachmentIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbAttachmentIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AttachmentIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbAttachmentIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.AttachmentIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbAttachmentIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbAttachmentResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAttachmentResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbAttachmentResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                }

                { $script:result = Get-CosmosDbAttachmentResourcePath @getCosmosDbAttachmentResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/docs/{2}/attachments/{3}' -f $script:testDatabase, $script:testCollection, $script:testDocument, $script:testAttachment1)
            }
        }
    }

    Describe 'Get-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                }

                { $script:result = Get-CosmosDbAttachment @getCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testAttachment1
                $script:result[1].id | Should -Be $script:testAttachment2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'Attachments'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and no id but with two partition keys' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    PartitionKey = $script:testPartitionKeys
                }

                { $script:result = Get-CosmosDbAttachment @getCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testAttachment1
                $script:result[1].id | Should -Be $script:testAttachment2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $Headers.'x-ms-documentdb-partitionkey' -eq '["' + ($script:testPartitionKeys -join '","') + '"]'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                }

                { $script:result = Get-CosmosDbAttachment @getCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1)
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id and with two partition keys' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    PartitionKey = $script:testPartitionKeys
                }

                { $script:result = Get-CosmosDbAttachment @getCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Get' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) -and `
                        $Headers.'x-ms-documentdb-partitionkey' -eq '["' + ($script:testPartitionKeys -join '","') + '"]'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    ContentType  = $script:testContentType
                    Media        = $script:testMedia
                }

                { $script:result = New-CosmosDbAttachment @newCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'Attachments'
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id and with two partition keys' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    ContentType  = $script:testContentType
                    Media        = $script:testMedia
                    PartitionKey = $script:testPartitionKeys
                }

                { $script:result = New-CosmosDbAttachment @newCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Post' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $Headers.'x-ms-documentdb-partitionkey' -eq '["' + ($script:testPartitionKeys -join '","') + '"]'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                }

                { $script:result = Remove-CosmosDbAttachment @removeCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1)
                    } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an id and with two partition keys' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    PartitionKey = $script:testPartitionKeys
                }

                { $script:result = Remove-CosmosDbAttachment @removeCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Delete' -and `
                        $ResourceType -eq 'Attachments' -and `
                        $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) -and `
                        $Headers.'x-ms-documentdb-partitionkey' -eq '["' + ($script:testPartitionKeys -join '","') + '"]'
                    } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    ContentType  = $script:testContentType
                    Media        = $script:testMedia
                }

                { $script:result = Set-CosmosDbAttachment @setCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'attachments' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and with two partition keys' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetAttachmentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbAttachmentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                    ContentType  = $script:testContentType
                    Media        = $script:testMedia
                    PartitionKey = $script:testPartitionKeys
                }

                { $script:result = Set-CosmosDbAttachment @setCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testAttachment1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter {
                        $Method -eq 'Put' -and `
                        $ResourceType -eq 'attachments' -and `
                        $Headers.'x-ms-documentdb-partitionkey' -eq '["' + ($script:testPartitionKeys -join '","') + '"]'
                    } `
                    -Exactly -Times 1
            }
        }
    }
}
