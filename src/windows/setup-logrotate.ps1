Write-Host "=== Adding Log Rotation ==="

# Remember where we are
$wd = (Get-Item -Path '.\' -Verbose).FullName

$logrotate_directory = "$(npm config get prefix)\node_modules\pm2-logrotate\"

Write-Host "Using directory: $logrotate_directory"

cd $logrotate_directory
pm2 install .
pm2 save --force

# Go back to where we came from
cd $wd

Write-Host "=== Adding Log Rotation Complete ==="
