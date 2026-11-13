# Run from the repository root. Laravel must already be running separately.
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $repoRoot
. (Join-Path $PSScriptRoot 'dev-env.ps1')
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'functions/.secret.local'))) {
    throw 'Token integrasi lokal belum disiapkan di functions/.secret.local.'
}
# The Firestore emulator requires a newer Java than the original Android JDK 17.
$studioJava = 'C:\Program Files\Android\Android Studio\jbr'
if (Test-Path -LiteralPath (Join-Path $studioJava 'bin/java.exe')) {
    $env:JAVA_HOME = $studioJava
    $env:Path = (Join-Path $studioJava 'bin') + ';' + $env:Path
}
firebase emulators:start --only functions,firestore,auth --project si-melayur-capstone-dev
