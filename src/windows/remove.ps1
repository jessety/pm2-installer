Write-Host "=== Remove ==="

# Remove the service, and reset associated environmental variables
& .\src\windows\remove-service.ps1

# Uninstall packages
& .\src\windows\remove-packages.ps1

# Revert npm configuration
# This is now broken out into it's own script and not a part of the setup process
# Therefore, it isn't a part of the standard removal process either
# & .\src\windows\configure-remove.ps1

Write-Host "=== Remove Complete ==="
