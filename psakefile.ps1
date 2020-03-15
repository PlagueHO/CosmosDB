# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Prepare the folder variables
    $ProjectRoot = $ENV:BHProjectPath

    if (-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }

    $ModuleName = 'CosmosDB'
    $Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $separator = '----------------------------------------------------------------------'
}

Task Default -Depends Test, Build

Task Init {
    Set-Location -Path $ProjectRoot

    # Install any dependencies required for the Init stage
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Init'

    Set-BuildEnvironment -Force

    $separator
    'Build System Details:'
    Get-Item -Path ENV:BH*
    "`n"

    $separator
    'Other Environment Variables:'
    Get-ChildItem -Path ENV:
    "`n"

    $separator
    'PowerShell Details:'
    $PSVersionTable
    "`n"
}

Task PrepareTest -Depends Init {
    # Install any dependencies required for testing
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Test'
}

Task Test -Depends UnitTest, IntegrationTest

Task UnitTest -Depends Init, PrepareTest {
    $separator

    # Execute tests
    $testScriptsPath = Join-Path -Path $ProjectRoot -ChildPath 'test\Unit'
    $testResultsFile = Join-Path -Path $testScriptsPath -ChildPath 'TestResults.unit.xml'
    $codeCoverageFile = Join-Path -Path $testScriptsPath -ChildPath 'CodeCoverage.xml'
    $codeCoverageSource = Get-ChildItem -Path (Join-Path -Path $ProjectRoot -ChildPath 'src\lib\*.ps1') -Recurse
    $testResults = Invoke-Pester `
        -Script $testScriptsPath `
        -OutputFormat NUnitXml `
        -OutputFile $testResultsFile `
        -PassThru `
        -ExcludeTag Incomplete `
        -CodeCoverage $codeCoverageSource `
        -CodeCoverageOutputFile $codeCoverageFile `
        -CodeCoverageOutputFileFormat JaCoCo

    # Prepare and uploade code coverage
    if ($testResults.CodeCoverage)
    {
        'Preparing CodeCoverage'
        Import-Module `
            -Name (Join-Path -Path $ProjectRoot -ChildPath '.codecovio\CodeCovio.psm1')

        $jsonPath = Export-CodeCovIoJson `
            -CodeCoverage $testResults.CodeCoverage `
            -RepoRoot $ProjectRoot

        'Uploading CodeCoverage to CodeCov.io'
        try
        {
            Invoke-UploadCodeCovIoReport -Path $jsonPath
        }
        catch
        {
            # CodeCov currently reports an error when uploading
            # This is not fatal and can be ignored
            Write-Warning -Message $_
        }
    }
    else
    {
        Write-Warning -Message 'Could not create CodeCov.io report because pester results object did not contain a CodeCoverage object'
    }

    if ($testResults.FailedCount -gt 0)
    {
        Write-Error -Exception "$($testResults.FailedCount) unit tests failed."
    }

    "`n"
}

Task IntegrationTest -Depends Init, PrepareTest {
    $separator

    # Execute tests
    $testScriptsPath = Join-Path -Path $ProjectRoot -ChildPath 'test\Integration'

    if ($TestStagedModule)
    {
        # Get the path to the staged module
        $stagingFolder = Join-Path -Path $ProjectRoot -ChildPath 'staging'
        $stagedModulesFolder = Join-Path -Path $stagingFolder -ChildPath $ModuleName
        $mostRecentStagedModulePath = Get-MostRecentStagedModulePath -StagedModulesFolder $stagedModulesFolder
        $testScript = @{
            Path = $testScriptsPath
            Parameters = @{
                ModuleRootPath = $mostRecentStagedModulePath
            }
        }
        "Executing integration tests on Staged Module in $mostRecentStagedModulePath"
    }
    else
    {
        "Executing integration tests on src folder"
        $testScript = $testScriptsPath
    }

    $testResultsFile = Join-Path -Path $testScriptsPath -ChildPath 'TestResults.integration.xml'
    $testResults = Invoke-Pester `
        -Script $testScript `
        -OutputFormat NUnitXml `
        -OutputFile $testResultsFile `
        -PassThru `
        -ExcludeTag Incomplete

    if ($testResults.FailedCount -gt 0)
    {
        Write-Error -Exception "$($testResults.FailedCount) integration tests failed."
    }

    "`n"
}

Task Build -Depends Init {
    $separator

    # Install any dependencies required for the Build stage
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Build'

    # Build the Classes
    $classesProjectFolder = Join-Path -Path $ProjectRoot -ChildPath 'src/classes/CosmosDB'
    $classesProjectPath = Join-Path -Path $classesProjectFolder -ChildPath 'CosmosDB.csproj'
    & dotnet @('build',$classesProjectPath,'/p:Configuration=Release')

    # Generate the next version by adding the build system build number to the manifest version
    $manifestPath = Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psd1"
    $newVersion = Get-VersionNumber `
        -ManifestPath $manifestPath `
        -Build $ENV:BHBuildNumber

    # Determine the folder names for staging the module
    $stagingFolder = Join-Path -Path $ProjectRoot -ChildPath 'staging'
    $moduleFolder = Join-Path -Path $stagingFolder -ChildPath $ModuleName

    # Determine the folder names for staging the module
    $versionFolder = Join-Path -Path $moduleFolder -ChildPath $newVersion

    # Stage the module
    $null = New-Item -Path $stagingFolder -Type directory -ErrorAction SilentlyContinue
    $null = New-Item -Path $moduleFolder -Type directory -ErrorAction SilentlyContinue
    Remove-Item -Path $versionFolder -Recurse -Force -ErrorAction SilentlyContinue
    $null = New-Item -Path $versionFolder -Type directory

    # Populate Version Folder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psm1") -Destination $versionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/formats') -Destination $versionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/types') -Destination $versionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/en-US') -Destination $versionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'LICENSE') -Destination $versionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'README.md') -Destination $versionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'CHANGELOG.md') -Destination $versionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'RELEASENOTES.md') -Destination $versionFolder
    $null = Copy-Item -Path (Join-Path -Path $classesProjectFolder -ChildPath 'bin/release/netstandard2.0/CosmosDB.dll') -Destination $versionFolder

    # Load the Libs files into the PSM1
    $libFiles = Get-ChildItem `
        -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/lib') `
        -Include '*.ps1' `
        -Recurse

    # Assemble all the libs content into a single string
    $libFilesStringBuilder = [System.Text.StringBuilder]::new()

    foreach ($libFile in $libFiles)
    {
        $libContent = Get-Content -Path $libFile -Raw
        $null = $libFilesStringBuilder.AppendLine($libContent)
    }

    <#
        Load the PSM1 file into an array of lines and step through each line
        adding it to a string builder if the line is not part of the ImportFunctions
        Region. Then add the content of the $libFilesStringBuilder string builder
        immediately following the end of the region.
    #>
    $modulePath = Join-Path -Path $versionFolder -ChildPath "$ModuleName.psm1"
    $moduleContent = Get-Content -Path $modulePath
    $moduleStringBuilder = [System.Text.StringBuilder]::new()
    $importFunctionsRegionFound = $false

    foreach ($moduleLine in $moduleContent)
    {
        if ($importFunctionsRegionFound)
        {
            if ($moduleLine -eq '#endregion')
            {
                $null = $moduleStringBuilder.AppendLine('#region Functions')
                $null = $moduleStringBuilder.AppendLine($libFilesStringBuilder)
                $null = $moduleStringBuilder.AppendLine('#endregion')
                $importFunctionsRegionFound = $false
            }
        }
        else
        {
            if ($moduleLine -eq '#region ImportFunctions')
            {
                $importFunctionsRegionFound = $true
            }
            else
            {
                $null = $moduleStringBuilder.AppendLine($moduleLine)
            }
        }
    }

    Set-Content -Path $modulePath -Value $moduleStringBuilder -Force

    # Prepare external help
    'Building external help file'
    New-ExternalHelp `
        -Path (Join-Path -Path $ProjectRoot -ChildPath 'docs\') `
        -OutputPath $versionFolder `
        -Force

    # Create the module manifest in the staging folder
    'Updating module manifest'
    $stagedManifestPath = Join-Path -Path $versionFolder -ChildPath "$ModuleName.psd1"
    $tempManifestPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "$ModuleName.psd1"

    Import-LocalizedData `
        -BindingVariable 'stagedManifestContent' `
        -FileName "$ModuleName.psd1" `
        -BaseDirectory (Join-Path -Path $ProjectRoot -ChildPath 'src')
    $stagedManifestContent.ModuleVersion = $newVersion
    $stagedManifestContent.Copyright = "(c) $((Get-Date).Year) Daniel Scott-Raynsford. All rights reserved."

    # Extract the PrivateData values and remove it because it can not be splatted
    'LicenseUri','Tags','ProjectUri','IconUri','ReleaseNotes' | Foreach-Object -Process {
        $privateDataValue = $stagedManifestContent.PrivateData.PSData.$_

        if ($privateDataValue)
        {
            $null = $stagedManifestContent.Add($_, $privateDataValue)
        }
    }

    $stagedManifestContent.ReleaseNotes = $stagedManifestContent.ReleaseNotes -replace "## What is New in $ModuleName Unreleased", "## What is New in $ModuleName $newVersion"
    $stagedManifestContent.Remove('PrivateData')

    # Create the module manifest file
    New-ModuleManifest `
        -Path $tempManifestPath `
        @stagedManifestContent

    # Make sure the manifest is encoded as UTF8 and remove trailing whitespace
    'Convert manifest to UTF8 and trim trailing whitespace'
    $temporaryManifestContent = Get-Content -Path $tempManifestPath
    $trimmedManifestContent = $temporaryManifestContent.TrimEnd()
    $utf8NoBomEncoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList ($false)
    [System.IO.File]::WriteAllLines($stagedManifestPath, $trimmedManifestContent, $utf8NoBomEncoding)

    # Remove the temporary manifest
    $null = Remove-Item -Path $tempManifestPath -Force

    # Validate the module manifest
    if (-not (Test-ModuleManifest -Path $stagedManifestPath))
    {
        throw "The generated module manifest '$stagedManifestPath' was invalid"
    }

    # Set the new version number in the staged CHANGELOG.md
    'Updating CHANGELOG.MD'
    $stagedChangeLogPath = Join-Path -Path $versionFolder -ChildPath 'CHANGELOG.md'
    $stagedChangeLogContent = Get-Content -Path $stagedChangeLogPath -Raw
    $stagedChangeLogContent = $stagedChangeLogContent -replace '# Unreleased', "# $newVersion"
    Set-Content -Path $stagedChangeLogPath -Value $stagedChangeLogContent -NoNewLine -Force

    # Set the new version number in the staged RELEASENOTES.md
    'Updating RELEASENOTES.MD'
    $stagedReleaseNotesPath = Join-Path -Path $versionFolder -ChildPath 'RELEASENOTES.md'
    $stagedReleaseNotesContent = Get-Content -Path $stagedReleaseNotesPath -Raw
    $stagedReleaseNotesContent = $stagedReleaseNotesContent -replace "## What is New in $ModuleName Unreleased", "## What is New in $ModuleName $newVersion"
    Set-Content -Path $stagedReleaseNotesPath -Value $stagedReleaseNotesContent -NoNewLine -Force

    # Create zip artifact
    $zipFileFolder = Join-Path `
        -Path $stagingFolder `
        -ChildPath 'zip'

    $null = New-Item -Path $zipFileFolder -Type directory -ErrorAction SilentlyContinue

    $zipFilePath = Join-Path `
        -Path $zipFileFolder `
        -ChildPath "${ENV:BHProjectName}_$newVersion.zip"

    if (Test-Path -Path $zipFilePath)
    {
        $null = Remove-Item -Path $zipFilePath
    }
    $null = Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($moduleFolder, $zipFilePath)

    # Update the Git Repo if this is the master branch build in Azure Pipelines
    if ($ENV:BHBuildSystem -eq 'Azure Pipelines')
    {
        if ($ENV:BHBranchName -eq 'master')
        {
            # This is a push to master so update GitHub with release info
            'Beginning update to master branch with deployed information'

            $commitMessage = $ENV:BHCommitMessage.TrimEnd()
            "Commit to master branch triggered with commit message: '$commitMessage'"

            if ($commitMessage -match '^Azure DevOps Deploy updating Version Number to [0-9/.]*')
            {
                # This was a deploy commit so no need to do anything
                'Skipping update to master branch with deployed information because this was triggered by Azure DevOps Updating the Version Number'
            }
            else
            {
                # Pull the master branch, update the readme.md and manifest
                Set-Location -Path $ProjectRoot

                Invoke-Git -GitParameters @('config', '--global', 'credential.helper', 'store')

                # Configure Azure DevOps to be able to Push back to GitHub
                Add-Content `
                    -Path "$ENV:USERPROFILE\.git-credentials" `
                    -Value "https://$($ENV:githubRepoToken):x-oauth-basic@github.com`n"

                Invoke-Git -GitParameters @('config', '--global', 'user.email', 'plagueho@gmail.com')
                Invoke-Git -GitParameters @('config', '--global', 'user.name', 'Daniel Scott-Raynsford')

                'Display list of Git Remotes'
                Invoke-Git -GitParameters @('remote', '-v')
                Invoke-Git -GitParameters @('checkout', '-f', 'master')

                # Replace the manifest with the one that was published
                'Updating files changed during deployment'
                Copy-Item `
                    -Path $stagedManifestPath `
                    -Destination (Join-Path -Path $ProjectRoot -ChildPath 'src') `
                    -Force
                Copy-Item `
                    -Path $stagedChangeLogPath `
                    -Destination $ProjectRoot `
                    -Force
                Copy-Item `
                    -Path $stagedReleaseNotesPath `
                    -Destination $ProjectRoot `
                    -Force

                'Adding updated module files to commit'
                Invoke-Git -GitParameters @('add', '.')

                "Creating new commit for 'Azure DevOps Deploy updating Version Number to $NewVersion'"
                Invoke-Git -GitParameters @('commit', '-m', "Azure DevOps Deploy updating Version Number to $NewVersion")

                "Adding $newVersion tag to Master"
                Invoke-Git -GitParameters @('tag', '-a', '-m', $newVersion, $newVersion)

                # Update the master branch
                'Pushing deployment changes to Master'
                Invoke-Git -GitParameters @('status')
                Invoke-Git -GitParameters @('push')

                # Merge the changes to the Master branch into the Dev branch
                'Pushing deployment changes to Dev'
                Invoke-Git -GitParameters @('checkout', '-f', 'dev')
                Invoke-Git -GitParameters @('merge', 'origin/master')
                Invoke-Git -GitParameters @('push')
            }
        }
        else
        {
            "Skipping update to master branch with deployed information because branch is: '$ENV:BHBranchName'"
        }
    }
    else
    {
        "Skipping update to master branch with deployed information because build system is: '$ENV:BHBuildSystem'"
    }
    "`n"
}

Task Deploy {
    $separator

    # Determine the folder name for the Module
    $moduleFolder = Join-Path -Path $ProjectRoot -ChildPath $ModuleName

    # Install any dependencies required for the Deploy stage
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Deploy'

    # Copy the module to the PSModulePath
    $PSModulePath = ($ENV:PSModulePath -split ';')[0]
    $destinationPath = Join-Path -Path $PSModulePath -ChildPath $ModuleName

    "Copying Module from $moduleFolder to $destinationPath"
    Copy-Item `
        -Path $moduleFolder `
        -Destination $destinationPath `
        -Container `
        -Recurse `
        -Force

    $installedModule = Get-Module -Name $ModuleName -ListAvailable

    $versionNumber = $installedModule.Version |
        Sort-Object -Descending |
        Select-Object -First 1

    if (-not $versionNumber)
    {
        Throw "$ModuleName Module could not be found after copying to $PSModulePath"
    }

    # This is a deploy from the staging folder
    "Publishing $ModuleName Module version '$versionNumber' to PowerShell Gallery"
    $null = Get-PackageProvider `
        -Name NuGet `
        -ForceBootstrap

    Publish-Module `
        -Name $ModuleName `
        -RequiredVersion $versionNumber `
        -NuGetApiKey $ENV:PowerShellGalleryApiKey `
        -Confirm:$false
}

<#
    .SYNOPSIS
        Generate a new version number.
#>
function Get-VersionNumber
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ManifestPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Build
    )

    # Get version number from the existing manifest
    $manifestContent = Get-Content -Path $ManifestPath -Raw
    $regex = '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')'
    $matches = @([regex]::matches($manifestContent, $regex, 'IgnoreCase'))
    $version = $null

    if ($matches)
    {
        $version = $matches[0].Value
    }

    # Determine the new version number
    $versionArray = $version -split '\.'
    $newVersion = ''

    foreach ($ver in (0..2))
    {
        $sem = $versionArray[$ver]

        if ([String]::IsNullOrEmpty($sem))
        {
            $sem = '0'
        }

        $newVersion += "$sem."
    }

    $newVersion += $Build
    return $newVersion
}

<#
    .SYNOPSIS
        Safely execute a Git command.
#>
function Invoke-Git
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $GitParameters
    )

    try
    {
        "Executing 'git $($GitParameters -join ' ')'"
        exec { & git $GitParameters }
    }
    catch
    {
        Write-Warning -Message $_
    }
}

<#
    .SYNOPSIS
        Get path to most recent staged module.

    .PARAMETER StagedModulesFolder
        Path to folder containing staged modules.
#>
function Get-MostRecentStagedModulePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $StagedModulesFolder
    )

    $stagedModules = Get-ChildItem -Path $StagedModulesFolder

    if ($null -eq $stagedModules)
    {
        throw 'There are no currently staged modules in {0}' -f $StagedModulesFolder
    }

    return ($stagedModules | Sort-Object -Property Name -Descending | Select-Object -First 1).Fullname
}
