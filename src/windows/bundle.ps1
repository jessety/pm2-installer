Write-Host "=== Bundle ==="

$Epoch = Get-Date

$pm2_package = "$(node src/tools/dependencies/echo.js pm2)"
$pm2_logrotate_package = "$(node src/tools/dependencies/echo.js @jessety/pm2-logrotate)"
$node_windows_package = "$(node src/tools/dependencies/echo.js node-windows)"

$cache_folder = ".\.npm_cache";
$cache_archive_tar=".\bundle.tar.gz"
$cache_archive_zip = ".\bundle.zip";
$node_modules = ".\node_modules";

# Remove any existing cache tar archive
if (Test-Path $cache_archive_tar) {
  Write-Host "Existing cache tar file detected, removing.."
  Remove-Item $cache_archive_tar | Out-Null
}

# Remove any existing cache zip archive
if (Test-Path $cache_archive_zip) {
  Write-Host "Existing cache zip file detected, removing.."
  Remove-Item $cache_archive_zip | Out-Null
}

# Remove existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Existing cache folder detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
}

# Remove existing node_modules folder, if one exists
if (Test-Path $node_modules) {
  Write-Host "Existing node_modules folder detected, removing.."
  Remove-Item $node_modules -recurse | Out-Null
}

# Create a new npm cache folder
New-Item -ItemType Directory -Name $cache_folder | Out-Null

Write-Host "Populating cache folder with all dependencies.."

$BeforePopulation = Get-Date

npm install --no-save --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $pm2_package
npm install --no-save --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $pm2_logrotate_package
npm install --no-save --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund $node_windows_package
Write-Host "Populating cache took $([Math]::Floor($(Get-Date).Subtract($BeforePopulation).TotalSeconds)) seconds."

if (Get-Command "tar.exe" -ErrorAction SilentlyContinue) {

  Write-Host "Compressing cache using tar.exe.."

  $BeforeTar = Get-Date
  tar -czf $cache_archive_tar $cache_folder
  Write-Host "Compressing cache into $cache_archive_tar took $([Math]::Floor($(Get-Date).Subtract($BeforeTar).TotalSeconds)) seconds."

} else {

  Write-Host "WARNING: tar.exe is not available, not compressing dependencies into $cache_archive_tar."
  Write-Host "         Offline installs will use .zip instead, and may be considerably slower."
}

Write-Host "Compressing cache using Compress-Archive.."

$BeforeZip = Get-Date
Compress-Archive -CompressionLevel Fastest -Path $cache_folder -DestinationPath $cache_archive_zip
Write-Host "Compressing cache into $cache_archive_zip took $([Math]::Floor($(Get-Date).Subtract($BeforeZip).TotalSeconds)) seconds."

Write-Host "Removing uncompressed cache folder.."
Remove-Item $node_modules -recurse | Out-Null
Remove-Item $cache_folder -recurse | Out-Null

# Write system information to bundle file
node src\bundle-info\write.js

$TotalDuration = $(Get-Date).Subtract($Epoch);

Write-Host "=== Bundle Complete: took $([Math]::Floor($TotalDuration.TotalSeconds)) seconds ==="
