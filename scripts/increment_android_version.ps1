# PowerShell script til at øge Android build nummer automatisk
# Brug: .\scripts\increment_android_version.ps1

# Læs pubspec.yaml
$pubspecContent = Get-Content "pubspec.yaml"
$versionLine = $pubspecContent | Where-Object { $_ -match "^version:" }

# Parse version og build nummer
$currentVersion = ($versionLine -split ": ")[1]
$versionParts = $currentVersion -split "\+"
$versionName = $versionParts[0]
$buildNumber = [int]$versionParts[1]

# Øg build nummer
$newBuildNumber = $buildNumber + 1
$newVersion = "$versionName+$newBuildNumber"

# Opdater pubspec.yaml
$pubspecContent = $pubspecContent -replace "^version: .*", "version: $newVersion"
$pubspecContent | Set-Content "pubspec.yaml"

Write-Host "Build nummer øget fra $buildNumber til $newBuildNumber"
Write-Host "Ny version: $newVersion"
Write-Host ""
Write-Host "Kør nu: flutter build appbundle --release"

# Created on $(Get-Date) 