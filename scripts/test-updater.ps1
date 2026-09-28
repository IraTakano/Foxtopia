$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$launcher = Join-Path $repoRoot "dist/launcher-publish/FoxtopiaLauncher.exe"
if (-not (Test-Path -LiteralPath $launcher)) { throw "Publish the launcher before running this test." }

$testRoot = Join-Path $repoRoot ".tools/updater-test"
$workspacePrefix = $repoRoot.TrimEnd('\') + '\'
if (-not ([System.IO.Path]::GetFullPath($testRoot)).StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe test path."
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
$installed = Join-Path $testRoot "installed"
$fixture = Join-Path $testRoot "fixture"
$releaseFiles = Join-Path $testRoot "release-files"
New-Item -ItemType Directory -Path (Join-Path $installed "versions/base-v1") -Force | Out-Null
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
New-Item -ItemType Directory -Path $releaseFiles -Force | Out-Null

Set-Content -LiteralPath (Join-Path $installed "versions/base-v1/Foxtopia.exe") -Value "version one" -Encoding UTF8
@{ repository = ""; manifestAsset = "Foxtopia-update.json"; archiveAsset = "Foxtopia-win-x64.zip"; gameExecutable = "Foxtopia.exe" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $installed "launcher-config.json") -Encoding UTF8
@{ version = "v1.0.0"; directory = "base-v1" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $installed "current.json") -Encoding UTF8

Set-Content -LiteralPath (Join-Path $releaseFiles "Foxtopia.exe") -Value "version two" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $releaseFiles "Foxtopia.pck") -Value "game data" -Encoding UTF8
$archive = Join-Path $fixture "Foxtopia-win-x64.zip"
Compress-Archive -Path (Join-Path $releaseFiles '*') -DestinationPath $archive
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
@{ schemaVersion = 1; version = "v1.1.0"; archive = "Foxtopia-win-x64.zip"; sha256 = $hash; gameExecutable = "Foxtopia.exe" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $fixture "Foxtopia-update.json") -Encoding UTF8

function Invoke-Fixture([string]$expected) {
    $process = Start-Process -FilePath $launcher -ArgumentList @("--test-fixture", "`"$fixture`"", "--install-root", "`"$installed`"") -Wait -PassThru -WindowStyle Hidden
    $result = Get-Content -LiteralPath (Join-Path $installed "test-result.json") -Raw | ConvertFrom-Json
    if ($result.outcome -ne $expected) { throw "Expected $expected, got $($result.outcome): $($result.error)" }
    if ($expected -eq "Failed" -and $process.ExitCode -eq 0) { throw "Failure case returned exit code zero." }
    if ($expected -ne "Failed" -and $process.ExitCode -ne 0) { throw "Updater returned exit code $($process.ExitCode)." }
}

Invoke-Fixture "Updated"
$state = Get-Content -LiteralPath (Join-Path $installed "current.json") -Raw | ConvertFrom-Json
if ($state.version -ne "v1.1.0") { throw "Version pointer was not updated." }
$gameFile = Join-Path $installed ("versions/" + $state.directory + "/Foxtopia.exe")
if ((Get-Content -LiteralPath $gameFile -Raw).Trim() -ne "version two") { throw "Installed game file is incorrect." }
Invoke-Fixture "AlreadyCurrent"

@{ schemaVersion = 1; version = "v1.2.0"; archive = "Foxtopia-win-x64.zip"; sha256 = ('0' * 64); gameExecutable = "Foxtopia.exe" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $fixture "Foxtopia-update.json") -Encoding UTF8
Invoke-Fixture "Failed"
$stateAfterFailure = Get-Content -LiteralPath (Join-Path $installed "current.json") -Raw | ConvertFrom-Json
if ($stateAfterFailure.version -ne "v1.1.0") { throw "A failed update replaced the working version." }
Write-Host "Updater fixture passed: update, repeat launch, and rejected hash mismatch."

