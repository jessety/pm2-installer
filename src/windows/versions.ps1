$pm2_package = "$(node src/dependency.js pm2)"
$pm2_service_package = "$(node src/dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/dependency.js pm2-logrotate)"

Write-Host "Using:"
Write-Host "- $pm2_package"
Write-Host "- $pm2_service_package"
Write-Host "- $pm2_logrotate_package"
