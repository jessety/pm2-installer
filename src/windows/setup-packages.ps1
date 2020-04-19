Write-Host "=== Install Packages ==="

$Epoch = Get-Date

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"
$cache_folder = ".\.npm_cache";
$cache_archive = ".\bundle.zip";

# Print out the versions of this package, node, and npm for this host
node src\bundle\current.js

if (Test-Path $cache_archive) {

  Write-Host "Cache detected, installing offline.."

  # Remove the existing cache directory, if one exists
  if (Test-Path $cache_folder) {
    Remove-Item $cache_folder -recurse | Out-Null
  }

  Write-Host "Decompressing cache.."
  $PriorToDecompression = Get-Date
  Expand-Archive -Path $cache_archive -DestinationPath .\
  $DecompressionDuration = $(Get-Date).Subtract($PriorToDecompression);
  Write-Host "Decompressing cache took $([Math]::Floor($DecompressionDuration.TotalSeconds)) seconds."

  # Read the bundle information file and compare it to the current host
  node src\bundle\compare.js

  # Verify the cache folder contents
  npm --offline --cache $cache_folder --optional cache verify

  Write-Host "Installing packages:"
  Write-Host " - $($pm2_package)"
  Write-Host " - $($pm2_service_package)"
  Write-Host " - $($pm2_logrotate_package)"

  $PriorToInstall = Get-Date

  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_service_package
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_logrotate_package

  $InstallDuration = $(Get-Date).Subtract($PriorToInstall);

  Write-Host "Installing packages took $([Math]::Floor($InstallDuration.TotalSeconds)) seconds."

} else {
  
  Write-Host "Cache not detected, installing online.."

  $PriorToInstall = Get-Date
  
  npm install --global --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global --loglevel=error --audit=false --no-fund $pm2_service_package
  npm install --global --loglevel=error --audit=false --no-fund $pm2_logrotate_package

  $InstallDuration = $(Get-Date).Subtract($PriorToInstall);

  Write-Host "Installing packages took $([Math]::Floor($InstallDuration.TotalSeconds)) seconds."
}

# Enable execution of pm2's powershell script, so the current user can interact with pm2
$script_path = "$(npm config get prefix)\pm2.ps1"
if (Test-Path $script_path) {

  Write-Host "Unblocking script at $script_path.."
  Unblock-File -Path $script_path
}

$TotalDuration = $(Get-Date).Subtract($Epoch);

Write-Host "=== Install Packages Complete: took $([Math]::Floor($TotalDuration.TotalSeconds)) seconds ==="
