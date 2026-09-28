param([string]$GodotExe = "")

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if (-not $GodotExe) {
    $localGodot = Get-ChildItem -LiteralPath (Join-Path $repoRoot ".tools/godot") -Filter "Godot*_console.exe" -File -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($localGodot) {
        $GodotExe = $localGodot.FullName
    } else {
        $GodotExe = (Get-Command godot -ErrorAction Stop).Source
    }
}
& $GodotExe --headless --path (Join-Path $repoRoot "game") --script (Join-Path $PSScriptRoot "build-icon.gd")
if ($LASTEXITCODE -ne 0) { throw "Icon build failed." }
