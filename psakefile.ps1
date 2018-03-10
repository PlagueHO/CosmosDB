# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Prepare the folder variables
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }

    # Determine the folder names for staging the module
    $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath 'staging'
    $ModuleFolder = Join-Path -Path $StagingFolder -ChildPath 'CosmosDB'

    $Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $separator = '----------------------------------------------------------------------'
}

Task Default -Depends Build

Task Init {
    $separator

    Set-Location -Path $ProjectRoot
    'Build System Details:'
    Get-Item -Path ENV:BH*
    "`n"
    'PowerShell Details:'
    $PSVersionTable

    "`n"
}

Task Test -Depends Init {
    $separator

    # Execute tests
    $testResultsFile = Join-Path -Path $ProjectRoot -ChildPath 'test\TestsResults.xml'
    $testResults = Invoke-Pester `
        -OutputFormat NUnitXml `
        -OutputFile $testResultsFile `
        -PassThru `
        -ExcludeTag Incomplete `
        -CodeCoverage @( Join-Path -Path $ProjectRoot -ChildPath 'src\lib\*.ps1' )

    # Prepare and uploade code coverage
    if ($testResults.CodeCoverage)
    {
        'Preparing CodeCoverage'
        Import-Module `
            -Name (Join-Path -Path $ProjectRoot -ChildPath '.codecovio\CodeCovio.psm1')

        $jsonPath = Export-CodeCovIoJson `
            -CodeCoverage $testResults.CodeCoverage `
            -RepoRoot $ProjectRoot

        if ($ENV:BHBuildSystem -eq 'AppVeyor')
        {
            'Uploading CodeCoverage to CodeCov.io'
            try
            {
                Invoke-UploadCoveCoveIoReport -Path $jsonPath
            }
            catch
            {
                # CodeCov currently reports an error when uploading
                # This is not fatal and can be ignored
                Write-Warning -Message $_
            }
        }
    }
    else
    {
        Write-Warning -Message 'Could not create CodeCov.io report because pester results object did not contain a CodeCoverage object'
    }

    # Upload tests
    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        'Publishing test results to AppVeyor'
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            (Resolve-Path $testResultsFile))

        "Publishing test results to AppVeyor as Artifact"
        Push-AppveyorArtifact $testResultsFile

        if ($testResults.FailedCount -gt 0)
        {
            throw "$($testResults.FailedCount) tests failed."
        }
    }
    else
    {
        if ($testResults.FailedCount -gt 0)
        {
            Write-Error -Exception "$($testResults.FailedCount) tests failed."
        }
    }

    "`n"
}

Task Build -Depends Test {
    $separator

    # Generate the next version by adding the build system build number to the manifest version
    $manifestPath = Join-Path -Path $ProjectRoot -ChildPath 'src/CosmosDB.psd1'
    $newVersion = Get-NewVersionNumber `
        -ManifestPath $manifestPath `
        -Build $ENV:BHBuildNumber

    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        # Update AppVeyor build version number
        Update-AppveyorBuild -Version $newVersion
    }

    # Determine the folder names for staging the module
    $VersionFolder = Join-Path -Path $ModuleFolder -ChildPath $newVersion

    # Stage the module
    $null = New-Item -Path $StagingFolder -Type directory -ErrorAction SilentlyContinue
    $null = New-Item -Path $ModuleFolder -Type directory -ErrorAction SilentlyContinue
    Remove-Item -Path $VersionFolder -Recurse -Force -ErrorAction SilentlyContinue
    $null = New-Item -Path $VersionFolder -Type directory

    # Populate Version Folder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/CosmosDB.psd1') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/CosmosDB.psm1') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/lib') -Destination $VersionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/formats') -Destination $VersionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/types') -Destination $VersionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/en-us') -Destination $VersionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'LICENSE') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'README.md') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'CHANGELOG.md') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'RELEASENOTES.md') -Destination $VersionFolder

    # Prepare external help
    'Building external help file'
    New-ExternalHelp `
        -Path (Join-Path -Path $ProjectRoot -ChildPath 'docs\') `
        -OutputPath $VersionFolder `
        -Force

    # Set the new version number in the staged Module Manifest
    'Updating module manifest'
    $stagedManifestPath = Join-Path -Path $VersionFolder -ChildPath 'CosmosDB.psd1'
    $stagedManifestContent = Get-Content -Path $stagedManifestPath -Raw
    $stagedManifestContent = $stagedManifestContent -replace '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')', $newVersion
    $stagedManifestContent = $stagedManifestContent -replace '## What is New in CosmosDB Unreleased', "## What is New in CosmosDB $newVersion"
    Set-Content -Path $stagedManifestPath -Value $stagedManifestContent -NoNewLine -Force

    # Set the new version number in the staged CHANGELOG.md
    'Updating CHANGELOG.MD'
    $stagedChangeLogPath = Join-Path -Path $VersionFolder -ChildPath 'CHANGELOG.md'
    $stagedChangeLogContent = Get-Content -Path $stagedChangeLogPath -Raw
    $stagedChangeLogContent = $stagedChangeLogContent -replace '# Unreleased', "# $newVersion"
    Set-Content -Path $stagedChangeLogPath -Value $stagedChangeLogContent -NoNewLine -Force

    # Set the new version number in the staged RELEASENOTES.md
    'Updating RELEASENOTES.MD'
    $stagedReleaseNotesPath = Join-Path -Path $VersionFolder -ChildPath 'RELEASENOTES.md'
    $stagedReleaseNotesContent = Get-Content -Path $stagedReleaseNotesPath -Raw
    $stagedReleaseNotesContent = $stagedReleaseNotesContent -replace '## What is New in CosmosDB Unreleased', "## What is New in CosmosDB $newVersion"
    Set-Content -Path $stagedReleaseNotesPath -Value $stagedReleaseNotesContent -NoNewLine -Force
}

Task Deploy -Depends Build {
    $separator

    # Generate the next version by adding the build system build number to the manifest version
    $manifestPath = Join-Path -Path $ProjectRoot -ChildPath 'src/CosmosDB.psd1'
    $newVersion = Get-NewVersionNumber `
        -ManifestPath $manifestPath `
        -Build $ENV:BHBuildNumber

    # Determine the folder names for staging the module
    $VersionFolder = Join-Path -Path $ModuleFolder -ChildPath $newVersion

    # Copy the module to the PSModulePath
    $PSModulePath = ($ENV:PSModulePath -split ';')[0]

    "Copying Module to $PSModulePath"
    Copy-Item `
        -Path $ModuleFolder `
        -Destination $PSModulePath `
        -Recurse `
        -Force

    # Create zip artifact
    $zipFilePath = Join-Path `
        -Path $StagingFolder `
        -ChildPath "${ENV:BHProjectName}_${ENV:BHBuildNumber}.zip"
    $null = Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($ModuleFolder, $zipFilePath)

    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        # If AppVeyor, publish the deploy artefacts for debug purposes
        "Pushing package $zipFilePath as Appveyor artifact"
        Push-AppveyorArtifact $zipFilePath
        Remove-Item -Path $zipFilePath -Force

        <#
            If this is a build of the Master branch and not a PR push
            then publish the Module to the PowerShell Gallery.
        #>
        if ($ENV:BHBranchName -eq 'master')
        {
            if ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)
            {
                # This is a PR so do nothing
                'Skipping deployment because this is a Pull Request'
            }
            elseif ($ENV:BHCommitMessage -like '* Deploy!')
            {
                # This was a deploy commit so no need to do anything
                'Skipping deployment because this was a commit triggered by a deployment'
            }
            else
            {
                # This is a commit to Master
                'Publishing Module to PowerShell Gallery'
                Get-PackageProvider `
                    -Name NuGet `
                    -ForceBootstrap
                Publish-Module `
                    -Name 'CosmosDB' `
                    -RequiredVersion $newVersion `
                    -NuGetApiKey $ENV:PowerShellGalleryApiKey `
                    -Confirm:$false

                # This is not a PR so deploy
                'Beginning update to master branch with deployed information'

                # Pull the master branch, update the readme.md and manifest
                Set-Location -Path $ProjectRoot
                exec { git @('config', '--global', 'credential.helper', 'store') }

                Add-Content `
                    -Path "$env:USERPROFILE\.git-credentials" `
                    -Content "https://$($env:GitHubPushFromPlagueHO):x-oauth-basic@github.com`n"

                exec { git @('config', '--global', 'user.email', 'plagueho@gmail.com') }
                exec { git @('config', '--global', 'user.name', 'Daniel Scott-Raynsford') }

                exec { git @('checkout', '-f', 'master') }

                # Replace the manifest with the one that was published
                Copy-Item `
                    -Path (Join-Item -Path $VersionFolder -ChildPath 'CosmosDB.psd1') `
                    -Destination $ModuleFolder `
                    -Force
                Copy-Item `
                    -Path (Join-Item -Path $VersionFolder -ChildPath 'CHANGELOG.MD') `
                    -Destination $ModuleFolder `
                    -Force
                Copy-Item `
                    -Path (Join-Item -Path $VersionFolder -ChildPath 'RELEASENOTES.MD') `
                    -Destination $ModuleFolder `
                    -Force

                # Update the master branch
                'Pushing deployment changes to Master'
                exec { git @('add', '.') }
                exec { git @('commit', '-m', "$NewVersion Deploy!") }
                exec { git @('status') }
                exec { git @('push', 'origin', 'master') }

                # Create the version tag and push it
                "Pushing $newVersion tag to Master"
                exec { git @('tag', '-a', $newVersion, '-m', $newVersion) }
                exec { git @('push', 'origin', $newVersion) }

                # Merge the changes to the Dev branch as well
                'Pushing deployment changes to Dev'
                exec { git @('checkout', '-f', 'dev') }
                exec { git @('merge', 'master') }
                exec { git @('push', 'origin', 'dev') }
            }
        }
    }
}

function Get-NewVersionNumber
{
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
    Foreach ($ver in (0..2))
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
