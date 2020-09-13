Write-Host "=== Remove ==="

# Load the latest path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Confirm this script is running with administrator rights
$continue = &".\src\windows\check-administrator.ps1" | Select-Object -Last 1

if ($continue -eq 'n') {
  Write-Host "Administrator privileges are required to remove the service.`nPlease run this script in an admin prompt.`n"
  Write-Host "=== Remove Canceled ==="
  exit
}

# Remove logrotate module
& .\src\windows\remove-logrotate.ps1

# Remove the service, and reset associated environmental variables
& .\src\windows\remove-service.ps1

# Uninstall packages
& .\src\windows\remove-packages.ps1

# Revert npm configuration
# This is now broken out into it's own script and not a part of the setup process
# Therefore, it isn't a part of the standard removal process either
# & .\src\windows\configure-remove.ps1

Write-Host "=== Remove Complete ==="
