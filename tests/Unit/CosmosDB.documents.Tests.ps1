[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module -Name $ProjectName -Force

InModuleScope $ProjectName {
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
    $script:testDocument1 = 'testDocument1'
    $script:testDocument2 = 'testDocument2'
    $script:testDocumentBody = 'testDocumentBody'
    $script:testPartitionKey = 'testPartitionKey'
    $script:testETag = '\"0500d107-0000-0c00-0000-5d2a0a660000\"'
    $script:testHeaders = @{
        'x-ms-continuation' = 'test'
    }
    $script:testJsonMulti = @'
    {
        "_rId": "d9RzAJRFKgw=",
        "Documents": [
          {
            "Id": "testDocument1",
            "content": "testDocumentBody",
            "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
            "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
            "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
            "_ts": 1459216987,
            "_attachments": "attachments/"
          },
          {
            "Id": "testDocument2",
            "content": "testDocumentBody",
            "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
            "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
            "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
            "_ts": 1459216987,
            "_attachments": "attachments/"
          }
        ],
        "_count": 2
    }
'@
    $script:testGetDocumentResultMulti = @{
        Content = $script:testJsonMulti
        Headers = $script:testHeaders
    }
    $script:testJsonSingle = @'
      {
        "Id": "testDocument1",
        "content": "testDocumentBody",
        "_rId": "d9RzAJRFKgwBAAAAAAAAAA==",
        "_self": "dbs/d9RzAA==/colls/d9RzAJRFKgw=/docs/d9RzAJRFKgwBAAAAAAAAAA==/",
        "_etag": "\"0000d986-0000-0000-0000-56f9e25b0000\"",
        "_ts": 1459216987,
        "_attachments": "attachments/"
      }
'@
    $script:testGetDocumentResultSingle = @{
        Content = $script:testJsonSingle
        Headers = $script:testHeaders
    }

    Describe 'Assert-CosmosDbDocumentIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbDocumentIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbDocumentIdValid -Id 'This is a valid document ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DocumentIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDocumentIdValid -Id ('a' * 256)
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
                    -Message ($LocalizedData.DocumentIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDocumentIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DocumentIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbDocumentIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.DocumentIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbDocumentIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }


    Describe 'Format-CosmosDbDocumentPartitionKey' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Format-CosmosDbDocumentPartitionKey -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a partition key with "abc"' {
            It 'Should return ["abc"]' {
                Format-CosmosDbDocumentPartitionKey -PartitionKey 'abc' | Should -Be '["abc"]'
            }
        }

        Context 'When called with a partition key with "abc,def"' {
            It 'Should return ["abc","def"]' {
                Format-CosmosDbDocumentPartitionKey -PartitionKey 'abc','def' | Should -Be '["abc","def"]'
            }
        }

        Context 'When called with a partition key with 123' {
            It 'Should return [123]' {
                Format-CosmosDbDocumentPartitionKey -PartitionKey 123 | Should -Be '[123]'
            }
        }

        Context 'When called with a partition key with 123,456' {
            It 'Should return [123,456]' {
                Format-CosmosDbDocumentPartitionKey -PartitionKey 123,456 | Should -Be '[123,456]'
            }
        }

        Context 'When called with a partition key with "abc",456' {
            It 'Should return ["abc",456]' {
                Format-CosmosDbDocumentPartitionKey -PartitionKey 'abc',456 | Should -Be '["abc",456]'
            }
        }

        Context 'When called with a partition key with an unsupported type' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.ErrorPartitionKeyUnsupportedType -f 'True', 'System.Boolean') `
                    -ArgumentName 'PartitionKey'

                {
                    Format-CosmosDbDocumentPartitionKey -PartitionKey $true
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbDocumentResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocumentResourcePath -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $getCosmosDbDocumentResourcePathParameters = @{
                    Database     = $script:testDatabase
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbDocumentResourcePath @getCosmosDbDocumentResourcePathParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}/docs/{2}' -f $script:testDatabase, $script:testCollection, $script:testDocument1)
            }
        }
    }

    Describe 'Get-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no Id but with header parameters' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context             = $script:testContext
                    CollectionId        = $script:testCollection
                    MaxItemCount        = 5
                    ContinuationToken   = 'token'
                    ConsistencyLevel    = 'Strong'
                    SessionToken        = 'session'
                    PartitionKeyRangeId = 'partition'
                    Verbose             = $true
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testDocument1
                $script:result[1].id | Should -Be $script:testDocument2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and no Id with headers returned' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                $script:ResponseHeader = $null

                $getCosmosDbDocumentParameters = @{
                    Context        = $script:testContext
                    CollectionId   = $script:testCollection
                    ResponseHeader = [ref] $script:ResponseHeader
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testDocument1
                $script:result[1].id | Should -Be $script:testDocument2
                $script:ResponseHeader.'x-ms-continuation' | Should -Be 'test'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Key' {
            $script:result = $null

            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1) -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    PartitionKey = $script:testPartitionKey
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbDocument @getCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Get-CosmosDbDocumentJson' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbDocumentJson -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and no Id but with header parameters' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                $getCosmosDbDocumentJsonParameters = @{
                    Context             = $script:testContext
                    CollectionId        = $script:testCollection
                    MaxItemCount        = 5
                    ContinuationToken   = 'token'
                    ConsistencyLevel    = 'Strong'
                    SessionToken        = 'session'
                    PartitionKeyRangeId = 'partition'
                    Verbose             = $true
                }

                { $script:result = Get-CosmosDbDocumentJson @getCosmosDbDocumentJsonParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testJsonMulti
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and no Id with headers returned' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultMulti }

            It 'Should not throw exception' {
                $script:ResponseHeader = $null

                $getCosmosDbDocumentJsonParameters = @{
                    Context        = $script:testContext
                    CollectionId   = $script:testCollection
                    ResponseHeader = [ref] $script:ResponseHeader
                    Verbose        = $true
                }

                { $script:result = Get-CosmosDbDocumentJson @getCosmosDbDocumentJsonParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testJsonMulti
                $script:ResponseHeader.'x-ms-continuation' | Should -Be 'test'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentJsonParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbDocumentJson @getCosmosDbDocumentJsonParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testJsonSingle
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Key' {
            $script:result = $null

            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Get' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1) -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $getCosmosDbDocumentJsonParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    PartitionKey = $script:testPartitionKey
                    Verbose      = $true
                }

                { $script:result = Get-CosmosDbDocumentJson @getCosmosDbDocumentJsonParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testJsonSingle
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'New-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Encoding is UTF-8' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Encoding -eq 'UTF-8'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                    Encoding     = 'UTF-8'
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Key' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $newCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    DocumentBody = $script:testDocumentBody
                    PartitionKey = $script:testPartitionKey
                    Verbose      = $true
                }

                { $script:result = New-CosmosDbDocument @newCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Remove-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Delete' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    Verbose      = $true
                }

                { $script:result = Remove-CosmosDbDocument @removeCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Delete' -and `
                    $ResourceType -eq 'docs' -and `
                    $ResourcePath -eq ('colls/{0}/docs/{1}' -f $script:testCollection, $script:testDocument1) -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw exception' {
                $removeCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    PartitionKey = $script:testPartitionKey
                    Verbose      = $true
                }

                { $script:result = Remove-CosmosDbDocument @removeCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbDocument' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Set-CosmosDbDocument -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    Verbose      = $true
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Id' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    PartitionKey = $script:testPartitionKey
                    Verbose      = $true
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Encoding is UTF-8' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs' -and `
                    $Encoding -eq 'UTF-8'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    Encoding     = 'UTF-8'
                    Verbose      = $true
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and ETag' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['If-Match'] -eq ($script:testETag)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    ETag         = $script:testETag
                    Verbose      = $true
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and Partition Id and ETag' {
            $script:result = $null
            $invokeCosmosDbRequest_parameterfilter = {
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'docs' -and `
                    $Headers['x-ms-documentdb-partitionkey'] -eq ('["{0}"]' -f $script:testPartitionKey) -and `
                    $Headers['If-Match'] -eq ($script:testETag)
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetDocumentResultSingle }

            It 'Should not throw exception' {
                $setCosmosDbDocumentParameters = @{
                    Context      = $script:testContext
                    CollectionId = $script:testCollection
                    Id           = $script:testDocument1
                    DocumentBody = $script:testDocumentBody
                    PartitionKey = $script:testPartitionKey
                    ETag         = $script:testETag
                    Verbose      = $true
                }

                { $script:result = Set-CosmosDbDocument @setCosmosDbDocumentParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testDocument1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokeCosmosDbRequest_parameterfilter `
                    -Exactly -Times 1
            }
        }
    }
}
