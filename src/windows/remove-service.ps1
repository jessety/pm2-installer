Write-Host "=== Remove Service ==="

$PM2_HOME = $env:PM2_HOME;
$PM2_SERVICE_DIRECTORY = $env:PM2_SERVICE_DIRECTORY;

function Stop-Service {
  param([string] $name)

  # Create a filter to query for the service by

  $filter = "Name='$name'"

  # Query for the service, wait a second if we can't find it right away

  $attempt = 0
  $maxAttempts = 10
  $service = $null

  while (($null -eq $service -and $attempt -le ($maxAttempts - 1))) {

    if ($attempt -ne 0) {
      Start-Sleep -Milliseconds 500
      Write-Host "Attempt #$($attempt) to locate service `"$name`" failed, trying again.."
    }

    $service = Get-WMIObject -class Win32_Service -Filter $filter

    $attempt = $attempt + 1
  }

  if ($null -eq $service) {
    Write-Host "Could not find `"$name`" service after $maxAttempts attempts. It has likely already been uninstalled."
    return;
  }

  Write-Host "Found `"$name`" service:"
  Write-Host "  State: $($service.State)"
  Write-Host "  Status: $($service.Status)"
  Write-Host "  Started: $($service.Started)"
  Write-Host "  Start Mode: $($service.StartMode)"
  Write-Host "  Service Type: $($service.ServiceType)"
  Write-Host "  Start Name: $($service.StartName)"

  if ($service.State -eq 'Stopped') {
    Write-Host "Service is already stopped."
    return;
  }

  Write-Host "Sending stop command, this may take a minute.."

  $response = $service.StopService()

  if ($response.ReturnValue -ne 0) {
    $message = Get-Service-Error-For-Code($response.ReturnValue)
    throw "Could not stop service: $message"
  }

  # Wait until it has stopped

  $service = Get-WMIObject -class Win32_Service -Filter $filter

  Write-Host "  Service state is: $($service.State)"

  while ($service.State -ne 'Stopped') {

    Start-Sleep -Milliseconds 250
    $service = Get-WMIObject -class Win32_Service -Filter $filter
    Write-Host "  Service state is: $($service.State)"
  }

  Write-Host "Service stopped."
}

Write-Host "Stopping service, this may take a minute or so.."
Stop-Service -name "pm2.exe"

Write-Host "Running pm2 kill.."
pm2 kill --silent

$wd = (Get-Item -Path '.\' -Verbose).FullName

if (($null -ne $PM2_SERVICE_DIRECTORY) -and (Test-Path $PM2_SERVICE_DIRECTORY)) {
  Set-Location $PM2_SERVICE_DIRECTORY
}

Write-Host "Running Node service uninstall script.."

node "$wd\src\windows\service-management\uninstall.js" $PM2_SERVICE_DIRECTORY

if ($? -ne $True) {
  Set-Location $wd
  throw "Service uninstall script failed."
}

if (($null -ne $PM2_SERVICE_DIRECTORY) -and (Test-Path $PM2_SERVICE_DIRECTORY)) {
  # Write-Host "Unlinking node-windows in $PM2_SERVICE_DIRECTORY"
  # npm unlink node-windows --loglevel=error --no-fund --no-audit

  Set-Location $wd

  Write-Host "Deleting pm2 service directory `"$PM2_SERVICE_DIRECTORY`""
  Remove-Item $PM2_SERVICE_DIRECTORY -Recurse -Force | Out-Null
}

if (($null -ne $PM2_HOME) -and (Test-Path $PM2_HOME)) {

  Write-Host "Deleting pm2 home directory `"$PM2_HOME`""
  Remove-Item $PM2_HOME -Recurse -Force | Out-Null
}

$PM2_PARENT_FOLDER = "$($env:ProgramData)\pm2"
if (($null -ne $PM2_PARENT_FOLDER) -and (Test-Path $PM2_PARENT_FOLDER)) {

  Write-Host "Deleting `"$PM2_PARENT_FOLDER`""
  Remove-Item $PM2_PARENT_FOLDER -Recurse -Force | Out-Null
}

Write-Host "Resetting shell environmental variables.."

$env:PM2_HOME = $null
$env:PM2_INSTALL_DIRECTORY = $null
$env:PM2_SERVICE_DIRECTORY = $null

Write-Host "Resetting machine environmental variables.."

[Environment]::SetEnvironmentVariable("PM2_HOME", $env:PM2_HOME, "Machine")
[Environment]::SetEnvironmentVariable("PM2_INSTALL_DIRECTORY", $env:PM2_INSTALL_DIRECTORY, "Machine")
[Environment]::SetEnvironmentVariable("PM2_SERVICE_DIRECTORY", $env:PM2_SERVICE_DIRECTORY, "Machine")

Set-Location $wd

Write-Host "=== Remove Service Complete ==="
