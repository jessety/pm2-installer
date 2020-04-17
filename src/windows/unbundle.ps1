Write-Host "=== Unbundle ==="

$cache_folder = ".\.npm_cache";
$cache_archive = ".\bundle.zip";
$node_modules = ".\node_modules";
$bundle_file = ".\bundle.json";

# Remove the existing cache archive
if (Test-Path $cache_archive) {
  Write-Host "Bundle archive detected, removing.."
  Remove-Item $cache_archive | Out-Null
} else {
  Write-Host "Bundle archive not detected."
}

# Remove the existing bundle file
if (Test-Path $bundle_file) {
  Write-Host "Bundle info file detected, removing.."
  Remove-Item $bundle_file | Out-Null
} else {
  Write-Host "Bundle info file not detected."
}

# Remove the existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Cache folder detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
}

# Remove the node_modules folder, if one exists
if (Test-Path $node_modules) {
  Write-Host "node_modules folder detected, removing.."
  Remove-Item $node_modules -recurse | Out-Null
}


Write-Host "=== Unbundle Complete ==="
