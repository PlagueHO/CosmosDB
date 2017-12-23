[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force

InModuleScope CosmosDB {
    # Variables for use in tests
    $script:testAccount = 'testAccount'
    $script:testDatabase = 'testDatabase'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testConnection = [PSCustomObject] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testCollection = 'testCollection'
    $script:testDocument = 'testDocument'
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
    $script:testResource = 'dbs/testDatabase/colls/testCollection/docs/testDocument/attachment/'

    Describe 'Get-CosmosDbAttachmentResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbAttachmentResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with all parameters' {
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

        Context 'Called with connection parameter and no id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'Attachments' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonMulti }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Connection   = $script:testConnection
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
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'Attachments' } `
                    -Exactly -Times 1
            }
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'Attachments' -and $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $getCosmosDbAttachmentParameters = @{
                    Connection   = $script:testConnection
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
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'Attachments' -and $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'Attachments' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $newCosmosDbAttachmentParameters = @{
                    Connection   = $script:testConnection
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
                    -ParameterFilter { $Method -eq 'Post' -and $ResourceType -eq 'Attachments' } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'Attachments' -and $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) }

            It 'Should not throw exception' {
                $removeCosmosDbAttachmentParameters = @{
                    Connection   = $script:testConnection
                    CollectionId = $script:testCollection
                    DocumentId   = $script:testDocument
                    Id           = $script:testAttachment1
                }

                { $script:result = Remove-CosmosDbAttachment @removeCosmosDbAttachmentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'Attachments' -and $ResourcePath -eq ('colls/{0}/docs/{1}/attachments/{2}' -f $script:testCollection, $script:testDocument, $script:testAttachment1) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbAttachment' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbAttachment -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'Called with connection parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -ParameterFilter { $Method -eq 'Put' -and $ResourceType -eq 'attachments' } `
                -MockWith { ConvertFrom-Json -InputObject $script:testJsonSingle }

            It 'Should not throw exception' {
                $setCosmosDbAttachmentParameters = @{
                    Connection   = $script:testConnection
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
    }
}
