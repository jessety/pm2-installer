Write-Host "=== Remove Service ==="

$command = "pm2-service-uninstall"

if (Get-Command $command -ErrorAction SilentlyContinue) {
  Write-Host "Running $command.."
  & $command
} else {
  Write-Host "Command $command not found, likely because it has already been uninstalled."
}

Write-Host "Resetting system environmental variables"

[Environment]::SetEnvironmentVariable("PM2_HOME", $null, "Machine")
[Environment]::SetEnvironmentVariable("PM2_SERVICE_PM2_DIR", $null, "Machine")
# [Environment]::SetEnvironmentVariable("PM2_SERVICE_SCRIPTS", $null, "Machine")

[Environment]::SetEnvironmentVariable("SET_PM2_HOME", $null, "Machine")
[Environment]::SetEnvironmentVariable("SET_PM2_SERVICE_PM2_DIR", $null, "Machine")
[Environment]::SetEnvironmentVariable("SET_PM2_SERVICE_SCRIPTS", $null, "Machine")


Write-Host "Resetting shell environmental variables"

$env:PM2_HOME = $null
$env:PM2_SERVICE_PM2_DIR = $null
$env:PM2_SERVICE_PM2_DIR = $null
$env:SET_PM2_HOME = $null
$env:SET_PM2_SERVICE_PM2_DIR = $null
$env:SET_PM2_SERVICE_SCRIPTS = $null

Write-Host "=== Remove Service Complete ==="
