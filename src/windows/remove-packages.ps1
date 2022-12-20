Write-Host "=== Remove Packages ==="

Write-Host "Unlinking node-windows.."


# Strip dependencies from package.json
# This is because `npm unlink` fails while attempting to negotiate dev dependencies that aren't cached when offline
Write-Host "Stripping dependencies..."
node src\tools\dependencies\strip.js

Write-Host "Linking node-windows.."
npm unlink node-windows --loglevel=error --no-fund --no-audit

  # Restore dependencies to package.json
Write-Host "Restoring dependencies..."
node src\tools\dependencies\restore.js

Write-Host "Uninstalling packages.."

npm uninstall --global --loglevel=error "pm2"
npm uninstall --global --loglevel=error "@jessety/pm2-logrotate"
npm uninstall --global --loglevel=error "node-windows"

Write-Host "=== Remove Packages Complete ==="
