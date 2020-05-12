param([string] $name = "pm2.exe")

Write-Host "Confirm-Service -name `"$name`""

# Create a filter to query for the service by

$filter = "Name='$name'"

# Query for the service, wait a second if we can't find it right away

$attempt = 0
$maxAttempts = 10
$service = $null

while (($null -eq $service -and $attempt -le ($maxAttempts - 1))) {

  if ($attempt -ne 0) {
    Start-Sleep -Milliseconds 250
    Write-Host "Attempt #$($attempt + 1) to locate `"$name`" service.."
  }

  $service = Get-WMIObject -class Win32_Service -Filter $filter

  $attempt = $attempt + 1
}

if ($null -eq $service) {
  throw "Could not find `"$name`" service after $maxAttempts attempts."
}

Write-Host "Found `"$name`" service:"
Write-Host "  State: $($service.State)"
Write-Host "  Status: $($service.Status)"
Write-Host "  Started: $($service.Started)"
Write-Host "  Start Mode: $($service.StartMode)"
Write-Host "  Service Type: $($service.ServiceType)"
Write-Host "  Start Name: $($service.StartName)"
