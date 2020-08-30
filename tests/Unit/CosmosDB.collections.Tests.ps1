[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            { Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            { $false
            } )
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
    $script:testHeaders = [PSObject] @{
        'x-ms-continuation' = 'test'
    }
    $script:testCollection1 = 'testCollection1'
    $script:testCollection2 = 'testCollection2'
    $script:testJsonMulti = @'
{
    "_rid": "PaYSAA==",
    "DocumentCollections": [
        {
            "id": "testcollection1"
        },
        {
            "id": "testcollection2"
        }
    ],
    "_count": 1
}
'@
    $script:testGetCollectionResultMulti = @{
        Content = $script:testJsonMulti
        Headers = $script:testHeaders
    }
    $script:testJsonSingle = @'
{
    "id": "testcollection1"
}
'@
    $script:testGetCollectionResultSingle = @{
        Content = $script:testJsonSingle
    }
    $script:testIndexingPolicy = New-CosmosDbCollectionIndexingPolicy `
        -Automatic $true `
        -IndexingMode 'Consistent' `
        -IncludedPath (
        New-CosmosDbCollectionIncludedPath -Path '/*' -Index (
            New-CosmosDbCollectionIncludedPathIndex -Kind 'Range' -DataType 'String'
        )
    ) `
        -ExcludedPath (
        New-CosmosDbCollectionExcludedPath -Path '/exclude/'
    )
    $script:testIndexingPolicyJson = ConvertTo-Json -InputObject $script:testIndexingPolicy -Depth 10
    $script:testPartitionKey = @{
        paths = @(
            '/partitionkey'
        )
        kind  = 'Hash'
    }
    $script:testDefaultTimeToLive = 3600

    $script:testUniqueKeyA = New-CosmosDbCollectionUniqueKey -Path @('/uniquekey1', '/uniquekey2')
    $script:testUniqueKeyB = New-CosmosDbCollectionUniqueKey -Path '/uniquekey3'
    $script:testUniqueKeyPolicy = New-CosmosDbCollectionUniqueKeyPolicy -UniqueKey $script:testUniqueKeyA, $script:testUniqueKeyB

    Describe 'Assert-CosmosDbCollectionIdValid' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Assert-CosmosDbCollectionIdValid -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with a valid Id' {
            It 'Should return $true' {
                Assert-CosmosDbCollectionIdValid -Id 'This is a valid collection ID..._-99!' | Should -Be $true
            }
        }

        Context 'When called with a 256 character Id' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.CollectionIdInvalid -f ('a' * 256)) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbCollectionIdValid -Id ('a' * 256)
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
                    -Message ($LocalizedData.CollectionIdInvalid -f $Id) `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbCollectionIdValid -Id $Id
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an Id ending with a space' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.CollectionIdInvalid -f 'a ') `
                    -ArgumentName 'Id'

                {
                    Assert-CosmosDbCollectionIdValid -Id 'a '
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with an invalid Id and an argument name is specified' {
            It 'Should throw expected exception' {
                $errorRecord = Get-InvalidArgumentRecord `
                    -Message ($LocalizedData.CollectionIdInvalid -f 'a ') `
                    -ArgumentName 'Test'

                {
                    Assert-CosmosDbCollectionIdValid -Id 'a ' -ArgumentName 'Test'
                } | Should -Throw $errorRecord
            }
        }
    }

    Describe 'Get-CosmosDbCollectionResourcePath' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name Get-CosmosDbCollectionResourcePath  -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $getCosmosDbCollectionResourcePathParameters = @{
                    Database = $script:testDatabase
                    Id       = $script:testCollection1
                    Verbose  = $true
                }

                $script:result = Get-CosmosDbCollectionResourcePath @getCosmosDbCollectionResourcePathParameters
            }

            It 'Should return expected result' {
                $script:result | Should -Be ('dbs/{0}/colls/{1}' -f $script:testDatabase, $script:testCollection1)
            }
        }
    }

    Describe 'New-CosmosDbCollectionCompositeIndexElement' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionCompositeIndexElement -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with valid path and default order' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionCompositeIndexElementParameters = @{
                    Path    = '/path'
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionCompositeIndexElement @newCosmosDbCollectionCompositeIndexElementParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.CompositeIndex.Element'
                $script:result.Path | Should -Be '/path'
                $script:result.Order | Should -BeExactly 'ascending'
            }
        }

        Context 'When called with valid path and descending order' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionCompositeIndexElementParameters = @{
                    Path    = '/path'
                    Order   = 'Descending'
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionCompositeIndexElement @newCosmosDbCollectionCompositeIndexElementParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.CompositeIndex.Element'
                $script:result.Path | Should -Be '/path'
                $script:result.Order | Should -BeExactly 'descending'
            }
        }
    }

    Describe 'New-CosmosDbCollectionIncludedPathIndex' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionIncludedPathIndex -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with valid Hash parameters and Precision' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind      = 'Hash'
                    DataType  = 'String'
                    Precision = -1
                    Verbose   = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.Index'
                $script:result.Kind | Should -Be 'Hash'
                $script:result.DataType | Should -Be 'String'
                $script:result.Precision | Should -Be -1
            }
        }

        Context 'When called with valid Hash parameters and Precision not Specified' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind     = 'Hash'
                    DataType = 'String'
                    Verbose  = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.Index'
                $script:result.Kind | Should -Be 'Hash'
                $script:result.DataType | Should -Be 'String'
                $script:result.Precision | Should -Be -1
            }
        }

        Context 'When called with invalid Hash parameters' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind      = 'Hash'
                    DataType  = 'Point'
                    Precision = -1
                    Verbose   = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType `
                        -f $newCosmosDbCollectionIncludedPathIndexParameters.Kind, $newCosmosDbCollectionIncludedPathIndexParameters.DataType, 'String, Number')

                {
                    $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
                } | Should -Throw $errorMessage
            }
        }

        Context 'When called with valid Range parameters and Precision specified' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind      = 'Range'
                    DataType  = 'Number'
                    Precision = 2
                    Verbose   = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.Index'
                $script:result.Kind | Should -Be 'Range'
                $script:result.DataType | Should -Be 'Number'
                $script:result.Precision | Should -Be -1
            }
        }

        Context 'When called with valid Range parameters and Precision not Specified' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind     = 'Range'
                    DataType = 'Number'
                    Verbose  = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.Index'
                $script:result.Kind | Should -Be 'Range'
                $script:result.DataType | Should -Be 'Number'
                $script:result.Precision | Should -Be -1
            }
        }

        Context 'When called with invalid Range parameters' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind      = 'Range'
                    DataType  = 'Point'
                    Precision = -1
                    Verbose   = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType `
                        -f $newCosmosDbCollectionIncludedPathIndexParameters.Kind, $newCosmosDbCollectionIncludedPathIndexParameters.DataType, 'String, Number')

                {
                    $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
                } | Should -Throw $errorMessage
            }
        }

        Context 'When called with valid Spatial parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind     = 'Spatial'
                    DataType = 'Point'
                    Verbose  = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.Index'
                $script:result.Kind | Should -Be 'Spatial'
                $script:result.DataType | Should -Be 'Point'
                $script:result.Precision | Should -BeNull
            }
        }

        Context 'When called with invalid Spatial parameters' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind     = 'Spatial'
                    DataType = 'Number'
                    Verbose  = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType `
                        -f $newCosmosDbCollectionIncludedPathIndexParameters.Kind, $newCosmosDbCollectionIncludedPathIndexParameters.DataType, 'Point, Polygon, LineString')

                {
                    $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
                } | Should -Throw $errorMessage
            }
        }

        Context 'When called with invalid Spatial Precision parameters' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionIncludedPathIndexParameters = @{
                    Kind      = 'Spatial'
                    DataType  = 'Point'
                    Precision = 1
                    Verbose   = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionIncludedPathIndexPrecisionNotSupported `
                        -f $newCosmosDbCollectionIncludedPathIndexParameters.Kind)

                {
                    $script:result = New-CosmosDbCollectionIncludedPathIndex @newCosmosDbCollectionIncludedPathIndexParameters
                } | Should -Throw $errorMessage
            }
        }
    }

    Describe 'New-CosmosDbCollectionIncludedPath' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionIncludedPath -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathParameters = @{
                    Path    = '/*'
                    Index   = (New-CosmosDbCollectionIncludedPathIndex -Kind 'Range' -DataType 'String' -Precision -1)
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPath @newCosmosDbCollectionIncludedPathParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.IncludedPathIndex'
                $script:result.Path | Should -Be '/*'
                $script:result.Indexes[0].Kind | Should -Be 'Range'
                $script:result.Indexes[0].DataType | Should -Be 'String'
                $script:result.Indexes[0].Precision | Should -Be -1
            }
        }

        Context 'When called with path parameter only' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIncludedPathParameters = @{
                    Path    = '/*'
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionIncludedPath @newCosmosDbCollectionIncludedPathParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.IncludedPath'
                $script:result.Path | Should -Be '/*'
                $script:result.Indexes | Should -BeNullOrEmpty
            }
        }
    }

    Describe 'New-CosmosDbCollectionExcludedPath' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionExcludedPath -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionExcludedPathParameters = @{
                    Path    = '/*'
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionExcludedPath @newCosmosDbCollectionExcludedPathParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Path.ExcludedPath'
                $script:result.Path | Should -Be '/*'
            }
        }
    }

    Describe 'New-CosmosDbCollectionIndexingPolicy' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionIndexingPolicy -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionIndexingPolicyParameters = @{
                    Automatic      = $true
                    IndexingMode   = 'Consistent'
                    IncludedPath   = (New-CosmosDbCollectionIncludedPath -Path '/*' -Index (New-CosmosDbCollectionIncludedPathIndex -Kind 'Range' -DataType 'String' -Precision -1))
                    ExcludedPath   = (New-CosmosDbCollectionExcludedPath -Path '/*')
                    CompositeIndex = @(
                        @(
                            (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                            (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Ascending')
                        ),
                        @(
                            (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                            (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Descending')
                        )
                    )
                    Verbose        = $true
                }

                $script:result = New-CosmosDbCollectionIndexingPolicy @newCosmosDbCollectionIndexingPolicyParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.IndexingPolicy.Policy'
                $script:result.Automatic | Should -Be $true
                $script:result.IndexingMode | Should -Be 'Consistent'
                $script:result.IncludedPaths[0].Path | Should -Be '/*'
                $script:result.ExcludedPaths[0].Path | Should -Be '/*'
                $script:result.CompositeIndexes[0][0].Path | Should -Be '/name'
                $script:result.CompositeIndexes[0][0].Order | Should -Be 'ascending'
                $script:result.CompositeIndexes[0][1].Path | Should -Be '/age'
                $script:result.CompositeIndexes[0][1].Order | Should -Be 'ascending'
                $script:result.CompositeIndexes[1][0].Path | Should -Be '/name'
                $script:result.CompositeIndexes[1][0].Order | Should -Be 'ascending'
                $script:result.CompositeIndexes[1][1].Path | Should -Be '/age'
                $script:result.CompositeIndexes[1][1].Order | Should -Be 'descending'
            }
        }

        Context 'When called with IndexingMode of None and Automatic set to True parameters' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionIndexingPolicyParameters = @{
                    Automatic    = $true
                    IndexingMode = 'None'
                    Verbose      = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionIndexingPolicyInvalidMode)

                {
                    $script:result = New-CosmosDbCollectionIndexingPolicy @newCosmosDbCollectionIndexingPolicyParameters
                } | Should -Throw $errorMessage
            }
        }
    }

    Describe 'New-CosmosDbCollectionUniqueKey' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionUniqueKey -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionUniqueKeyParameters = @{
                    Path    = @('/uniquekey1', '/uniquekey2')
                    Verbose = $true
                }

                $script:result = New-CosmosDbCollectionUniqueKey @newCosmosDbCollectionUniqueKeyParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.UniqueKeyPolicy.UniqueKey'
                $script:result.paths[0] | Should -Be '/uniquekey1'
                $script:result.paths[1] | Should -Be '/uniquekey2'
            }
        }
    }

    Describe 'New-CosmosDbCollectionUniqueKeyPolicy' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollectionUniqueKeyPolicy -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionUniqueKeyPolicyParameters = @{
                    UniqueKey = @(
                        New-CosmosDbCollectionUniqueKey -Path @('/uniquekey1', '/uniquekey2')
                        New-CosmosDbCollectionUniqueKey -Path '/uniquekey3'
                    )
                    Verbose   = $true
                }

                $script:result = New-CosmosDbCollectionUniqueKeyPolicy @newCosmosDbCollectionUniqueKeyPolicyParameters
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType 'CosmosDB.UniqueKeyPolicy.Policy'
                $script:result.uniqueKeys[0].paths[0] | Should -Be '/uniquekey1'
                $script:result.uniqueKeys[0].paths[1] | Should -Be '/uniquekey2'
                $script:result.uniqueKeys[1].paths[0] | Should -Be '/uniquekey3'
            }
        }
    }

    Describe 'Get-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name Get-CosmosDbCollection -ErrorAction Stop
            } | Should -Not -Throw
        }

        BeforeEach {
            Mock `
                -CommandName Set-CosmosDbCollectionType `
                -MockWith { $Collection }
        }

        Context 'When called with context parameter and no Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultMulti }

            It 'Should not throw an exception' {
                $getCosmosDbCollectionParameters = @{
                    Context = $script:testContext
                    Verbose = $true
                }

                $script:result = Get-CosmosDbCollection @getCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testCollection1
                $script:result[1].id | Should -Be $script:testCollection2
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $getCosmosDbCollectionParameters = @{
                    Context = $script:testContext
                    Id      = $script:testCollection1
                    Verbose = $true
                }

                $script:result = Get-CosmosDbCollection @getCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) } `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and no Id but with MaxItemCount and ContinuationToken and with headers returned' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultMulti }

            It 'Should not throw an exception' {
                $script:ResponseHeader = $null

                $getCosmosDbCollectionParameters = @{
                    Context           = $script:testContext
                    MaxItemCount      = 5
                    ContinuationToken = 'token'
                    ResponseHeader    = [ref] $script:ResponseHeader
                    Verbose           = $true
                }

                $script:result = Get-CosmosDbCollection @getCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.Count | Should -Be 2
                $script:result[0].id | Should -Be $script:testCollection1
                $script:result[1].id | Should -Be $script:testCollection2
                $script:ResponseHeader.'x-ms-continuation' | Should -Be 'test'
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Get' -and $ResourceType -eq 'colls' -and $Headers['x-ms-continuation'] -eq 'token' -and $Headers['x-ms-max-item-count'] -eq 5 } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Get-CosmosDbCollectionSize' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name Get-CosmosDbCollectionSize -ErrorAction Stop
            } | Should -Not -Throw
        }
    }


    Describe 'New-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name New-CosmosDbCollection -ErrorAction Stop
            } | Should -Not -Throw
        }

        BeforeEach {
            Mock -CommandName Set-CosmosDbCollectionType -MockWith { $Collection }
        }

        Context 'When called with context parameter and an Id' {
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1
            }
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context = $script:testContext
                    Id      = $script:testCollection1
                    Verbose = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and a DefaultTimeToLive' {
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.defaultTtl -eq $script:testDefaultTimeToLive
            }
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context           = $script:testContext
                    Id                = $script:testCollection1
                    DefaultTimeToLive = $script:testDefaultTimeToLive
                    Verbose           = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and OfferThroughput parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $Headers['x-ms-offer-throughput'] -eq 400
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testCollection1
                    OfferThroughput = 400
                    Verbose         = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id parameter and OfferThroughput is greater than 10000 but PartitionKey is not specified' {
            $script:result = $null

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testCollection1
                    OfferThroughput = 20000
                    Verbose         = $true
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewCollectionParitionKeyOfferRequired

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with context parameter and an Id and OfferType parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $Headers['x-ms-offer-type'] -eq 'S2'
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context   = $script:testContext
                    Id        = $script:testCollection1
                    OfferType = 'S2'
                    Verbose   = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Id, AutoscaleThroughput and PartitionKey parameters' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                $ResourceType -eq 'colls' -and `
                $BodyObject.id -eq $script:testCollection1 -and `
                $Headers.'x-ms-cosmos-offer-autopilot-settings' -eq "{`"maxThroughput`":4000}"
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testCollection1
                    AutoscaleThroughput = 4000
                    PartitionKey        = 'partitionkey'
                    Verbose             = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and AutoscaleThroughput but without a PartitionKey parameter' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testCollection1
                    AutoscaleThroughput = 4000
                    Verbose             = $true
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewCollectionParitionKeyAutoscaleRequired

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with context parameter and an Id and AutoscaleThroughput and OfferThroughput parameter' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testCollection1
                    OfferThroughput     = 400
                    AutoscaleThroughput = 4000
                    Verbose             = $true
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewCollectionOfferParameterConflict

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with context parameter and an Id and AutoscaleThroughput and OfferType parameter' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testCollection1
                    OfferType           = 'S1'
                    AutoscaleThroughput = 4000
                    Verbose             = $true
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewCollectionOfferParameterConflict

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with context parameter and an Id and OfferThroughput and OfferType parameter' {
            $script:result = $null

            It 'Should throw expected exception' {
                $newCosmosDbCollectionParameters = @{
                    Context             = $script:testContext
                    Id                  = $script:testCollection1
                    OfferType           = 'S1'
                    OfferThroughput     = 400
                    Verbose             = $true
                }

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $LocalizedData.ErrorNewCollectionOfferParameterConflict

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorRecord
            }
        }

        Context 'When called with context parameter and an Id and an IndexingPolicy parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context        = $script:testContext
                    Id             = $script:testCollection1
                    IndexingPolicy = $script:testIndexingPolicy
                    Verbose        = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and an IndexingPolicyJson parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context            = $script:testContext
                    Id                 = $script:testCollection1
                    IndexingPolicyJson = $script:testIndexingPolicyJson
                    Verbose            = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and a UniqueKeyPolicy parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[0].paths[0] -eq $script:testUniqueKeyA.paths[0] -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[0].paths[1] -eq $script:testUniqueKeyA.paths[1] -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[1].paths[0] -eq $script:testUniqueKeyB.paths[0]
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testCollection1
                    UniqueKeyPolicy = $script:testUniqueKeyPolicy
                    Verbose         = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and PartitionKey parameter' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context      = $script:testContext
                    Id           = $script:testCollection1
                    PartitionKey = 'partitionkey'
                    Verbose      = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id parameter and PartitionKey parameter starting with ''/''' {
            $script:result = $null
            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Post' -and `
                    $ResourceType -eq 'colls' -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            It 'Should not throw an exception' {
                $newCosmosDbCollectionParameters = @{
                    Context      = $script:testContext
                    Id           = $script:testCollection1
                    PartitionKey = '/partitionkey'
                    Verbose      = $true
                }

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and OfferType and OfferThroughput' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultMulti }

            It 'Should throw expected exception' {
                $newCosmosDbCollectionParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testCollection1
                    OfferThroughput = 400
                    OfferType       = 'S1'
                    Verbose         = $true
                }

                $errorMessage = $($LocalizedData.ErrorNewCollectionOfferParameterConflict)

                {
                    $script:result = New-CosmosDbCollection @newCosmosDbCollectionParameters
                } | Should -Throw $errorMessage
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -Exactly -Times 0
            }
        }
    }

    Describe 'Remove-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name Remove-CosmosDbCollection -ErrorAction Stop
            } | Should -Not -Throw
        }

        Context 'When called with context parameter and an Id' {
            $script:result = $null

            Mock `
                -CommandName Invoke-CosmosDbRequest

            It 'Should not throw an exception' {
                $removeCosmosDbCollectionParameters = @{
                    Context = $script:testContext
                    Id      = $script:testCollection1
                    Verbose = $true
                }

                $script:result = Remove-CosmosDbCollection @removeCosmosDbCollectionParameters
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter { $Method -eq 'Delete' -and $ResourceType -eq 'colls' -and $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) } `
                    -Exactly -Times 1
            }
        }
    }

    Describe 'Set-CosmosDbCollection' -Tag 'Unit' {
        It 'Should exist' {
            {
                Get-Command -Name Set-CosmosDbCollection -ErrorAction Stop
            } | Should -Not -Throw
        }

        BeforeEach {
            Mock `
                -CommandName Set-CosmosDbCollectionType `
                -MockWith { $Collection }
        }

        Context 'When called with context parameter and an Id and IndexingPolicy parameter on a collection with no partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context        = $script:testContext
                    Id             = $script:testCollection1
                    IndexingPolicy = $script:testIndexingPolicy
                    Verbose        = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and IndexingPolicyJson parameter on a collection with no partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context            = $script:testContext
                    Id                 = $script:testCollection1
                    IndexingPolicyJson = $script:testIndexingPolicyJson
                    Verbose            = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }


        Context 'When called with context parameter and an Id and IndexingPolicy parameter on a collection with a partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection `
                -MockWith { @{ partitionKey = $script:testPartitionKey } }

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context        = $script:testContext
                    Id             = $script:testCollection1
                    IndexingPolicy = $script:testIndexingPolicy
                    Verbose        = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and IndexingPolicyJson parameter on a collection with a partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection `
                -MockWith { @{ partitionKey = $script:testPartitionKey } }

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context            = $script:testContext
                    Id                 = $script:testCollection1
                    IndexingPolicyJson = $script:testIndexingPolicyJson
                    Verbose            = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and UniqueKeyPolicy parameter on a collection with a partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[0].paths[0] -eq $script:testUniqueKeyA.paths[0] -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[0].paths[1] -eq $script:testUniqueKeyA.paths[1] -and `
                    $BodyObject.uniqueKeyPolicy.uniqueKeys[1].paths[0] -eq $script:testUniqueKeyB.paths[0] -and 1
                $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection `
                -MockWith { @{ partitionKey = $script:testPartitionKey } }

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context         = $script:testContext
                    Id              = $script:testCollection1
                    UniqueKeyPolicy = $script:testUniqueKeyPolicy
                    Verbose         = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and DefaultTimeToLive parameter on a collection with a partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.id -eq $script:testCollection1 -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind -and `
                    $BodyObject.defaultTtl -eq $script:testDefaultTimeToLive
            }
            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection `
                -MockWith { @{ partitionKey = $script:testPartitionKey } }

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context           = $script:testContext
                    Id                = $script:testCollection1
                    IndexingPolicy    = $script:testIndexingPolicy
                    DefaultTimeToLive = $script:testDefaultTimeToLive
                    Verbose           = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and RemoveDefaultTimeToLive parameter on a collection with a partition key' {
            $script:result = $null

            $invokecosmosdbrequest_parameterfilter = {
                $BodyObject = $Body | ConvertFrom-Json
                $Method -eq 'Put' -and `
                    $ResourceType -eq 'colls' -and `
                    $ResourcePath -eq ('colls/{0}' -f $script:testCollection1) -and `
                    $BodyObject.indexingPolicy.automatic -eq $script:testIndexingPolicy.automatic -and `
                    $BodyObject.indexingPolicy.indexingMode -eq $script:testIndexingPolicy.indexingMode -and `
                    $BodyObject.partitionKey.paths[0] -eq $script:testPartitionKey.paths[0] -and `
                    $BodyObject.partitionKey.kind -eq $script:testPartitionKey.kind
            }

            $getcosmosdbcollection_parameterfilter = {
                $Id -eq $script:testCollection1
            }

            Mock `
                -CommandName Invoke-CosmosDbRequest `
                -MockWith { $script:testGetCollectionResultSingle }

            Mock `
                -CommandName Get-CosmosDbCollection `
                -MockWith {
                @{
                    partitionKey = $script:testPartitionKey
                    defaultTtl   = $script:testDefaultTimeToLive
                }
            }

            It 'Should not throw an exception' {
                $setCosmosDbCollectionParameters = @{
                    Context                 = $script:testContext
                    Id                      = $script:testCollection1
                    IndexingPolicy          = $script:testIndexingPolicy
                    RemoveDefaultTimeToLive = $true
                    Verbose                 = $true
                }

                $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
            }

            It 'Should return expected result' {
                $script:result.id | Should -Be $script:testCollection1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-CosmosDbRequest `
                    -ParameterFilter $invokecosmosdbrequest_parameterfilter `
                    -Exactly -Times 1

                Assert-MockCalled `
                    -CommandName Get-CosmosDbCollection `
                    -ParameterFilter $getcosmosdbcollection_parameterfilter `
                    -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and an Id and DefaultTimeToLive and RemoveDefaultTimeToLive parameter' {
            $script:result = $null

            It 'Should throw exepected exception' {
                $setCosmosDbCollectionParameters = @{
                    Context                 = $script:testContext
                    Id                      = $script:testCollection1
                    DefaultTimeToLive       = $script:testDefaultTimeToLive
                    RemoveDefaultTimeToLive = $true
                    Verbose                 = $true
                }

                $errorMessage = $LocalizedData.ErrorSetCollectionRemoveDefaultTimeToLiveConflict

                {
                    $script:result = Set-CosmosDbCollection @setCosmosDbCollectionParameters
                } | Should -Throw $errorMessage
            }
        }
    }
}
