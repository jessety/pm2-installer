Write-Host "=== Install Packages ==="

$Epoch = Get-Date

$pm2_package = "$(node src/tools/dependencies/echo.js pm2)"
$pm2_logrotate_package = "$(node src/tools/dependencies/echo.js @jessety/pm2-logrotate)"
$node_windows_package = "$(node src/tools/dependencies/echo.js node-windows)"

$cache_folder = ".\.npm_cache"
$cache_archive_tar = ".\bundle.tar.gz"
$cache_archive_zip = ".\bundle.zip"
$bundle_info = ".\bundle.json"

# Print out the versions of this package, node, and npm for this host
node src\bundle-info\current.js

Write-Host "Using: "
Write-Host " $pm2_package"
Write-Host " $pm2_logrotate_package"
Write-Host " $node_windows_package"

# Check connectivity to registry.npmjs.org
node src\tools\npm-online.js

if ($? -eq $True) {

  # We *can* connect to the npm registry

  Write-Host "Installing packages.."

  $PriorToInstall = Get-Date

  npm install --global --loglevel=error --no-audit --no-fund $pm2_package
  npm install --global --loglevel=error --no-audit --no-fund $pm2_logrotate_package
  npm install --global --loglevel=error --no-audit --no-fund $node_windows_package

  Write-Host "Installing packages took $([Math]::Floor($(Get-Date).Subtract($PriorToInstall).TotalSeconds)) seconds."

  Write-Host "Linking node-windows.."
  npm link node-windows --loglevel=error --no-fund --no-audit --production --only=production --omit=dev

} elseif ((Test-Path $cache_archive_tar) -or (Test-Path $cache_archive_zip) -or (Test-Path $cache_folder)) {

  Write-Host "Cannot connect to the npm registry. Checking for offline bundle.."

  # If tar.exe is available and a .tar.gz bundle is included, extract it.
  # tar.exe is significantly faster, but might not be available.
  # Otherwise, check for the presence of the Expand-Archive command and extract the zip.
  # Finally, if neither the tar nor the zip can be extracted, check for an already-extracted cache folder
  # If none of those conditions are satisifed, notify the user to extract a bundle manually.

  if ((Get-Command "tar.exe" -ErrorAction SilentlyContinue) -and (Test-Path $cache_archive_tar)) {

    Write-Host "Cache tar bundle detected. Decompressing.."

    # Remove the existing cache folder
    if (Test-Path $cache_folder) {
      Remove-Item $cache_folder -recurse | Out-Null
    }

    $BeforeTar = Get-Date
    tar.exe -xzf $cache_archive_tar
    Write-Host "Decompressing $cache_archive_tar took $([Math]::Floor($(Get-Date).Subtract($BeforeTar).TotalSeconds)) seconds."

  } elseif ((Get-Command "Expand-Archive" -ErrorAction SilentlyContinue) -and (Test-Path $cache_archive_zip)) {

    Write-Host "Cache zip bundle detected. Decompressing.."

    # Remove the existing cache folder
    if (Test-Path $cache_folder) {
      Remove-Item $cache_folder -recurse | Out-Null
    }

    $BeforeZip = Get-Date
    Expand-Archive -Force -Path $cache_archive_zip -DestinationPath .\
    Write-Host "Decompressing $cache_archive_zip took $([Math]::Floor($(Get-Date).Subtract($BeforeZip).TotalSeconds)) seconds."

  } elseif (Test-Path $cache_folder) {

    Write-Host "Cache folder $cache_folder detected."

  } else {

    # The npm registry is unavailable, there's no cache folder, and although a bundle was detected, we can't extract it.

    if (Test-Path $cache_archive_tar) {
      Write-Host "$cache_archive_tar was detected, but tar.exe is unavailable. It was introduced in Windows 10 version 1803 in April 2018."
    }

    if (Test-Path $cache_archive_zip) {
      Write-Host "$cache_archive_zip was detected, but the PowerShell Expand-Archive cmdlet is unavailable. It was introduced in PowerShell 5.0 in February 2016."
    }

    Write-Error "Could not extract offline bundle. Expand $cache_archive_tar or $cache_archive_zip manually and run this script again." -ErrorAction Stop
  }

  # Read the bundle information file and compare it to the current host
  if (Test-Path $bundle_info) {
    node src\bundle-info\compare.js
  }

  # Verify the cache folder contents
  npm --offline --cache $cache_folder --optional cache verify

  Write-Host "Installing packages.."

  $PriorToInstall = Get-Date

  Write-Host "Installing $pm2_package.."
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $pm2_package
  Write-Host "Installing $pm2_logrotate_package.."
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $pm2_logrotate_package
  Write-Host "Installing $node_windows_package.."
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $node_windows_package

  Write-Host "Installing packages took $([Math]::Floor($(Get-Date).Subtract($PriorToInstall).TotalSeconds)) seconds."

  # Strip dependencies from package.json
  # This is because `npm link` fails while attempting to install dev dependencies that aren't cached when offline
  Write-Host "Stripping dependencies..."
  node src\tools\dependencies\strip.js

  Write-Host "Linking node-windows.."
  npm link node-windows --loglevel=error --no-fund --no-audit --production --only=production --offline --omit=dev

  # Restore dependencies to package.json
  Write-Host "Restoring dependencies..."
  node src\tools\dependencies\restore.js

} else {

  Write-Host "Cannot connect to the npm registry, and no offline bundle was found. Attempting install anyway.."

  # This will probably not work.

  npm install --global --loglevel=error --no-audit --no-fund $pm2_package
  npm install --global --loglevel=error --no-audit --no-fund $pm2_logrotate_package
  npm install --global --loglevel=error --no-audit --no-fund $node_windows_package

  Write-Host "Linking node-windows.."
  npm link node-windows --loglevel=error --no-fund --no-audit --production --only=production --omit=dev
}

# Enable execution of pm2's powershell script, so the current user can interact with the pm2 powershell script
$script_path = "$(npm config get prefix)\pm2.ps1"
if (Test-Path $script_path) {

  Write-Host "Unblocking script at $script_path.."
  Unblock-File -Path $script_path
}

$TotalDuration = $(Get-Date).Subtract($Epoch)

Write-Host "=== Install Packages Complete: took $([Math]::Floor($TotalDuration.TotalSeconds)) seconds ==="
