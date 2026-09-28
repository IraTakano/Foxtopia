param(
    [string]$GameExportDir = "dist/game",
    [string]$Version = "v0.1.0",
    [string]$Repository = "IraTakano/Foxtopia",
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,69}$') {
    throw "Version must be a simple release tag, for example v0.1.0."
}

if ($Repository.StartsWith("https://github.com/")) {
    $Repository = $Repository.Substring("https://github.com/".Length).TrimEnd('/')
}
if ($Repository.EndsWith(".git")) { $Repository = $Repository.Substring(0, $Repository.Length - 4) }
if ($Repository -and $Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
    throw "Repository must be a GitHub owner/repo name or URL."
}

function Resolve-WithinWorkspace([string]$path) {
    $absolute = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
    $workspacePrefix = $repoRoot.TrimEnd('\') + '\'
    if (-not $absolute.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path must be inside the Foxtopia workspace: $absolute"
    }
    return $absolute
}

$gameDir = Resolve-WithinWorkspace $GameExportDir
$output = Resolve-WithinWorkspace $OutputDir
$packageDir = Resolve-WithinWorkspace "dist/package"
$publishDir = Resolve-WithinWorkspace "dist/launcher-publish"
if (-not (Test-Path -LiteralPath (Join-Path $gameDir "Foxtopia.exe") -PathType Leaf)) {
    throw "Windows game export is missing: $gameDir\Foxtopia.exe"
}

$dotnet = Join-Path $repoRoot ".tools/dotnet/dotnet.exe"
if (-not (Test-Path -LiteralPath $dotnet)) {
    $dotnet = (Get-Command dotnet -ErrorAction Stop).Source
    if (-not (& $dotnet --list-sdks)) { throw "A .NET 8 SDK is required. Run the local SDK bootstrap first." }
}

$isccCandidates = @(
    (Join-Path $env:LOCALAPPDATA "Programs/Inno Setup 6/ISCC.exe"),
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)
$iscc = $isccCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $iscc) { throw "Inno Setup 6 (ISCC.exe) is required to build the setup EXE." }

foreach ($directory in @($packageDir, $publishDir)) {
    if (Test-Path -LiteralPath $directory) { Remove-Item -LiteralPath $directory -Recurse -Force }
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}
New-Item -ItemType Directory -Path $output -Force | Out-Null

$project = Join-Path $repoRoot "launcher/Foxtopia.Launcher/Foxtopia.Launcher.csproj"
& $dotnet publish $project -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o $publishDir
if ($LASTEXITCODE -ne 0) { throw "Launcher publish failed." }

Copy-Item -LiteralPath (Join-Path $publishDir "FoxtopiaLauncher.exe") -Destination $packageDir
Copy-Item -LiteralPath (Join-Path $repoRoot "game/assets/foxtopia.ico") -Destination (Join-Path $packageDir "Foxtopia.ico")
$baseDirectory = "base-" + $Version.Replace('.', '_')
$versionDir = Join-Path $packageDir ("versions/" + $baseDirectory)
New-Item -ItemType Directory -Path $versionDir -Force | Out-Null
Get-ChildItem -LiteralPath $gameDir -Force | Copy-Item -Destination $versionDir -Recurse -Force

@{ repository = $Repository; manifestAsset = "Foxtopia-update.json"; archiveAsset = "Foxtopia-win-x64.zip"; gameExecutable = "Foxtopia.exe" } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $packageDir "launcher-config.json") -Encoding UTF8
@{ version = $Version; directory = $baseDirectory } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $packageDir "current.json") -Encoding UTF8

$innoScript = Join-Path $repoRoot "installer/Foxtopia.iss"
& $iscc "/DPackageDir=$packageDir" "/DAppVersion=$Version" "/DOutputDir=$output" "/DIconFile=$(Join-Path $repoRoot 'game/assets/foxtopia.ico')" $innoScript
if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed." }

$setup = Join-Path $output ("Foxtopia-Setup-$Version.exe")
Write-Host "Setup ready: $setup"
Write-Host "Install folder: $env:LOCALAPPDATA\KlausennGames\common\Foxtopia"
if (-not $Repository) { Write-Warning "GitHub repository is not configured yet; pass -Repository owner/repo to enable release checks." }

