Write-Host "=== Remove Log Rotation ==="

if (Get-Command "pm2" -ErrorAction SilentlyContinue) {

  # Delete the running module
  pm2 delete pm2-logrotate --silent

  # Uninstall the module
  pm2 uninstall pm2-logrotate --silent

} else {

  Write-Host "Command `"pm2`" not found, potentially because it has already been uninstalled. Not removing log rotation, since pm2 itself has alrady been removed."
}

Write-Host "=== Remove Log Rotation Complete ==="
