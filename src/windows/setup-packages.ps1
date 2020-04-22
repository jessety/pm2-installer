Write-Host "=== Install Packages ==="

$Epoch = Get-Date

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"

$cache_folder = ".\.npm_cache";
$cache_archive_tar=".\bundle.tar.gz"
$cache_archive_zip = ".\bundle.zip";

# Print out the versions of this package, node, and npm for this host
node src\bundle\current.js

# Check for the presense of an offline bundle, which could be either bundle.tar.gz or bundle.zip

if ((Test-Path $cache_archive_tar) -or (Test-Path $cache_archive_zip)) {

  # Remove the existing cache directory, if one exists
  if (Test-Path $cache_folder) {
    Remove-Item $cache_folder -recurse | Out-Null
  }

  # Check if tar.exe is available and if a .tar.gz bundle is included. If so, extract that.
  # Otherwise, extract the .zip file
  # tar.exe is significantly faster, but might not be available

  if ((Get-Command "tar.exe" -ErrorAction SilentlyContinue) -and (Test-Path $cache_archive_tar)) {

    Write-Host "Cache tar bundle detected. Decompressing.."

    $BeforeTar = Get-Date
    tar.exe -xzf $cache_archive_tar
    Write-Host "Decompressing $cache_archive_tar took $([Math]::Floor($(Get-Date).Subtract($BeforeTar).TotalSeconds)) seconds."

  } else {

    Write-Host "Cache zip bundle detected. Decompressing.."

    $BeforeZip = Get-Date
    Expand-Archive -Force -Path $cache_archive_zip -DestinationPath .\
    Write-Host "Decompressing $cache_archive_zip took $([Math]::Floor($(Get-Date).Subtract($BeforeZip).TotalSeconds)) seconds."
  }

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

  Write-Host "Installing packages took $([Math]::Floor($(Get-Date).Subtract($PriorToInstall).TotalSeconds)) seconds."

} else {
  
  Write-Host "Cache bundle not detected, installing online.."

  $PriorToInstall = Get-Date
  
  npm install --global --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global --loglevel=error --audit=false --no-fund $pm2_service_package
  npm install --global --loglevel=error --audit=false --no-fund $pm2_logrotate_package

  Write-Host "Installing packages took $([Math]::Floor($(Get-Date).Subtract($PriorToInstall).TotalSeconds)) seconds."
}

# Enable execution of pm2's powershell script, so the current user can interact with pm2
$script_path = "$(npm config get prefix)\pm2.ps1"
if (Test-Path $script_path) {

  Write-Host "Unblocking script at $script_path.."
  Unblock-File -Path $script_path
}

$TotalDuration = $(Get-Date).Subtract($Epoch);

Write-Host "=== Install Packages Complete: took $([Math]::Floor($TotalDuration.TotalSeconds)) seconds ==="
