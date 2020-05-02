Write-Host "=== Remove Log Rotation ==="

# Delete the running module
pm2 delete pm2-logrotate --silent

# Uninstall the module
pm2 uninstall pm2-logrotate --silent 

Write-Host "=== Remove Log Rotation Complete ==="
