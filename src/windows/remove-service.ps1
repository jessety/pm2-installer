Write-Host "=== Remove Service ==="

if (Get-Command "pm2" -ErrorAction SilentlyContinue) {
  Write-Host "Deleting all pm2 processes.."
  pm2 uninstall pm2-logrotate --silent
  pm2 save --force --silent
} else {
  Write-Host "Command pm2 not found, potentially because it has already been uninstalled."
}

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
