$pm2_package = "$(node src/tools/echo-dependency.js pm2)"
$pm2_logrotate_package = "$(node src/tools/echo-dependency.js pm2-logrotate)"
$node_windows_package = "$(node src/tools/echo-dependency.js node-windows)"

Write-Host "Using:"
Write-Host "- $pm2_package"
Write-Host "- $pm2_logrotate_package"
Write-Host "- $node_windows_package"
