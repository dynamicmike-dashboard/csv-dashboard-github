# build.ps1
# Build script to generate the self-contained, offline-capable dashboard HTML file.

Write-Output "Starting dashboard build process..."

# Define paths
$templatePath = "dashboard_template.html"
$papaPath = "papaparse.min.js"
$xlsxPath = "xlsx.full.min.js"
$chartPath = "chart.umd.js"
$outputPath = "toastmasters_dashboard.html"

# Verify files exist
if (-not (Test-Path $templatePath)) {
    Write-Error "Error: $templatePath not found!"
    exit 1
}
if (-not (Test-Path $papaPath)) {
    Write-Error "Error: $papaPath not found!"
    exit 1
}
if (-not (Test-Path $xlsxPath)) {
    Write-Error "Error: $xlsxPath not found!"
    exit 1
}
if (-not (Test-Path $chartPath)) {
    Write-Error "Error: $chartPath not found!"
    exit 1
}

Write-Output "Reading file contents..."
# Read as raw text to preserve encoding
$template = [System.IO.File]::ReadAllText((Resolve-Path $templatePath))
$papa = [System.IO.File]::ReadAllText((Resolve-Path $papaPath))
$xlsx = [System.IO.File]::ReadAllText((Resolve-Path $xlsxPath))
$chart = [System.IO.File]::ReadAllText((Resolve-Path $chartPath))

Write-Output "Replacing script placeholders..."
# Use literal .Replace() instead of regex -replace to prevent symbol evaluation errors
$compiled = $template.Replace("/*{{PAPAPARSE_JS}}*/", $papa)
$compiled = $compiled.Replace("/*{{XLSX_JS}}*/", $xlsx)
$compiled = $compiled.Replace("/*{{CHART_JS}}*/", $chart)

# Append companion desktop launcher instructions as an HTML comment at the end of the file
$launcherInstructions = @"


<!--
================================================================================
🚀 COMPANION README: DESKTOP LAUNCHER INSTRUCTIONS
================================================================================

This application is 100% self-contained and runs offline. To use it like a 
native desktop application, you can set up a desktop launcher.

--------------------------------------------------------------------------------
❖ WINDOWS LAUNCHER (BAT METHOD)
--------------------------------------------------------------------------------
1. In the same folder as this file, create a new text file.
2. Rename it to "launch_dashboard.bat" (make sure the extension changes to .bat).
3. Right-click and choose "Edit", then paste the following code:

   @echo off
   start "" "chrome.exe" --app="%~dp0toastmasters_dashboard.html"

4. Save the file and close it.
5. Double-click the file to open the dashboard as a frameless web application.
6. (Optional) Right-click "launch_dashboard.bat" -> Create Shortcut, then pin 
   the shortcut to your taskbar or place it on your Desktop.

--------------------------------------------------------------------------------
❖ MACOS LAUNCHER (AUTOMATOR METHOD)
--------------------------------------------------------------------------------
Method A: .webloc Shortcut
1. Open "toastmasters_dashboard.html" in Safari or Chrome.
2. Drag the URL from the browser's address bar onto your Desktop.
3. This creates a ".webloc" shortcut. Double-click it anytime.

Method B: Automator App (Frameless App Mode)
1. Open the "Automator" application on your Mac.
2. Select "New Document" -> "Application".
3. Search for "Run Shell Script" in the actions search, and drag it to the workflow panel.
4. Set the script content to:
   open -a "Google Chrome" --args --app="file:///absolute/path/to/toastmasters_dashboard.html"
   (Replace "/absolute/path/to/" with the actual path to your file).
5. Save the workflow as "Toastmasters Dashboard.app" to your Applications folder.
6. Drag this app to your Mac Dock for instant launch.

--------------------------------------------------------------------------------
❖ LINUX LAUNCHER (.DESKTOP METHOD)
--------------------------------------------------------------------------------
1. Create a new text file on your desktop named "toastmasters_dashboard.desktop".
2. Open it in a text editor and paste the following content:

   [Desktop Entry]
   Version=1.0
   Type=Application
   Terminal=false
   Name=Toastmasters Dashboard
   Comment=Local CSV and Excel Dashboard
   Exec=google-chrome --app=file:///absolute/path/to/toastmasters_dashboard.html
   Icon=utilities-terminal
   Categories=Utility;

3. Save the file.
4. Right-click the file and select "Allow Launching" or run:
   chmod +x ~/Desktop/toastmasters_dashboard.desktop

--------------------------------------------------------------------------------
❖ CHROME SHORTCUT TIP (UNIVERSAL FRAMELESS METHOD)
--------------------------------------------------------------------------------
1. Open this file in Google Chrome.
2. Click the browser's three-dot menu (⋮) -> More Tools -> Create Shortcut...
3. Check the box "Open as Window" and click "Create".
4. This adds a clean, frameless icon to your OS Desktop/Applications menu 
   that runs offline like a native app.
================================================================================
-->
"@

$compiled = $compiled + $launcherInstructions

Write-Output "Writing compiled HTML to $outputPath and index.html..."
[System.IO.File]::WriteAllText((Join-Path $pwd $outputPath), $compiled, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $pwd "index.html"), $compiled, [System.Text.Encoding]::UTF8)

Write-Output "Done! toastmasters_dashboard.html and index.html generated successfully."
