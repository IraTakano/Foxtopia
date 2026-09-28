param(
    [string]$Version,
    [string]$Repository = "IraTakano/Foxtopia",
    [string]$ReleaseDir = "dist/release",
    [string]$Notes = "Foxtopia Windows build."
)

$ErrorActionPreference = "Stop"
if (-not $Version) { throw "Pass the release tag with -Version, for example v0.1.1." }
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,69}$') { throw "Invalid release tag." }
if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw "Repository must be owner/repo." }
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$output = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $ReleaseDir))
if (-not $output.StartsWith(($repoRoot.TrimEnd('\') + '\'), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Release directory must be inside the Foxtopia workspace."
}
$archive = Join-Path $output "Foxtopia-win-x64.zip"
$manifest = Join-Path $output "Foxtopia-update.json"
if (-not (Test-Path -LiteralPath $archive) -or -not (Test-Path -LiteralPath $manifest)) {
    throw "Run create-release.ps1 first."
}
$data = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
if ($data.version -ne $Version) { throw "Manifest version does not match the release tag." }
$actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
if ($actualHash -ne $data.sha256) { throw "Release archive SHA-256 does not match the manifest." }
$ghCommand = Get-Command gh -ErrorAction SilentlyContinue
$gh = if ($ghCommand) { $ghCommand.Source } else {
    Join-Path $env:LOCALAPPDATA "Microsoft/WinGet/Packages/GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe/bin/gh.exe"
}
if (-not (Test-Path -LiteralPath $gh)) { throw "GitHub CLI (gh) is required to publish the release." }
$files = @($archive, $manifest)
$setup = Join-Path $repoRoot ("dist/Foxtopia-Setup-$Version.exe")
if (Test-Path -LiteralPath $setup) { $files += $setup }
& $gh release create $Version @files --repo $Repository --title "Foxtopia $Version" --notes $Notes --latest
if ($LASTEXITCODE -ne 0) { throw "GitHub release creation failed." }

