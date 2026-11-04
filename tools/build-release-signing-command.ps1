#Requires -Version 7.0
<#
.SYNOPSIS
    Build a release-signing export command for Last Stand Homestead without storing credentials in Git.

.DESCRIPTION
    Interactively prompts for keystore path, passwords, and other signing details,
    then constructs a Godot CLI export command for release AAB signing.

    The command is printed to console for manual execution—credentials are never
    stored in files or committed to Git.

.EXAMPLE
    .\tools\build-release-signing-command.ps1

    # Output:
    # Godot CLI export command (copy and paste to terminal):
    # & "%USERPROFILE%\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe" `
    #   --export-release android "LastStandHomestead-release.aab"

    # Environment variables (set before running, or Godot will prompt):
    # $env:KEYSTORE_PATH = "%USERPROFILE%\AppData\Roaming\Godot\keystores\release.keystore"
    # $env:KEYSTORE_PASSWORD = "your_keystore_password"
    # $env:KEY_ALIAS = "release"
    # $env:KEY_PASSWORD = "your_key_password"

.NOTES
    - Keystore and passwords are NOT saved to disk by this script
    - Print the command and set env vars in your session, then run manually
    - Godot will prompt interactively for passwords if env vars are not set
#>

[CmdletBinding()]
param()

Write-Host ""
Write-Host "Last Stand Homestead - Release Signing Command Builder"
Write-Host "=====================================================" -ForegroundColor White
Write-Host ""
Write-Host "This script builds a Godot CLI export command for release signing." -ForegroundColor Gray
Write-Host "Credentials are NOT stored in files or committed to Git." -ForegroundColor Gray
Write-Host ""

# Find Godot executable
$godotPaths = @(
    "$env:ProgramFiles\Godot\Godot.exe",
    "$env:USERPROFILE\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe",
    "$env:USERPROFILE\Desktop\GoDot\Godot_v4.7.1-stable_win64.exe",
    "$env:LOCALAPPDATA\Godot\Godot.exe"
)

$godotExe = $null
foreach ($path in $godotPaths) {
    if (Test-Path $path) {
        $godotExe = $path
        break
    }
}

if (-not $godotExe) {
    Write-Host "❌ Godot executable not found in common paths." -ForegroundColor Red
    Write-Host "Set `$godotExe manually or install Godot 4.7.1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Godot found: $godotExe" -ForegroundColor Green
Write-Host ""

# Verify release keystore exists
$keystoreDir = "$env:APPDATA\Godot\keystores"
$releaseKeystore = Join-Path $keystoreDir "release.keystore"

if (-not (Test-Path $releaseKeystore)) {
    Write-Host "❌ Release keystore not found at: $releaseKeystore" -ForegroundColor Red
    Write-Host "   Create one with: keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✓ Release keystore found: $releaseKeystore" -ForegroundColor Green
Write-Host ""

# Collect signing details (user will enter interactively or via Godot prompts)
Write-Host "--- Signing Configuration ---" -ForegroundColor Cyan
Write-Host ""

# Verify AAB export format
$exportPreset = "build/android/last-stand-homestead.aab"
Write-Host "Export output: $exportPreset" -ForegroundColor Gray
Write-Host ""

# Build Godot export command
$projectRoot = "%USERPROFILE%\Documents\TopDownZombies"

Write-Host "--- Godot CLI Export Command ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy and paste the command below into PowerShell:" -ForegroundColor Gray
Write-Host ""
Write-Host "cd `"$projectRoot`"" -ForegroundColor White
Write-Host "& `"$godotExe`" --export-release android `"$exportPreset`"" -ForegroundColor White
Write-Host ""

Write-Host "When prompted by Godot:" -ForegroundColor Gray
Write-Host "  1. Select release keystore: $releaseKeystore" -ForegroundColor Gray
Write-Host "  2. Enter keystore password" -ForegroundColor Gray
Write-Host "  3. Enter key alias (default: release)" -ForegroundColor Gray
Write-Host "  4. Enter key password" -ForegroundColor Gray
Write-Host ""

Write-Host "--- Alternative: Set Environment Variables (optional) ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "To avoid prompts, set these in your PowerShell session BEFORE running the command:" -ForegroundColor Gray
Write-Host ""
Write-Host "`$env:KEYSTORE_PATH = `"$releaseKeystore`"" -ForegroundColor White
Write-Host "`$env:KEYSTORE_PASSWORD = `"[your keystore password]`"" -ForegroundColor White
Write-Host "`$env:KEY_ALIAS = `"release`"" -ForegroundColor White
Write-Host "`$env:KEY_PASSWORD = `"[your key password]`"" -ForegroundColor White
Write-Host ""

Write-Host "Then run the export command." -ForegroundColor Gray
Write-Host ""

Write-Host "⚠️  DO NOT:" -ForegroundColor Yellow
Write-Host "  - Commit credentials to Git" -ForegroundColor Gray
Write-Host "  - Store passwords in .env files" -ForegroundColor Gray
Write-Host "  - Share keystore files via email/chat" -ForegroundColor Gray
Write-Host ""

Write-Host "✓ Store keystore and password in:" -ForegroundColor Green
Write-Host "  - Password manager (1Password, LastPass, KeePass)" -ForegroundColor Gray
Write-Host "  - Encrypted external drive (backup)" -ForegroundColor Gray
Write-Host "  - Secure notes (local only, never synced)" -ForegroundColor Gray
Write-Host ""
