Write-Host "=== Setup ==="

# Check the npm configuration to ensure the prefix isn't in the current user's appdata folder
$continue = &".\src\windows\configure-check.ps1" | select -Last 1

if ($continue -eq 'n') {
  Write-Host "=== Setup Canceled ==="
  exit
}

# Install all required npm packages
# Use local offline install bundle if possible, but fallback to online installation
& .\src\windows\setup-packages.ps1

# Install service that runs pm2
& .\src\windows\setup-service.ps1

# Add the logrotate module
& .\src\windows\setup-logrotate.ps1

Write-Host "`nTo interact with pm2, close this window and start a new terminal session."
Write-Host "Alternatively, update your PM2_HOME env variable in this session by executing:`n  `$Env:PM2_HOME=`"$Env:PM2_HOME`"`n"

Write-Host "=== Setup Complete ===`n"
