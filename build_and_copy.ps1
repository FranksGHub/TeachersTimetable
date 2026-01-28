# --- Configuration ---
Write-Host "---- change the version in pubspec.yaml before running this script! ----" -ForegroundColor Magenta
$projectName = "Teachers_Timetable" # insert your project name
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$releaseDir = "D:\Projekte_Flutter\Releases\$projectName\_$timestamp"

Write-Host "--- Start multi-platform build ---" -ForegroundColor Cyan

# 1. Cleanup
Write-Host "Cleanup old files..."
flutter clean
flutter pub get

# 2. Run Builds
Write-Host "---- Generate all icons (uncomment if new changes to master icon!) ----" -ForegroundColor Magenta
# dart --disable-analytics
# dart run flutter_launcher_icons

Write-Host "Build Web (CanvasKit)..." -ForegroundColor Yellow
flutter build web --release --base-href "/stundenplan/"

Write-Host "Build Android APK..." -ForegroundColor Yellow
flutter build apk --release

Write-Host "Build Windows App..." -ForegroundColor Yellow
flutter build windows --release

# 3. Create output folder
Write-Host "Create release folder..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$releaseDir\Web"
New-Item -ItemType Directory -Force -Path "$releaseDir\Android"
New-Item -ItemType Directory -Force -Path "$releaseDir\Windows"

# 4. copy files
Write-Host "Copy files into the release folder..." -ForegroundColor Green

# Web
Copy-Item -Path "build\web\*" -Destination "$releaseDir\Web" -Recurse

# Android
Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "$releaseDir\Android\$projectName.apk"

# Windows (Kopiert den gesamten Release-Ordner inkl. DLLs)
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "$releaseDir\Windows" -Recurse
Compress-Archive -Path "$releaseDir\Windows" -DestinationPath "$releaseDir\Windows\Teachers_Timetable.zip" -Force

Write-Host "`n--- FERTIG! ---" -ForegroundColor Green
Write-Host "Find your files here: $releaseDir"
explorer $releaseDir
