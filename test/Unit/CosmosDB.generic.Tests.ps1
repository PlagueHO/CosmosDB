[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$moduleManifestName = 'CosmosDB.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $moduleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}

Describe 'CosmosDB Module'{
    Context 'PSScriptAnalyzer' {
        Import-Module -Name 'PSScriptAnalyzer'

        $modulePath = Join-Path -Path $moduleRootPath -ChildPath 'CosmosDB.psm1'

        # Perform PSScriptAnalyzer scan
        $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
            -Path $modulePath `
            -Settings (Join-Path -Path $moduleRootPath -ChildPath '..\PSScriptAnalyzerSettings.psd1') `
            -ErrorAction SilentlyContinue
        $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
            -Path (Join-Path -Path $moduleRootPath -ChildPath 'lib') `
            -Recurse `
            -Settings (Join-Path -Path $moduleRootPath -ChildPath '..\PSScriptAnalyzerSettings.psd1') `
            -ErrorAction SilentlyContinue

        $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object {
            $_.Severity -eq 'Error'
        }

        It 'Should have no Error level PowerShell Script Analyzer violations' {
            if ($PSScriptAnalyzerErrors -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer errors that must be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
                Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors.Count | Should -Be $null
            }
        }

        It 'Should have no Warning level PowerShell Script Analyzer violations' {
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object {
                $_.Severity -eq 'Warning'
            }

            if ($PSScriptAnalyzerWarnings -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer warnings that should be fixed:'
                @($PSScriptAnalyzerWarnings).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
            }
        }

        It 'Should have no Information level PowerShell Script Analyzer violations' -Skip:$true {
            Write-Verbose -Message 'Hello' -Verbose
            $PSScriptAnalyzerInformation = $PSScriptAnalyzerResult | Where-Object {
                $_.Severity -eq 'Information'
            }

            if ($PSScriptAnalyzerInformation -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer informational issues that should be fixed:'
                @($PSScriptAnalyzerInformation).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
            }
        }
    }

    Context 'Manifest' {
        $moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath 'CosmosDB.psd1'

        It 'Should have a valid manifest' {
            $script:moduleManifest = Test-ModuleManifest -Path $moduleManifestPath
            $script:moduleManifest | Should -Not -BeNullOrEmpty
        }

        It 'Should have less than 10000 characters in the release notes of the module manifest' {
            $script:moduleManifest.ReleaseNotes.Length | Should -BeLessThan 10000
        }
    }
}
