param([string[]] $Tasks = @('build'))

Set-Location $PSScriptRoot

function global:gitversion
{
    $exe = (Get-Command gitversion -CommandType Application).Source
    $raw = & $exe @args | Where-Object { $_ -notmatch '^\s*(INFO|WARN|VERBOSE|DEBUG) \[' }

    try
    {
        $obj = ($raw -join "`n") | ConvertFrom-Json
        if ($obj -and [string]::IsNullOrEmpty($obj.NuGetVersionV2) -and $obj.SemVer)
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'NuGetVersionV2' -Value $obj.SemVer -Force
            $obj | Add-Member -MemberType NoteProperty -Name 'NuGetVersion' -Value $obj.SemVer -Force
        }
        return $obj | ConvertTo-Json -Compress
    }
    catch
    {
        return $raw
    }
}

& ./build.ps1 -Tasks $Tasks
