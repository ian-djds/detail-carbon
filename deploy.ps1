# deploy.ps1 - commit, push, and let Vercel auto-deploy the live site.
#
# Usage (from the project folder):
#   .\deploy.ps1 "your commit message"
#   .\deploy.ps1                       # uses a timestamped default message
#
# What it does: stages all changes, commits (if there are any), and pushes to
# GitHub. The push to 'master' triggers Vercel to redeploy
# https://detail-carbon.vercel.app within about 30 seconds.

param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $Message
)

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# Commit message: joined args, or a timestamped default
if ($Message) {
  $msg = ($Message -join " ")
} else {
  $msg = "Update site ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
}

git add -A

# Only commit if something is staged
$staged = git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace($staged)) {
  Write-Host "No file changes to commit - pushing any unpushed commits..." -ForegroundColor Yellow
} else {
  git commit -m $msg
}

# Push to the tracked branch (this is what triggers the Vercel deploy)
git push

Write-Host ""
Write-Host "Pushed to GitHub. Vercel will auto-deploy in about 30s." -ForegroundColor Green
Write-Host "Live: https://detail-carbon.vercel.app" -ForegroundColor Cyan
