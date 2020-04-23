Write-Host "=== Unbundle ==="

$cache_folder = ".\.npm_cache";
$cache_archive_tar=".\bundle.tar.gz"
$cache_archive_zip = ".\bundle.zip";
$node_modules = ".\node_modules";
$bundle_info = ".\bundle.json";

# Remove any existing cache tar archive
if (Test-Path $cache_archive_tar) {
  Write-Host "Cache tar archive detected, removing.."
  Remove-Item $cache_archive_tar | Out-Null
} else {
  Write-Host "Cache tar archive not detected."
}

# Remove any existing cache zip archive
if (Test-Path $cache_archive_zip) {
  Write-Host "Cache zip archive detected, removing.."
  Remove-Item $cache_archive_zip | Out-Null
} else {
  Write-Host "Cache zip archive not detected."
}

# Remove existing npm cache, if one exists
if (Test-Path $cache_folder) {
  Write-Host "Cache folder detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
} else {
  Write-Host "Cache folder not detected."
}

# Remove existing node_modules folder, if one exists
if (Test-Path $node_modules) {
  Write-Host "node_modules folder detected, removing.."
  Remove-Item $node_modules -recurse | Out-Null
} else {
  Write-Host "node_modules folder not detected."
}

# Remove the existing bundle file
if (Test-Path $bundle_info) {
  Write-Host "Bundle info file detected, removing.."
  Remove-Item $bundle_info | Out-Null
} else {
  Write-Host "Bundle info file not detected."
}

Write-Host "=== Unbundle Complete ==="
