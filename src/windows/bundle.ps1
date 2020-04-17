Write-Host "=== Bundle ==="

$Epoch = Get-Date

$pm2_package = "$(node src/echo-dependency.js pm2)"
$pm2_service_package = "$(node src/echo-dependency.js pm2-windows-service)";
$pm2_logrotate_package = "$(node src/echo-dependency.js pm2-logrotate)"
$cache_folder = ".\.npm_cache";
$cache_archive = ".\bundle.zip";
$node_modules = ".\node_modules";

# Remove the node_modules folder, if one exists
if (Test-Path $node_modules) {
  Write-Host "Existing $node_modules folder detected, removing.."
  Remove-Item $node_modules -recurse | Out-Null
}

# Remove any existing cache archive
if (Test-Path $cache_archive) {
  Write-Host "Existing cache archive file detected, removing.."
  Remove-Item $cache_archive | Out-Null
}

# Remove the existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Existing cache folder detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
}

# Create a new npm cache folder
New-Item -ItemType Directory -Name $cache_folder | Out-Null

Write-Host "Populating cache folder with all dependencies.."
$PopulationDuration = Measure-Command { 
  npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_service_package
  npm install --global-style --force --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_logrotate_package
}
Write-Host "Populating cache took $([Math]::Floor($PopulationDuration.TotalSeconds)) seconds."

Write-Host "Compressing cache.."
$CompressionDuration = Measure-Command { 
  Compress-Archive -CompressionLevel Fastest -Path $cache_folder -DestinationPath $cache_archive
}
Write-Host "Compressing cache took $([Math]::Floor($CompressionDuration.TotalSeconds)) seconds."

Write-Host "Removing uncompressed cache folder.."
Remove-Item $node_modules -recurse | Out-Null
Remove-Item $cache_folder -recurse | Out-Null

# Write system information to bundle file
node src\bundle\write.js

$Duration = $(Get-Date).Subtract($Epoch);

Write-Host "=== Bundle Complete: took $([Math]::Floor($Duration.TotalSeconds)) seconds ==="
