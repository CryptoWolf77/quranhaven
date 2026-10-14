param(
    [switch]$TestSigning,
    [switch]$AppBundle,
    [string]$FlutterExecutable = 'flutter',
    [string]$ContentUrl = 'https://quranhaven.org/v1/'
)

$ErrorActionPreference = 'Stop'
if ($AppBundle -and $TestSigning) {
    throw 'A Google Play app bundle must use the production upload key, not test signing.'
}
$quranProjectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$quranPreviousLocation = Get-Location
$quranPreviousJavaOptions = $env:JAVA_TOOL_OPTIONS
$quranPreviousTestSigning = $env:QURAN_HAVEN_TEST_SIGNING
$quranContentUri = [Uri]$ContentUrl
if (-not $quranContentUri.IsAbsoluteUri -or $quranContentUri.Scheme -ne 'https' -or
    $quranContentUri.UserInfo -or $quranContentUri.Query -or $quranContentUri.Fragment) {
    throw 'Use a public HTTPS content root without credentials, query or fragment.'
}

try {
    Set-Location -LiteralPath $quranProjectRoot
    if ($env:OS -eq 'Windows_NT') {
        # Windows Java NIO pipes can fail when the redirected TEMP path is long.
        # Keep only their temporary socket files in this ignored build directory.
        $quranSocketDirectory = Join-Path $quranProjectRoot 'android\.gradle'
        New-Item -ItemType Directory -Path $quranSocketDirectory -Force | Out-Null
        $env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir="' + $quranSocketDirectory + '"'
    }
    # Never inherit a test-signing flag accidentally into a store release.
    $env:QURAN_HAVEN_TEST_SIGNING = if ($TestSigning) { 'true' } else { $null }
    $quranTarget = if ($AppBundle) { 'appbundle' } else { 'apk' }
    & $FlutterExecutable build $quranTarget --release "--dart-define=QURAN_CONTENT_URL=$ContentUrl"
    if ($LASTEXITCODE -ne 0) { throw "Android build failed (exit $LASTEXITCODE)." }
} finally {
    $env:JAVA_TOOL_OPTIONS = $quranPreviousJavaOptions
    $env:QURAN_HAVEN_TEST_SIGNING = $quranPreviousTestSigning
    Set-Location -LiteralPath $quranPreviousLocation.Path
}
