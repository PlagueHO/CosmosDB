param([string[]] $Tasks = @('build'))

Set-Location $PSScriptRoot

function global:gitversion
{
    $cmd = Get-Command -Name dotnet-gitversion -CommandType Application -ErrorAction SilentlyContinue
    if (-not $cmd)
    {
        $cmd = Get-Command -Name gitversion -CommandType Application -ErrorAction Stop
    }

    $raw = & $cmd.Source @args | Where-Object { $_ -notmatch '^\s*(INFO|WARN|VERBOSE|DEBUG) \[' }

    try
    {
        $obj = ($raw -join "`n") | ConvertFrom-Json
        if ($obj -and [string]::IsNullOrEmpty($obj.NuGetVersionV2) -and $obj.SemVer)
        {
            # GitVersion 6.x removed NuGetVersionV2; construct a NuGet-compatible version
            # from SemVer by replacing dots in the pre-release segment with hyphens.
            # NuGet only allows [A-Za-z0-9-] in pre-release identifiers.
            $semVer = $obj.SemVer -replace '\+.*$', ''
            $parts = $semVer -split '-', 2
            $nuGetVersion = if ($parts.Length -eq 2) {
                "$($parts[0])-$($parts[1] -replace '\.', '-')"
            } else {
                $semVer
            }
            $obj | Add-Member -MemberType NoteProperty -Name 'NuGetVersionV2' -Value $nuGetVersion -Force
            $obj | Add-Member -MemberType NoteProperty -Name 'NuGetVersion' -Value $nuGetVersion -Force
        }
        return $obj | ConvertTo-Json -Compress
    }
    catch
    {
        return $raw
    }
}

& ./build.ps1 -Tasks $Tasks
