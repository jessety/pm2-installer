Write-Host "=== Setup ==="

# Load the latest path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Confirm this script is running with administrator rights
$continue = &".\src\windows\check-administrator.ps1" | Select-Object -Last 1

if ($continue -eq 'n') {
  Write-Host "Administrator privileges are required to install the service.`nPlease run this script in an admin prompt.`n"
  Write-Host "=== Setup Canceled ==="
  exit
}

# Check the npm configuration to confirm the prefix isn't in the current user's appdata folder
$continue = &".\src\windows\check-configuration.ps1" | Select-Object -Last 1

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

Write-Host "=== Setup Complete ===`n"

Write-Host "`nTo interact with pm2, close this window and start a new terminal session."
Write-Host "Alternatively, update your PM2_HOME env variable in this session by executing:`n  `$Env:PM2_HOME=`"$Env:PM2_HOME`"`n"
