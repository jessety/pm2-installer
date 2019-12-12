Write-Host "=== Install ==="

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

  npm --offline --cache $cache_folder --optional --cache-min 99999999999 cache verify

  npm install --global --offline --cache $cache_folder --cache-min 99999999999 --shrinkwrap false --loglevel=error $pm2_package
  npm install --global --offline --cache $cache_folder --cache-min 99999999999 --shrinkwrap false --loglevel=error $pm2_service_package
  npm install --global --offline --cache $cache_folder --cache-min 99999999999 --shrinkwrap false --loglevel=error $pm2_logrotate_package

} else {
  
  Write-Host "Cache not detected, installing online.."
  
  npm install --global --loglevel=error $pm2_package
  npm install --global --loglevel=error $pm2_service_package
  npm install --global --loglevel=error $pm2_logrotate_package
}

Write-Host "=== Install Complete ==="
