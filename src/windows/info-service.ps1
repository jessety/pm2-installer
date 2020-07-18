param([string] $name = "pm2.exe")

Write-Host "`n=== Printing Service Info ==="

# Print out the versions of this package, node, and npm

node src\bundle-info\current.js

# Create a filter to query for the service by

$filter = "Name='$name'"

# Query for the service, wait a second if we can't find it right away

$attempt = 0
$maxAttempts = 10
$service = $null

while (($null -eq $service -and $attempt -le ($maxAttempts - 1))) {

  if ($attempt -ne 0) {
    Start-Sleep -Milliseconds 100
    Write-Host "Attempt #$($attempt) to locate service `"$name`" failed, trying again.."
  }

  $service = Get-WMIObject -class Win32_Service -Filter $filter

  $attempt = $attempt + 1
}

if ($null -eq $service) {
  throw "Could not find `"$name`" service after $maxAttempts attempts."
}

Write-Host "`nFound `"$name`" service:"

Write-Host "  State: $($service.State)"
Write-Host "  Status: $($service.Status)"
Write-Host "  Started: $($service.Started)"
Write-Host "  Start Mode: $($service.StartMode)"
Write-Host "  Service Type: $($service.ServiceType)"
Write-Host "  Start Name: $($service.StartName)"
Write-Host ""
Write-Host "  Display Name: $($service.DisplayName)"
Write-Host "  Description: $($service.Description)"
Write-Host "  Path Name: $($service.PathName)"
Write-Host "  System Name: $($service.SystemName)"
Write-Host "  Install Date: $($service.InstallDate)"
Write-Host "  Check Point: $($service.CheckPoint)"
Write-Host "  Service Specific Exit Code: $($service.ServiceSpecificExitCode)"
Write-Host "  Exit Code: $($service.ExitCode)"


$service = Get-Service $name
if ($service.RequiredServices) {
  write-Host "  Requires:"
  foreach ($item in $service.RequiredServices) {
    Write-Host "    $($item.name)"
  }
}

if ($service.DependentServices) {
  write-Host "  Depended on by:"
  foreach ($item in $service.DependentServices) {
    Write-Host "    $($item.name)"
  }
}

Write-Host ""
