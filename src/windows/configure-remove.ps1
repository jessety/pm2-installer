Write-Host "=== Reverting npm Configuration ==="

# Revert the npm config changes made on installation
Write-Host "Resetting npm prefix config.."
npm config --global delete prefix

Write-Host "Resetting npm cache config.."
npm config --global delete cache

Write-Host "=== Reverting npm Configuration Complete ==="
