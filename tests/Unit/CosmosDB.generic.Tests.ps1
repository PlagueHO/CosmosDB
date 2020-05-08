[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module -Name $ProjectName -Force

$modulePath = (Get-Module -Name $ProjectName).Path
$moduleManifestPath = Join-Path -Path ((Get-Module -Name $ProjectName).ModuleBase) -ChildPath "$ProjectName.psd1"
$scriptAnalyzerSettingsPath = "$ProjectPath\PSScriptAnalyzerSettings.psd1"

Describe 'CosmosDB Module' {
    if ($PSVersionTable.PSVersion.Major -eq 6 -and $PSVersionTable.PSVersion -lt [System.Version] '6.2.4')
    {
        Write-Warning -Message ('Minimum supported version of PSScriptAnalyzer for PowerShell Core is 6.2.4 but current version is "{0}".' -f $PSVersionTable.PSVersion)
    }
    else
    {
        Context 'PowerShell Script Analyzer' {
            Import-Module -Name PSScriptAnalyzer

            # Perform PSScriptAnalyzer scan
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                -Path $moduleManifestPath `
                -Settings $scriptAnalyzerSettingsPath `
                -ErrorAction SilentlyContinue `
                -Verbose:$false
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -Path $modulePath `
                -Recurse `
                -Settings $scriptAnalyzerSettingsPath `
                -ErrorAction SilentlyContinue `
                -Verbose:$false

            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object {
                $_.Severity -eq 'Error'
            }

            It 'Should have no Error level PowerShell Script Analyzer violations' {
                if ($PSScriptAnalyzerErrors -ne $null)
                {
                    Write-Warning -Message 'There are Error level PowerShell Script Analyzer violations that must be fixed:'

                    foreach ($violation in $PSScriptAnalyzerErrors)
                    {
                        Write-Warning -Message "$($violation.Scriptname) (Line $($violation.Line)): $($violation.Message)"
                    }

                    Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'

                    $PSScriptAnalyzerErrors.Count | Should -BeNullOrEmpty
                }
            }

            It 'Should have no Warning level PowerShell Script Analyzer violations' {
                $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object {
                    $_.Severity -eq 'Warning'
                }

                if ($PSScriptAnalyzerWarnings -ne $null)
                {
                    Write-Warning -Message 'There are Warning level PowerShell Script Analyzer violations that should be fixed:'

                    foreach ($violation in $PSScriptAnalyzerWarnings)
                    {
                        Write-Warning -Message "$($violation.Scriptname) (Line $($violation.Line)): $($violation.Message)"
                    }

                    Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                }
            }

            It 'Should have no Information level PowerShell Script Analyzer violations' {
                $PSScriptAnalyzerInformation = $PSScriptAnalyzerResult | Where-Object {
                    $_.Severity -eq 'Information'
                }

                if ($PSScriptAnalyzerInformation -ne $null)
                {
                    Write-Warning -Message 'There are Information level PowerShell Script Analyzer violations that must be fixed:'

                    foreach ($violation in $PSScriptAnalyzerInformation)
                    {
                        Write-Warning -Message "$($violation.Scriptname) (Line $($violation.Line)): $($violation.Message)"
                    }

                    Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'

                    $PSScriptAnalyzerErrors.Count | Should -Be $null
                }
            }
        }
    }

    Context 'Module Manifest' {
        It 'Should have a valid manifest' {
            $script:moduleManifest = Test-ModuleManifest -Path $moduleManifestPath
            $script:moduleManifest | Should -Not -BeNullOrEmpty
        }

        It 'Should have less than 10000 characters in the release notes of the module manifest' {
            $script:moduleManifest.ReleaseNotes.Length | Should -BeLessThan 10000
        }
    }
}
