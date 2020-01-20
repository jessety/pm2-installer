Write-Host "=== Bundle ==="

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"
$cache_folder = ".\.npm_cache";
$node_modules = ".\node_modules";

# Remove the existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Existing cache detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
}

# Create a new npm cache folder
New-Item -ItemType Directory -Name $cache_folder | Out-Null

Write-Host "Temporarily uninstalling dependencies.."
npm uninstall --global-style --loglevel=error "pm2"
npm uninstall --global-style --loglevel=error "@innomizetech/pm2-windows-service"
npm uninstall --global-style --loglevel=error "pm2-logrotate"

Write-Host "Populating cache with all dependencies.."
npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_package
npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_service_package
npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_logrotate_package

Write-Host "Removing local npm_modules folder.."
Remove-Item $node_modules -recurse | Out-Null

# Write system information to bundle file
node src\bundle\write.js

Write-Host "=== Bundle Complete ==="
