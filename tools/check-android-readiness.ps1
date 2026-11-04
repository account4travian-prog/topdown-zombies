#Requires -Version 7.0
<#
.SYNOPSIS
    Android/Google Play release readiness checker for Last Stand Homestead (Godot 4.7)

.DESCRIPTION
    Validates all prerequisites for Android debug APK and release AAB exports.
    Reports exact pass/fail status and actionable remediation without modifying system.

.EXAMPLE
    .\tools\check-android-readiness.ps1
    .\tools\check-android-readiness.ps1 -Verbose
#>

[CmdletBinding()]
param()

# Color helpers
function Write-Pass {
    param([string]$Message)
    Write-Host "✓ PASS: $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message, [string]$Remediation)
    Write-Host "✗ FAIL: $Message" -ForegroundColor Red
    if ($Remediation) {
        Write-Host "  → $Remediation" -ForegroundColor Yellow
    }
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠ WARN: $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ INFO: $Message" -ForegroundColor Gray
}

$failureCount = 0
$warningCount = 0

Write-Host ""
Write-Host "Last Stand Homestead - Android Release Readiness Check"
Write-Host "========================================================" -ForegroundColor White
Write-Host ""

# =============================================================================
# 1. JDK/Java Check
# =============================================================================
Write-Host "1. JDK / Java" -ForegroundColor White

$javaExe = $null
$javaVersion = $null

# Check java command
try {
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
    $javaExe = (Get-Command java -ErrorAction Stop).Source

    if ($javaVersion -match "17|21|22") {
        Write-Pass "Java found: $javaExe"
        Write-Info $javaVersion
    } else {
        Write-Warn "Java version unknown or unexpected: $javaVersion"
        Write-Info "Godot 4.7 requires JDK 11+ (17+ recommended)"
        $warningCount++
    }
} catch {
    Write-Fail "Java not found in PATH" "Install JDK 17+ (Eclipse Temurin, Amazon Corretto, or OpenJDK). Add <JDK>/bin to PATH."
    $failureCount++
}

Write-Host ""

# =============================================================================
# 2. Android SDK Check
# =============================================================================
Write-Host "2. Android SDK" -ForegroundColor White

$androidHome = $env:ANDROID_HOME
$androidSdkFound = $false

# Check ANDROID_HOME env var
if ($androidHome -and (Test-Path $androidHome)) {
    Write-Info "ANDROID_HOME = $androidHome"
    $androidSdkFound = $true
} else {
    # Search common locations
    $commonPaths = @(
        "C:\Android\sdk",
        "C:\Android",
        "$env:LOCALAPPDATA\Android\sdk",
        "$env:ProgramFiles\Android\sdk",
        "C:\Program Files\Android\Android Studio\sdk"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path -PathType Container) {
            Write-Warn "ANDROID_HOME not set, but found Android SDK at: $path"
            Write-Info "Recommend: Set ANDROID_HOME=$path (Windows Settings > Environment Variables)"
            $androidHome = $path
            $androidSdkFound = $true
            $warningCount++
            break
        }
    }
}

if ($androidSdkFound) {
    Write-Pass "Android SDK located: $androidHome"

    # Check for required components
    $platformsPath = Join-Path $androidHome "platforms"
    $buildToolsPath = Join-Path $androidHome "build-tools"
    $platformToolsPath = Join-Path $androidHome "platform-tools"

    if (Test-Path $platformsPath) {
        $platforms = Get-ChildItem -Path $platformsPath -Directory | Where-Object { $_.Name -match "^android-" }
        if ($platforms) {
            $maxApiLevel = ($platforms | ForEach-Object { [int]($_.Name -replace "android-", "") } | Measure-Object -Maximum).Maximum
            Write-Info "Platforms installed: up to API level $maxApiLevel"
            if ($maxApiLevel -ge 36) {
                Write-Pass "Target SDK API $maxApiLevel meets the current Google Play API 36 requirement"
            } else {
                Write-Fail "API level $maxApiLevel is below the current Play submission minimum" "Install platforms/android-36"
                $failureCount++
            }
        } else {
            Write-Fail "No Android platforms installed" "Install platforms/android-36"
            $failureCount++
        }
    } else {
        Write-Fail "platforms/ directory not found in $androidHome" "Run: android sdk install platforms/android-36"
        $failureCount++
    }

    if (Test-Path $buildToolsPath) {
        $buildTools = Get-ChildItem -Path $buildToolsPath -Directory | Sort-Object Name -Descending | Select-Object -First 1
        if ($buildTools) {
            Write-Info "Build-tools: $($buildTools.Name)"
            Write-Pass "Build-tools installed"
        }
    } else {
        Write-Fail "build-tools/ not found in $androidHome" "Run: android sdk install build-tools/36.1.0"
        $failureCount++
    }

    if (Test-Path $platformToolsPath) {
        $adbPath = Join-Path $platformToolsPath "adb.exe"
        if (Test-Path $adbPath) {
            Write-Pass "adb.exe found: $adbPath"
        } else {
            Write-Warn "platform-tools/ exists but adb.exe not found"
            $warningCount++
        }
    } else {
        Write-Fail "platform-tools/ not found (adb required for debugging)" "Install via Android SDK Manager"
        $failureCount++
    }
} else {
    Write-Fail "Android SDK not found" "Install Android Studio or Android SDK standalone. Then set ANDROID_HOME to the SDK root directory."
    $failureCount++
}

Write-Host ""

# =============================================================================
# 3. Godot Export Templates
# =============================================================================
Write-Host "3. Godot 4.7 Export Templates" -ForegroundColor White

$godotDataPath = "$env:APPDATA\Godot"
if (-not (Test-Path $godotDataPath)) {
    $godotDataPath = "$env:LOCALAPPDATA\Godot"
}

$templatesPath = Join-Path $godotDataPath "export_templates"

if (Test-Path $templatesPath -PathType Container) {
    $template471 = Join-Path $templatesPath "4.7.1.stable"
    $template47 = Join-Path $templatesPath "4.7.stable"
    $android471 = (Test-Path $template471 -PathType Container) -and
        (Test-Path (Join-Path $template471 "android_debug.apk")) -and
        (Test-Path (Join-Path $template471 "android_release.apk")) -and
        (Test-Path (Join-Path $template471 "android_source.zip"))
    $android47 = (Test-Path $template47 -PathType Container) -and
        (Test-Path (Join-Path $template47 "android_debug.apk")) -and
        (Test-Path (Join-Path $template47 "android_release.apk"))

    if ($android471 -or $android47) {
        $version = if ($android471) { "4.7.1" } else { "4.7" }
        Write-Pass "Godot $version export templates installed at: $templatesPath"
    } else {
        Write-Fail "Complete Godot 4.7.x Android export templates not found" "Install 4.7.1 templates including android_debug.apk, android_release.apk, and android_source.zip"
        $failureCount++
    }

    $allTemplates = Get-ChildItem -Path $templatesPath -Directory | Select-Object Name
    if ($allTemplates) {
        Write-Info "Available templates: $(($allTemplates | ForEach-Object { $_.Name }) -join ', ')"
    }
} else {
    Write-Fail "Godot data directory not found at $godotDataPath" "Launch Godot 4.7 first to initialize. Then install templates via Editor > Tools > Manage Export Templates."
    $failureCount++
}

Write-Host ""

# =============================================================================
# 4. Godot Editor (verify installed)
# =============================================================================
Write-Host "4. Godot 4.7 Editor" -ForegroundColor White

$godotExe = $null
$godotPaths = @(
    "$env:ProgramFiles\Godot\Godot.exe",
    "$env:ProgramFiles\GodotEngine\Godot.exe",
    "$env:LOCALAPPDATA\Godot\Godot.exe",
    "$env:USERPROFILE\Desktop\GoDot\Godot_v4.7.1-stable_win64.exe",
    "$env:USERPROFILE\Desktop\GoDot\Godot_v4.7.1-stable_win64_console.exe",
    "C:\Program Files\Godot 4.7\Godot.exe"
)

foreach ($path in $godotPaths) {
    if (Test-Path $path) {
        $godotExe = $path
        break
    }
}

if ($godotExe) {
    Write-Pass "Godot found: $godotExe"
} else {
    Write-Warn "Godot.exe not found in common paths. Verify Godot 4.7 is installed."
    Write-Info "Check: Start menu > search 'Godot', or locate manually: where /r C:\ Godot.exe 2>nul"
    $warningCount++
}

Write-Host ""

# =============================================================================
# 5. Keystores
# =============================================================================
Write-Host "5. Keystores (for APK/AAB signing)" -ForegroundColor White

$keystorePath = Join-Path $godotDataPath "keystores"

if (Test-Path $keystorePath -PathType Container) {
    $debugKeystore = Join-Path $keystorePath "debug.keystore"
    $releaseKeystore = Join-Path $keystorePath "release.keystore"

    if (Test-Path $debugKeystore) {
        Write-Pass "Debug keystore: $debugKeystore (for debug APK export)"
    } else {
        Write-Warn "debug.keystore not found. Godot will auto-create on first export."
        $warningCount++
    }

    if (Test-Path $releaseKeystore) {
        Write-Pass "Release keystore: $releaseKeystore (for AAB/release signing)"
    } else {
        Write-Info "Release keystore not yet created. You must:"
        Write-Info "  1. Generate: keytool -genkey -v -keystore keystores/release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release"
        Write-Info "  2. Or create in Godot: Editor > Project > Tools > Manage Keystores > Create from Keystore"
        Write-Warn "Release keystore required for Google Play Store submission"
        $warningCount++
    }
} else {
    Write-Warn "keystores/ directory not found at $keystorePath"
    Write-Info "Godot will create on first export. Debug signing will work automatically."
    $warningCount++
}

Write-Host ""

# =============================================================================
# 6. Project Configuration
# =============================================================================
Write-Host "6. Project Configuration" -ForegroundColor White

$projectGodot = "%USERPROFILE%\Documents\TopDownZombies\project.godot"

if (Test-Path $projectGodot) {
    Write-Pass "project.godot found"

    $content = Get-Content $projectGodot -Raw

    # Check for Godot version
    if ($content -match 'config/features.*"4\.7"') {
        Write-Pass "Godot version confirmed: 4.7"
    } else {
        Write-Warn "Could not confirm Godot 4.7 in project.godot"
        $warningCount++
    }

    # Check window configuration
    if ($content -match 'window/handheld/orientation.*1|window/handheld/orientation.*landscape') {
        Write-Info "Window orientation: Landscape"
    } elseif ($content -match 'window/handheld/orientation.*0|window/handheld/orientation.*portrait') {
        Write-Info "Window orientation: Portrait"
    } else {
        Write-Info "Window orientation: Auto-detect/default"
    }

    # Check rendering method
    if ($content -match 'renderer/rendering_method.*"gl_compatibility"') {
        Write-Pass "Rendering: GL Compatibility (mobile-safe)"
    } else {
        Write-Warn "Rendering method unknown; GL Compatibility recommended for Android"
        $warningCount++
    }
} else {
    Write-Fail "project.godot not found" "Ensure working directory is the game root"
    $failureCount++
}

Write-Host ""

# =============================================================================
# Summary
# =============================================================================
Write-Host "Summary" -ForegroundColor White
Write-Host "=======" -ForegroundColor White

if ($failureCount -eq 0 -and $warningCount -eq 0) {
    Write-Host "✓ All checks PASSED. Ready for Android debug/release export." -ForegroundColor Green
    exit 0
} elseif ($failureCount -eq 0) {
    Write-Host "⚠ All critical checks PASSED ($warningCount warnings)." -ForegroundColor Cyan
    Write-Host "  Review warnings above. Debug APK export should work. Review release keystore status." -ForegroundColor Gray
    exit 0
} else {
    Write-Host "✗ FAILED: $failureCount critical issue(s), $warningCount warning(s)." -ForegroundColor Red
    Write-Host "  Address failures above before attempting export." -ForegroundColor Gray
    exit 1
}
