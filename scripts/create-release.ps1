param(
    [string]$GameExportDir = "dist/game",
    [string]$Version = "v0.1.0",
    [string]$OutputDir = "dist/release"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,69}$') { throw "Invalid release tag." }
function Resolve-WithinWorkspace([string]$path) {
    $absolute = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
    if (-not $absolute.StartsWith(($repoRoot.TrimEnd('\') + '\'), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path must be inside the Foxtopia workspace: $absolute"
    }
    return $absolute
}
$gameDir = Resolve-WithinWorkspace $GameExportDir
$output = Resolve-WithinWorkspace $OutputDir
if (-not (Test-Path -LiteralPath (Join-Path $gameDir "Foxtopia.exe") -PathType Leaf)) {
    throw "Game export must contain Foxtopia.exe."
}
New-Item -ItemType Directory -Path $output -Force | Out-Null
$archive = Join-Path $output "Foxtopia-win-x64.zip"
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
Compress-Archive -Path (Join-Path $gameDir '*') -DestinationPath $archive -CompressionLevel Optimal
$digest = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
@{ schemaVersion = 1; version = $Version; archive = "Foxtopia-win-x64.zip"; sha256 = $digest; gameExecutable = "Foxtopia.exe" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output "Foxtopia-update.json") -Encoding UTF8
Write-Host "Upload both files in $output to the GitHub release tagged $Version."

