# Deploys PM2 as a Windows service
# Adapted from: https://gist.github.com/mauron85/e55b3b9d722f91366c50fddf2fca07a4

param([string] $Directory = "C:\ProgramData\pm2")

$ErrorActionPreference = "Stop"

# Query for the name of the Local Service user by its security identifier
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
$localServiceSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-19")
$User = ($localServiceSID.Translate([System.Security.Principal.NTAccount])).Value

Write-Host "=== Creating Service ==="
Write-Host "  PM2_HOME: $Directory"
Write-Host "  User:     $User"

function New-PM2-Home {
  Write-Host "Attempting to create `"$Directory`" and give FullControl to `"$User`""

  if (Test-Path $Directory) {
    Write-Host "`"$Directory`" already exists, no need to create it."
  } else {
    Write-Host "`"$Directory`" does not exist, creating it.."
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $User, "FullControl", "ContainerInherit, ObjectInherit",
    "None", "Allow")

  try {
    $acl = Get-Acl -Path  $Directory -ErrorAction Stop
    $acl.SetAccessRule($rule)
    Set-Acl -Path  $Directory -AclObject $acl -ErrorAction Stop
    Write-Host "Successfully set permissions on `"$Directory`"."
  } catch {
    throw "Failed to set permissions on `"$Directory`". Details: $_"
  }
}

function Set-Daemon-Permissions {
  $daemonPath = "$(npm config get prefix --global)\node_modules\@innomizetech\pm2-windows-service\src\daemon"
  Write-Host "Attempting to create `"$daemonPath`" and give FullControl to `"$User`""

  if (Test-Path $daemonPath) {
    Write-Host "`"$daemonPath`" already exists, no need to create it."
  } else {
    Write-Host "`"$daemonPath`" does not exist, creating it.."
    New-Item -ItemType Directory -Force -Path $daemonPath | Out-Null
  }

  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $User, "FullControl", "ContainerInherit, ObjectInherit",
    "None", "Allow")

  try {
    $acl = (Get-Item $daemonPath).GetAccessControl('Access')
    $acl.SetAccessRule($rule)
    Set-Acl -Path $daemonPath -AclObject $acl -ErrorAction Stop
    Write-Host "Successfully set permissions on `"$daemonPath`"."
  } catch {
    throw "Failed to set permissions on `"$daemonPath`". Details: $_"
  }
}

function Set-NPM-Folder-Permissions {
  $path = "$(npm config get prefix --global)"
  Write-Host "Attempting to give FullControl of `"$path`" to `"$User`""

  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $User, "FullControl", "ContainerInherit, ObjectInherit",
    "None", "Allow")

  try {
    $acl = (Get-Item $path).GetAccessControl('Access')
    $acl.SetAccessRule($rule)
    Set-Acl -Path $path -AclObject $acl -ErrorAction Stop
    Write-Host "Successfully set permissions on `"$path`"."
  } catch {
    throw "Failed to set permissions on `"$path`". Details: $_"
  }

  $path = "$(npm config get cache --global)"
  Write-Host "Attempting to give FullControl of `"$path`" to `"$User`""

  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $User, "FullControl", "ContainerInherit, ObjectInherit",
    "None", "Allow")

  try {
    $acl = (Get-Item $path).GetAccessControl('Access')
    $acl.SetAccessRule($rule)
    Set-Acl -Path $path -AclObject $acl -ErrorAction Stop
    Write-Host "Successfully set permissions on `"$path`"."
  } catch {
    throw "Failed to set permissions on `"$path`". Details: $_"
  }
}

function Install-PM2-Service {
  # Create wrapper log file, otherwise it won't start

  $wrapperLogPath = "$(npm config get prefix --global)\node_modules\@innomizetech\pm2-windows-service\src\daemon\pm2.wrapper.log"

  if (Test-Path $wrapperLogPath) {
    Write-Debug "PM2 service wrapper log file already exists"
  } else {
    Write-Debug "PM2 service wrapper log file does not exist. Creating.."
    Out-File $wrapperLogPath -Encoding utf8
  }

  # Ensure that the pm2-service-install command exists before attempting to invoke it

  if ([bool](Get-Command "pm2-service-install" -ErrorAction SilentlyContinue) -eq $False) {
    throw "pm2-windows-service is not installed."
  }

  Write-Host "Running pm2-service-install.."

  # node-windows creates services with the current working directory
  # pm2-service-install doesn't currently allow manually specifying the working directory when it invokes node-windows
  # However, if we just cd into the correct place before creating the service, it's almost good enough

  $wd = (Get-Item -Path '.\' -Verbose).FullName

  Set-Location $Directory

  pm2-service-install --unattended

  # Make sure this command succeeded

  if ($? -ne $True) {

    # Return back where we came from
    Set-Location $wd

    throw "pm2-service-install failed."
  }

  # Return back where we came from
  Set-Location $wd
}

# Adapted from http://stackoverflow.com/a/4370900/964356
function Set-ServiceUser {
  param([string] $serviceName, [string] $username, [string] $pass)

  # Write-Host "Set-ServiceUser -serviceName `"$serviceName`" -username `"$username`""

  # Create a filter to query for the service by

  $filter = "Name='$serviceName'"

  # Query for the service, wait a second if we can't find it right away

  $attempt = 0
  $maxAttempts = 10
  $service = $null

  while (($null -eq $service -and $attempt -le ($maxAttempts - 1))) {

    if ($attempt -ne 0) {
      Start-Sleep -Milliseconds 1000
      Write-Host "Attempt #$($attempt + 1) to locate `"$serviceName`" service.."
    }

    $service = Get-WMIObject -class Win32_Service -Filter $filter

    $attempt = $attempt + 1
  }

  if ($null -eq $service) {
    throw "Could not find `"$serviceName`" service after $maxAttempts attempts."
  }

  # Now that we have a reference to the service, change it's user account

  Write-Host "Found `"$serviceName`" service:"
  Write-Host "  State: $($service.State)"
  Write-Host "  Status: $($service.Status)"
  Write-Host "  Started: $($service.Started)"
  Write-Host "  Start Mode: $($service.StartMode)"
  Write-Host "  Start Name: $($service.StartName)"
  Write-Host "  Service Type: $($service.ServiceType)"

  # Stop the service
  Write-Host "Stopping service.."

  $response = $service.StopService()

  if ($response.ReturnValue -ne 0) {
    $message = Get-Service-Error-For-Code($response.ReturnValue)
    throw "Could not stop service: $message"
  }

  # Wait until it has stopped

  $service = Get-WMIObject -class Win32_Service -Filter $filter

  Write-Host "  State is now: $($service.State)"

  while ($service.State -ne 'Stopped') {

    Start-Sleep -Milliseconds 250
    $service = Get-WMIObject -class Win32_Service -Filter $filter
    Write-Host "  State is now: $($service.State)"
  }

  Write-Host "Changing service user account.."

  $response = $service.Change($null, $null, $null, $null, $null, $null, $username, $pass)

  if ($response.ReturnValue -ne 0) {
    $message = Get-Service-Error-For-Code($response.ReturnValue)
    throw "Could not change service user: $message"
  }

  # Start it up agian
  Write-Host "Starting service.."

  $response = $service.StartService()

  if ($response.ReturnValue -ne 0) {
    $message = Get-Service-Error-For-Code($response.ReturnValue)
    throw "Could not start service: $message"
  }

  # Wait until it has started

  $service = Get-WMIObject -class Win32_Service -Filter $filter

  Write-Host "  State is now: $($service.State)"

  while ($service.State -ne 'Running') {

    Start-Sleep -Milliseconds 250
    $service = Get-WMIObject -class Win32_Service -Filter $filter
    Write-Host "  State is now: $($service.State)"
  }

  Write-Host "Service `"$serviceName`" is now running as `"$($service.StartName)`""
  Write-Host "  State: $($service.State)"
  Write-Host "  Status: $($service.Status)"
  Write-Host "  Started: $($service.Started)"
  Write-Host "  Start Mode: $($service.StartMode)"
  Write-Host "  Service Type: $($service.ServiceType)"
}

function Set-PM2-Service-Account {
  Write-Host "Changing PM2 to run as `"$User`""
  Set-ServiceUser -serviceName "pm2.exe" -username $User -pass ""
}

# https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/startservice-method-in-class-win32-service
function Get-Service-Error-For-Code {
  param([int] $code = 0)

  switch ([int] $code) {
    0 { return 'Success' }
    1 { return 'Not Supported' }
    2 { return 'Access Denied' }
    3 { return 'Dependent Services Running' }
    4 { return 'Invalid Service Control' }
    5 { return 'Service Cannot Accept Control' }
    6 { return 'Service Not Active' }
    7 { return 'Service Request Timeout' }
    8 { return 'Unknown Failure' }
    9 { return 'Path Not Found' }
    10 { return 'Service Already Running' }
    11 { return 'Service Database Locked' }
    12 { return 'Service Dependency Deleted' }
    13 { return 'Service Dependency Failure' }
    14 { return 'Service Disabled' }
    15 { return 'Service Logon Failed' }
    16 { return 'Service Marked For Deletion' }
    17 { return 'Service No Thread' }
    18 { return 'Circular Dependency' }
    19 { return 'Duplicate Name' }
    20 { return 'Invalid Name' }
    21 { return 'Invalid Parameter' }
    22 { return 'Invalid Service Account' }
    23 { return 'Service Exists' }
    24 { return 'Service Paused' }
    default { return "Unknown Error: $code" }
  }
}

$env:PM2_HOME = $Directory
$env:PM2_SERVICE_PM2_DIR = "$(npm config get prefix --global)\node_modules\pm2\index.js"
# $env:PM2_SERVICE_SCRIPTS = " $Directory\ecosystem.json"

[Environment]::SetEnvironmentVariable("PM2_HOME", $env:PM2_HOME, "Machine")
[Environment]::SetEnvironmentVariable("PM2_SERVICE_PM2_DIR", $env:PM2_SERVICE_PM2_DIR, "Machine")
# [Environment]::SetEnvironmentVariable("PM2_SERVICE_SCRIPTS", $env:PM2_SERVICE_SCRIPTS, "Machine")

[Environment]::SetEnvironmentVariable("SET_PM2_HOME", "true", "Machine")
[Environment]::SetEnvironmentVariable("SET_PM2_SERVICE_PM2_DIR", "true", "Machine")
[Environment]::SetEnvironmentVariable("SET_PM2_SERVICE_SCRIPTS", "false", "Machine")

& New-PM2-Home
& Set-NPM-Folder-Permissions
& Set-Daemon-Permissions
& Install-PM2-Service
& Set-PM2-Service-Account

# Finally, invoke pm2 directly
pm2 list

Write-Host "=== Creating Service Complete ==="
