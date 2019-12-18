Write-Host "=== Remove Packages ==="

npm uninstall --global --loglevel=error "pm2"
npm uninstall --global --loglevel=error "@innomizetech/pm2-windows-service"
npm uninstall --global --loglevel=error "pm2-logrotate"

Write-Host "=== Remove Packages Complete ==="
