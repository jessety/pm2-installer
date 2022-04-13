Write-Host "=== Remove Log Rotation ==="

if (Get-Command "pm2" -ErrorAction SilentlyContinue) {

  # Delete the running module
  pm2 delete @jessety/pm2-logrotate --silent

  # Uninstall the module
  pm2 uninstall @jessety/pm2-logrotate --silent

} else {

  Write-Host "Command `"pm2`" not found, potentially because it has already been uninstalled."
  Write-Host "Not removing log rotation, since pm2 itself has already been removed."
}

Write-Host "=== Remove Log Rotation Complete ==="
