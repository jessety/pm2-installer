Write-Host "=== Checking Script Privileges ==="

$role = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
$admin = [Security.Principal.WindowsBuiltInRole] "Administrator"

if ($role.IsInRole($admin) -ne $True) {

  Write-Warning "Script is not running as administrator."
  Write-Output "n"
  exit

} else {

  Write-Host "Script is running as administrator."
  Write-Output "y"
}

Write-Host "=== Checking Script Privileges Complete ==="
