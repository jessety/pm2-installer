Write-Host "=== Unbundle ==="

$cache_folder = ".\.npm_cache";
$bundle_file = ".\bundle.json";

# Remove the existing npm cache
if (Test-Path $cache_folder) {
  Write-Host "Cache detected, removing.."
  Remove-Item $cache_folder -recurse | Out-Null
} else {
  Write-Host "Cache not detected."
}

# Remove the existing bundle file
if (Test-Path $bundle_file) {
  Write-Host "Bundle file detected, removing.."
  Remove-Item $bundle_file | Out-Null
} else {
  Write-Host "Bundle not detected."
}

Write-Host "=== Unbundle Complete ==="
