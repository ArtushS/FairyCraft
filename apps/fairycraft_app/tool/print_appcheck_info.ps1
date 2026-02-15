param(
    [switch]$SkipSigningReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-Text {
    param([string]$Path)
    if (!(Test-Path -LiteralPath $Path)) {
        throw "Missing file: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Parse-SigningReport {
    param([string[]]$Lines)

    $currentVariant = $null
    $shaByVariant = @{}
    $errorByVariant = @{}

    foreach ($line in $Lines) {
        if ($line -match '^Variant:\s*(.+)$') {
            $currentVariant = $Matches[1].Trim()
            continue
        }

        if (($line -match '^SHA-256:\s*(.+)$') -and $currentVariant) {
            $shaByVariant[$currentVariant] = $Matches[1].Trim()
            continue
        }

        if (($line -match '^Error:\s*(.+)$') -and $currentVariant) {
            $errorByVariant[$currentVariant] = $Matches[1].Trim()
            continue
        }
    }

    return @{
        ShaByVariant = $shaByVariant
        ErrorByVariant = $errorByVariant
    }
}

$appRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$bootstrapFile = Join-Path $appRoot "lib/firebase/firebase_bootstrap.dart"
$configFile = Join-Path $appRoot "lib/shared/config/app_config.dart"
$gradleFile = Join-Path $appRoot "android/app/build.gradle.kts"
$devGoogleServicesFile = Join-Path $appRoot "android/app/src/dev/google-services.json"
$prodGoogleServicesFile = Join-Path $appRoot "android/app/src/prod/google-services.json"

$bootstrapText = Read-Text -Path $bootstrapFile
$configText = Read-Text -Path $configFile
$gradleText = Read-Text -Path $gradleFile

$devGoogleServices = Get-Content -LiteralPath $devGoogleServicesFile -Raw | ConvertFrom-Json
$prodGoogleServices = Get-Content -LiteralPath $prodGoogleServicesFile -Raw | ConvertFrom-Json

$configFiles = @()
if ($bootstrapText -match 'FirebaseAppCheck\.instance\.activate\(') {
    $configFiles += "lib/firebase/firebase_bootstrap.dart"
}
if ($configText -match 'APP_CHECK') {
    $configFiles += "lib/shared/config/app_config.dart"
}

$appCheckDefault = if ($configText -match "(?s)String\.fromEnvironment\(\s*'APP_CHECK'\s*,\s*defaultValue:\s*'([^']+)'\s*,\s*\)") { $Matches[1] } else { "unknown" }
$appCheckFallback = if ($configText -match "(?s)bool\.fromEnvironment\(\s*'APPCHECK_REQUIRED'\s*,\s*defaultValue:\s*(true|false)\s*\)") { $Matches[1] } else { "unknown" }

$providerDev = if ($bootstrapText -match 'AndroidDebugProvider') { "AndroidDebugProvider" } else { "not detected" }
$providerProd = if ($bootstrapText -match 'AndroidPlayIntegrityProvider') { "AndroidPlayIntegrityProvider" } else { "not detected" }

$baseAppId = if ($gradleText -match 'applicationId\s*=\s*"([^"]+)"') { $Matches[1] } else { "unknown" }
$devSuffix = if ($gradleText -match 'applicationIdSuffix\s*=\s*"([^"]+)"') { $Matches[1] } else { "" }
$devAppId = if ($baseAppId -ne "unknown") { "$baseAppId$devSuffix" } else { "unknown" }
$prodAppId = $baseAppId

$devFirebaseAppId = $null
$prodFirebaseAppId = $null

foreach ($client in $devGoogleServices.client) {
    if ($client.client_info.android_client_info.package_name -eq $devAppId) {
        $devFirebaseAppId = $client.client_info.mobilesdk_app_id
    }
}
if (-not $devFirebaseAppId) {
    foreach ($client in $devGoogleServices.client) {
        if ($client.client_info.android_client_info.package_name -eq $prodAppId) {
            $devFirebaseAppId = $client.client_info.mobilesdk_app_id
        }
    }
}

foreach ($client in $prodGoogleServices.client) {
    if ($client.client_info.android_client_info.package_name -eq $prodAppId) {
        $prodFirebaseAppId = $client.client_info.mobilesdk_app_id
    }
}

$shaDebugDev = "not captured"
$shaDebugProd = "not captured"
$shaReleaseDev = "not captured"
$shaReleaseProd = "not captured"
$releaseErrors = @()

if (-not $SkipSigningReport) {
    $androidDir = Join-Path $appRoot "android"
    Push-Location $androidDir
    try {
        $signingLines = cmd /c "gradlew.bat signingReport --console=plain --no-daemon 2>&1"
        $parsed = Parse-SigningReport -Lines $signingLines
        $shaByVariant = $parsed.ShaByVariant
        $errorByVariant = $parsed.ErrorByVariant

        if ($shaByVariant.ContainsKey("devDebug")) { $shaDebugDev = $shaByVariant["devDebug"] }
        if ($shaByVariant.ContainsKey("prodDebug")) { $shaDebugProd = $shaByVariant["prodDebug"] }
        if ($shaByVariant.ContainsKey("devRelease")) { $shaReleaseDev = $shaByVariant["devRelease"] }
        if ($shaByVariant.ContainsKey("prodRelease")) { $shaReleaseProd = $shaByVariant["prodRelease"] }

        if ($errorByVariant.ContainsKey("devRelease")) { $releaseErrors += "devRelease: $($errorByVariant["devRelease"])" }
        if ($errorByVariant.ContainsKey("prodRelease")) { $releaseErrors += "prodRelease: $($errorByVariant["prodRelease"])" }
    }
    finally {
        Pop-Location
    }
}

$debugTokenFromEnv = $env:FIREBASE_APPCHECK_DEBUG_TOKEN
$debugTokenLabel = if ($debugTokenFromEnv) {
    $debugTokenFromEnv
}
else {
    "Not found in environment. Run dev build with APP_CHECK=on and copy from logcat (line includes 'Firebase App Check Debug Token')."
}

@"
AppCheck config files:
- $(($configFiles | Sort-Object -Unique) -join "`n- ")

Current AppCheck mode/provider:
- APP_CHECK dart-define default: $appCheckDefault
- APPCHECK_REQUIRED fallback default: $appCheckFallback
- Android provider (dev flavor): $providerDev
- Android provider (prod flavor): $providerProd

applicationId dev/prod:
- dev: $devAppId
- prod: $prodAppId

Firebase Android App ID dev/prod:
- dev: $devFirebaseAppId
- prod: $prodFirebaseAppId

SHA-256 debug/release:
- devDebug: $shaDebugDev
- prodDebug: $shaDebugProd
- devRelease: $shaReleaseDev
- prodRelease: $shaReleaseProd
$(if ($releaseErrors.Count -gt 0) { "- release-signing errors: $($releaseErrors -join ' | ')" })

Debug token (if used):
- $debugTokenLabel

Firebase Console steps:
1. Firebase Console -> App Check -> Apps -> select Android app ($prodAppId for prod, $devAppId for dev if registered).
2. Dev setup: provider = Debug, run app once, copy debug token from logcat, register token in Console.
3. Prod setup: provider = Play Integrity, ensure SHA-256 (release key) and package/appId are registered.
4. Start enforcement in Monitor mode, then switch to Enforce after token pass rate is stable.
"@ | Write-Output
