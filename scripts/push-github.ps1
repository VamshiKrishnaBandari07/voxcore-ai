# Create GitHub repo (if needed) and push main branch.
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RepoName = "voicecode"
$Remote = "git@github.com:VamshiKrishnaBandari07/$RepoName.git"

Set-Location $ProjectRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Install GitHub CLI: winget install GitHub.cli" -ForegroundColor Red
    exit 1
}

$ghAuthed = $false
try {
    gh auth status 2>$null | Out-Null
    $ghAuthed = $LASTEXITCODE -eq 0
} catch {
    $ghAuthed = $false
}

if (-not $ghAuthed) {
    Write-Host "Log in to GitHub (one-time):" -ForegroundColor Yellow
    gh auth login --hostname github.com --git-protocol ssh --web
}

$exists = $false
git ls-remote $Remote 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { $exists = $true }

if (-not $exists) {
    Write-Host "Creating GitHub repo $RepoName..." -ForegroundColor Cyan
    gh repo create $RepoName --public --source=. --remote=origin --description "VoiceCode — offline speech practice app for Windows"
} elseif (-not (git remote get-url origin 2>$null)) {
    git remote add origin $Remote
}

Write-Host "Pushing to GitHub..." -ForegroundColor Green
git push -u origin main
Write-Host "Done: https://github.com/VamshiKrishnaBandari07/$RepoName" -ForegroundColor Green
