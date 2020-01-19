Write-Host "=== Install Packages ==="

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"
$cache_folder = ".\.npm_cache";

# Print out the versions of this package, node, and npm for this host
node src\bundle\current.js

if (Test-Path $cache_folder) {

  # Read the bundle information file and compare it to the current host
  node src\bundle\compare.js

  Write-Host "Cache detected, installing offline.."

  npm --offline --cache $cache_folder --optional cache verify

  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_package
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_service_package
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_logrotate_package

} else {
  
  Write-Host "Cache not detected, installing online.."
  
  npm install --global --loglevel=error $pm2_package
  npm install --global --loglevel=error $pm2_service_package
  npm install --global --loglevel=error $pm2_logrotate_package
}

# Enable execution of pm2's powershell script, so the current user can interact with pm2
$script_path = "$(npm config get prefix)\pm2.ps1"
if (Test-Path $script_path) {

  Write-Host "Unblocking script at $script_path.."
  Unblock-File -Path $script_path
}

Write-Host "=== Install Packages Complete ==="
