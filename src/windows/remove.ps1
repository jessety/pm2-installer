Write-Host "=== Remove ==="

$pm2_package = "pm2";
$pm2_service_package = "@innomizetech/pm2-windows-service";
$pm2_logrotate_package = "pm2-logrotate";

Write-Host "Killing pm2 process"
pm2 kill

Write-Host "Removing pm2 service"
pm2-service-uninstall

Write-Host "Uninstalling pm2"
npm uninstall --global $pm2_package --loglevel=error
npm uninstall --global $pm2_service_package --loglevel=error
npm uninstall --global $pm2_logrotate_package --loglevel=error

Write-Host "=== Remove Complete ==="
