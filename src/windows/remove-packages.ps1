Write-Host "=== Remove Packages ==="

Write-Host "Unlinking node-windows.."

npm unlink node-windows --loglevel=error --no-fund --no-audit

Write-Host "Uninstalling packages.."

npm uninstall --global --loglevel=error "pm2"
npm uninstall --global --loglevel=error "@jessety/pm2-logrotate"
npm uninstall --global --loglevel=error "node-windows"

Write-Host "=== Remove Packages Complete ==="
