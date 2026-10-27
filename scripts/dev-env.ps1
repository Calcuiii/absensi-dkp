# Jalankan dengan dot sourcing: . .\scripts\dev-env.ps1
$toolRoot = 'C:\dev\si-melayur'
$env:FLUTTER_ROOT = Join-Path $toolRoot 'flutter'
$env:JAVA_HOME = Join-Path $toolRoot 'java\jdk-17.0.20.1+1'
$env:ANDROID_HOME = Join-Path $toolRoot 'android-sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:PUB_CACHE = Join-Path $toolRoot 'pub-cache'
$env:GRADLE_USER_HOME = Join-Path $toolRoot 'gradle-cache'
# Socket internal Java di Windows membutuhkan jalur sementara pendek.
$javaSocketOption = '-Djdk.net.unixdomain.tmpdir=C:\dev\si-melayur\tmp'
if ($env:JAVA_TOOL_OPTIONS -notmatch 'jdk\.net\.unixdomain\.tmpdir') {
    $env:JAVA_TOOL_OPTIONS = (($env:JAVA_TOOL_OPTIONS, $javaSocketOption) -join ' ').Trim()
}
$toolPaths = @(
    "$env:FLUTTER_ROOT\bin",
    "$env:JAVA_HOME\bin",
    "$env:ANDROID_HOME\platform-tools",
    "$env:ANDROID_HOME\cmdline-tools\latest\bin",
    "$env:PUB_CACHE\bin",
    "$toolRoot\firebase-tools\node_modules\.bin"
)
$env:Path = ($toolPaths -join ';') + ';' + $env:Path
Write-Host 'Lingkungan SI-MELAYUR aktif untuk terminal ini.'
