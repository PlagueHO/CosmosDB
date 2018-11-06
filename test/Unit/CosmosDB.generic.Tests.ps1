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

Describe 'PSScriptAnalyzer' -Tag 'PSScriptAnalyzer' {
    Import-Module -Name 'PSScriptAnalyzer'

    Context 'CosmosDB Module code and CosmosDB Lib Functions' {
        $modulePath = Join-Path -Path $moduleRootPath -ChildPath 'CosmosDB.psm1'
        $moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath 'CosmosDB.psd1'

        It 'Should have no Error level PowerShell Script Analyzer violations' {
            # Perform PSScriptAnalyzer scan.
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                -path $modulePath `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -path (Join-Path -Path $moduleRootPath -ChildPath 'lib\*.ps1') `
                -excluderule "PSAvoidUsingUserNameAndPassWordParams" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object {
                $_.Severity -eq 'Error'
            }
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object {
                $_.Severity -eq 'Warning'
            }

            if ($PSScriptAnalyzerErrors -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
                Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors.Count | Should -Be $null
            }

            if ($PSScriptAnalyzerWarnings -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer warnings that should be fixed:'
                @($PSScriptAnalyzerWarnings).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
            }
        }

        $script:moduleManifest = Test-ModuleManifest -Path $moduleManifestPath -ErrorAction SilentlyContinue

        It 'Should have a valid manifest' {
            $script:moduleManifest | Should -Not -BeNullOrEmpty
        }

        It 'Should have less than 10000 characters in the release notes of the module manifest' {
            $script:moduleManifest.ReleaseNotes.Length | Should -BeLessThan 10000
        }
    }
}
