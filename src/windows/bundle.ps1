Write-Host "=== Bundle ==="

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"
$cache_folder = ".\.npm_cache";

# Remove the existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Existing cache detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
}

# Create a new npm cache folder
New-Item -ItemType Directory -Name $cache_folder | Out-Null

Write-Host "Populating cache with all global dependencies.."
npm install --global --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_package
npm install --global --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_service_package
npm install --global --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_logrotate_package

# Write system information to bundle file
node src\bundle\write.js

Write-Host "=== Bundle Complete ==="
