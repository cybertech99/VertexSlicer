# Build/run helper: uses VS2019 BuildTools env (VS2022 install here lacks C++ libs)
$vc='C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
cmd /c "`"$vc`" >nul 2>&1 && set" | ForEach-Object { if ($_ -match '^([^=]+)=(.*)$') { Set-Item "env:$($matches[1])" $matches[2] } }
$env:Path += ";$env:USERPROFILE\.cargo\bin"

# A running GUI locks target\...\vertexslicer.exe and the link step fails with "Access is denied",
# so close any copy started from this repo's target folder before building or running.
# Set SLICER_KEEP_GUI=1 to skip this.
if (-not $env:SLICER_KEEP_GUI -and ($args -contains 'build' -or $args -contains 'run' -or $args -contains 'b' -or $args -contains 'r')) {
    $target = Join-Path $PSScriptRoot 'target'
    $running = Get-Process -Name 'vertexslicer', 'slicer-gui' -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($target, [System.StringComparison]::OrdinalIgnoreCase) }
    foreach ($p in $running) {
        Write-Host "Closing running VertexSlicer (pid $($p.Id)) so the exe can be replaced"
        try { $p.Kill(); $p.WaitForExit(5000) | Out-Null } catch { Write-Warning "Could not close pid $($p.Id): $_" }
    }
}

cargo @args
