Write-Host "=== Adding Log Rotation ==="

# Check connectivity to registry.npmjs.org
node src\tools\npm-online.js

if ($? -eq $True) {

  $logrotate_package = "$(node src/tools/dependencies/echo.js @jessety/pm2-logrotate)"

  Write-Host "Installing $logrotate_package online.."

  pm2 install $logrotate_package --silent

} else {

  $logrotate_directory = "$(npm config get prefix)\node_modules\@jessety\pm2-logrotate\"

  Write-Host "Installing pm2-logrotate locally in directory: $logrotate_directory"

  # Remember where we are
  $wd = (Get-Item -Path '.\' -Verbose).FullName

  Set-Location $logrotate_directory

  pm2 install . --silent

  # Go back to where we were
  Set-Location $wd
}

pm2 save --force

Write-Host "=== Adding Log Rotation Complete ==="
