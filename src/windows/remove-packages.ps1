Write-Host "=== Remove Packages ==="

$pm2_package = "pm2";
$pm2_service_package = "@innomizetech/pm2-windows-service";
$pm2_logrotate_package = "pm2-logrotate";

npm uninstall --global $pm2_package --loglevel=error
npm uninstall --global $pm2_service_package --loglevel=error
npm uninstall --global $pm2_logrotate_package --loglevel=error

Write-Host "=== Remove Packages Complete ==="
