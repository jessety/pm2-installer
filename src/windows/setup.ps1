Write-Host "=== Setup ==="

# Configure npm to use a global location accessible to all users instead of the current user's AppData directory
PowerShell -NoProfile -ExecutionPolicy Bypass .\src\windows\setup-npm.ps1 -Directory C:\ProgramData\npm

# Update the path, because that last command changed it
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install pm2 globally. Use local offline install bundle if possible, but fallback to online installation if necessary
PowerShell -NoProfile -ExecutionPolicy Bypass .\src\windows\setup-install.ps1

# Install service that runs pm2
PowerShell -NoProfile -ExecutionPolicy Bypass .\src\windows\setup-service.ps1 -Directory C:\ProgramData\pm2

# Add the logrotate module
cd "$(npm config get prefix)\node_modules\pm2-logrotate\"
pm2 install . --silent
pm2 save --force

Write-Host "=== Setup Complete ==="
