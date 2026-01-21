# Bump minor version, commit, push, and reinstall uno-dev plugin

$pluginPath = $PSScriptRoot
$pluginJsonPath = Join-Path $pluginPath ".claude-plugin\plugin.json"

# Read and parse plugin.json
$json = Get-Content $pluginJsonPath -Raw | ConvertFrom-Json

# Parse current version
$versionParts = $json.version -split '\.'
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

# Bump minor version, reset patch
$newVersion = "$major.$($minor + 1).0"
$json.version = $newVersion

# Write back without BOM
$newJson = @"
{
  "name": "$($json.name)",
  "description": "$($json.description)",
  "version": "$newVersion",
  "author": {
    "name": "$($json.author.name)",
    "url": "$($json.author.url)"
  },
  "repository": "$($json.repository)",
  "license": "$($json.license)",
  "keywords": $(($json.keywords | ConvertTo-Json -Compress))
}
"@
[System.IO.File]::WriteAllText($pluginJsonPath, $newJson)

Write-Host "Version bumped to $newVersion" -ForegroundColor Green

# Git operations
Set-Location (Split-Path $pluginPath -Parent | Split-Path -Parent)
git add .
git commit -m "bump uno-dev to $newVersion"
git push

Write-Host "Committed and pushed" -ForegroundColor Green

# Reinstall plugin using local marketplace
Write-Host "Adding local marketplace..." -ForegroundColor Yellow
$marketplacePath = Split-Path $pluginPath -Parent
claude plugin marketplace add $marketplacePath 2>$null

Write-Host "Installing uno-dev plugin..." -ForegroundColor Yellow
claude plugin install uno-dev

Write-Host "Done!" -ForegroundColor Green
