# claude-meta doctor — check if your system is ready
# Run this before install.ps1 to make sure everything is in place.

$hasErrors = $false

Write-Host ""
Write-Host "  Checking your system..." -ForegroundColor Cyan
Write-Host ""

# 1. Node.js >= 18
try {
    $nodeVersion = (node --version 2>$null)
    if ($nodeVersion) {
        $major = [int]($nodeVersion -replace '^v','').Split('.')[0]
        if ($major -ge 18) {
            Write-Host "  [OK] Node.js $nodeVersion" -ForegroundColor Green
        } else {
            Write-Host "  [!!] Node.js $nodeVersion is too old (need v18+)" -ForegroundColor Red
            $hasErrors = $true
        }
    } else { throw }
} catch {
    Write-Host "  [!!] Node.js not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "       Node.js is what runs Claude Code under the hood. You need version 18 or newer." -ForegroundColor Yellow
    Write-Host "       Download it from: https://nodejs.org (pick the big green button that says 'LTS')" -ForegroundColor Yellow
    Write-Host "       After installing, close this window, open a new PowerShell, and run this check again." -ForegroundColor Yellow
    Write-Host ""
    $hasErrors = $true
}

# 2. npm
try {
    $npmVersion = (npm --version 2>$null)
    if ($npmVersion) {
        Write-Host "  [OK] npm v$npmVersion" -ForegroundColor Green
    } else { throw }
} catch {
    Write-Host "  [!!] npm not found (should come with Node.js — try reinstalling Node.js)" -ForegroundColor Red
    $hasErrors = $true
}

# 3. Claude Code
try {
    $claudeVersion = (claude --version 2>$null)
    if ($claudeVersion) {
        Write-Host "  [OK] Claude Code installed" -ForegroundColor Green
    } else { throw }
} catch {
    Write-Host "  [--] Claude Code not installed yet (the install script will handle this)" -ForegroundColor Yellow
}

# 4. Chrome or Edge browser
$browserFound = $false
$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$edgePaths = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)
foreach ($p in ($chromePaths + $edgePaths)) {
    if (Test-Path $p) { $browserFound = $true; break }
}
if ($browserFound) {
    Write-Host "  [OK] Chrome/Edge browser found" -ForegroundColor Green
} else {
    Write-Host "  [--] Chrome/Edge not detected (optional — needed for browser automation)" -ForegroundColor Yellow
    Write-Host "       Get Chrome from: https://www.google.com/chrome" -ForegroundColor Yellow
}

# 5. Existing settings file
$settingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "  [OK] Settings file exists" -ForegroundColor Green
} else {
    Write-Host "  [--] No settings file yet (the install script will create one)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
if (-not $hasErrors) {
    Write-Host "  All good! You're ready to install. Run:" -ForegroundColor Green
    Write-Host ""
    Write-Host "    .\install.ps1" -ForegroundColor White
} else {
    Write-Host "  Almost there! Fix the items marked with [!!] above, then run this check again:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    .\doctor.ps1" -ForegroundColor White
}
Write-Host ""
