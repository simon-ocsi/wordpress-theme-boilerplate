param(
    [Parameter(Mandatory = $true)][string]$ThemeName,
    [Parameter(Mandatory = $true)][string]$ThemeSlug
)

$ErrorActionPreference = "Stop"
if ($ThemeSlug -notmatch '^[a-z0-9-]+$') { throw "ThemeSlug must contain only lowercase letters, numbers and hyphens." }

# Windows PowerShell 5.1 writes a byte-order mark when Set-Content uses UTF-8.
# Use an explicit encoder so generated PHP, JSON and JavaScript remain UTF-8 without BOM.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Content, $utf8NoBom)
}

$oldSlug = "starter-theme"
$oldDir = "wp-content/themes/$oldSlug"
$newDir = "wp-content/themes/$ThemeSlug"

if (-not (Test-Path $oldDir)) { throw "Starter theme not found at $oldDir" }
if (Test-Path $newDir) { throw "Theme directory already exists: $newDir" }

$phpPrefix = $ThemeSlug.Replace('-', '_')
$classPrefix = (($ThemeSlug -split '-') | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }) -join '_'
Rename-Item $oldDir $ThemeSlug

$files = Get-ChildItem $newDir -Recurse -File | Where-Object { $_.Extension -in '.php', '.js', '.css', '.scss', '.json', '.md' -or $_.Name -in 'package.json', 'vite.config.js' }
foreach ($file in $files) {
    $content = Get-Content -Raw $file.FullName
    $content = $content.Replace('Starter Theme', $ThemeName)
    $content = $content.Replace('starter-theme', $ThemeSlug)
    $content = $content.Replace('starter_theme', $phpPrefix)
    $content = $content.Replace('Starter_Theme', $classPrefix)
    Write-Utf8NoBom -Path $file.FullName -Content $content
}

$settings = Get-Content -Raw '.vscode/settings.json'
$settings = $settings.Replace('starter-theme', $ThemeSlug)
Write-Utf8NoBom -Path '.vscode/settings.json' -Content $settings

$projectFiles = @('.github/workflows/ci.yml', 'phpcs.xml.dist')
foreach ($projectFile in $projectFiles) {
    $content = Get-Content -Raw $projectFile
    $content = $content.Replace('starter-theme', $ThemeSlug)
    Write-Utf8NoBom -Path $projectFile -Content $content
}


Write-Host "Created '$ThemeName' in $newDir" -ForegroundColor Green
Write-Host "Next: cd $newDir; npm ci; npm run dev"
