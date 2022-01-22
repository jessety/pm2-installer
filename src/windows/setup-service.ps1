param(
  [string] $PM2_HOME = "$($env:ProgramData)\pm2\home",
  [string] $PM2_SERVICE_DIRECTORY = "$($env:ProgramData)\pm2\service"
)

$ErrorActionPreference = "Stop"

function Set-ENV {
  $env:PM2_HOME = $PM2_HOME
  $env:PM2_INSTALL_DIRECTORY = $PM2_INSTALL_DIRECTORY
  $env:PM2_SERVICE_DIRECTORY = $PM2_SERVICE_DIRECTORY

  [Environment]::SetEnvironmentVariable("PM2_HOME", $env:PM2_HOME, "Machine")
  [Environment]::SetEnvironmentVariable("PM2_INSTALL_DIRECTORY", $env:PM2_INSTALL_DIRECTORY, "Machine")
  [Environment]::SetEnvironmentVariable("PM2_SERVICE_DIRECTORY", $env:PM2_SERVICE_DIRECTORY, "Machine")
}

function New-Directory {
  param([string] $Directory)

  Write-Host "Attempting to create `"$Directory`""

  if (Test-Path $Directory) {
    Write-Host "Directory `"$Directory`" already exists, no need to create it."
  } else {
    Write-Host "Directory `"$Directory`" does not exist, creating it.."
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }
}

function Set-Permissions {
  param([string] $Directory, [string] $User)

  Write-Host "Attempting to grant `"$User`" full permissions to `"$Directory`"."

  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

  try {
    $acl = Get-Acl -Path $Directory -ErrorAction Stop

    # $acl.SetAccessRuleProtection($true, $false)
    # $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }

    $acl.SetAccessRule($rule)

    Set-Acl -Path $Directory -AclObject $acl -ErrorAction Stop

    Write-Host "Successfully set permissions on `"$Directory`"."

  } catch {

    throw "Failed to set permissions on `"$Directory`". Details: $_"
  }
}
function Install-Service-Files {

  # First, copy the service files

  $source = ".\src\windows\service\"

  Write-Host "Copying service files from `"$source`" to `"$PM2_SERVICE_DIRECTORY`".."

  Copy-Item -Path $source\* -Destination $PM2_SERVICE_DIRECTORY -Recurse -Force

  Write-Host "Copying files complete."

  # Next, link node-windows in that directory

  # Write-Host "Service filed copied over. Linking node-windows in `"$PM2_SERVICE_DIRECTORY`".."

  # $wd = (Get-Item -Path '.\' -Verbose).FullName

  # Set-Location $PM2_SERVICE_DIRECTORY
  # npm link node-windows --loglevel=error --no-fund --no-audit
  # Set-Location $wd

  # Write-Host "Linked node-windows in $PM2_SERVICE_DIRECTORY"
}

function Install-Service {
  param([string] $Directory, [string] $User)

  Write-Host "Running Node service install script.."

  $wd = (Get-Item -Path '.\' -Verbose).FullName

  Set-Location $PM2_SERVICE_DIRECTORY
  node "$wd\src\windows\service-management\install.js" $Directory $User
  Set-Location $wd

  if ($? -ne $True) {
    throw "Service install script failed."
  }
}
function Set-ServiceUser {
  param([string] $name, [string] $username, [string] $pass)

  # Write-Host "Set-ServiceUser -name `"$name`" -username `"$username`""
  Write-Host "Updating `"$name`" service to run as `"$username`""

  # Create a filter to query for the service by

  $filter = "Name='$name'"

  # Query for the service, wait a second if we can't find it right away

  $attempt = 0
  $maxAttempts = 10
  $service = $null

  while (($null -eq $service -and $attempt -le ($maxAttempts - 1))) {

    if ($attempt -ne 0) {
      Start-Sleep -Milliseconds 1000
      Write-Host "Attempt #$($attempt + 1) to locate `"$name`" service.."
    }

    $service = Get-WMIObject -class Win32_Service -Filter $filter

    $attempt = $attempt + 1
  }

  if ($null -eq $service) {
    throw "Could not find `"$name`" service after $maxAttempts attempts."
  }

  # Now that we have a reference to the service, change it's user account

  Write-Host "Found `"$name`" service:"
  Write-Host "  State: $($service.State)"
  Write-Host "  Status: $($service.Status)"
  Write-Host "  Started: $($service.Started)"
  Write-Host "  Start Mode: $($service.StartMode)"
  Write-Host "  Service Type: $($service.ServiceType)"
  Write-Host "  Start Name: $($service.StartName)"

  Write-Host "Changing service user account.."

  $response = $service.Change($null, $null, $null, $null, $null, $null, $username, $pass)

  if ($response.ReturnValue -ne 0) {
    $message = Get-Service-Error-For-Code($response.ReturnValue)
    throw "Could not change service user: $message"
  }

  # If the service isn't already stopped, stop it.

  if ($service.State -ne 'Stopped') {

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
  }

  # Now, start it

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

  Write-Host "Service `"$name`" is now running as `"$($service.StartName)`"."
}

function Confirm-Service {
  param([string] $name)

  #Write-Host "Confirm-Service -name `"$name`""
  Write-Host "Waiting a moment to confirm the`"$name`" service.."

  # If the service is going to fail, it's likely going to fail within the first second.

  # Wait a second
  Start-Sleep -Milliseconds 1000

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

  Write-Host "Service `"$name`":"
  Write-Host "  State: $($service.State)"
  Write-Host "  Status: $($service.Status)"
  Write-Host "  Started: $($service.Started)"
  Write-Host "  Start Mode: $($service.StartMode)"
  Write-Host "  Service Type: $($service.ServiceType)"
  Write-Host "  Start Name: $($service.StartName)"
}
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


Write-Host "=== Creating Service ==="

# Discern where pm2 is installed
# Presumably this should be C:\ProgramData\npm\npm\, but we don't want to make any assumptions
Write-Host "Determining pm2 installation directory.."
$PM2_INSTALL_DIRECTORY = "$(npm config get prefix --global)\node_modules\pm2"

# Query for the name of the Local Service user by its security identifier
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
# In English, this is "NT AUTHORITY\LOCAL SERVICE", but in Norwegian it's "NT-MYNDIGHET\LOKAL TJENESTE"
Write-Host "Determining Local Service user name (`"S-1-5-19`").."
$localServiceSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-19")
$ServiceUser = ($localServiceSID.Translate([System.Security.Principal.NTAccount])).Value

# Print out configuration
Write-Host "Configuration:"
Write-Host "  PM2_HOME:              $PM2_HOME"
Write-Host "  PM2_SERVICE_DIRECTORY: $PM2_SERVICE_DIRECTORY"
Write-Host "  PM2_INSTALL_DIRECTORY: $PM2_INSTALL_DIRECTORY"
Write-Host "  Service User:          $ServiceUser"
Write-Host ""

# Set the environmental variables we need (PM2_HOME, PM2_SERVICE_DIRECTORY and PM2_INSTALL_DIRECTORY) on a machine level
Set-Env

# Create the pm2\home and pm2\service folders
New-Directory -Directory $PM2_HOME
New-Directory -Directory $PM2_SERVICE_DIRECTORY

# Copy the service source code into the pm2\service folder, and link node-windows
Install-Service-Files

# Set permissions on pm2\home and pm2\service
Set-Permissions -Directory $PM2_HOME -User $ServiceUser
Set-Permissions -Directory $PM2_SERVICE_DIRECTORY -User $ServiceUser

# Create the service itself
# Install-Service -Directory $PM2_SERVICE_DIRECTORY -User $ServiceUser
Install-Service -Directory $PM2_SERVICE_DIRECTORY
# There is currently (May 2020) an issue with the way that node-windows uses user credentials.
# Sending it the local service user fails, so instead:
# - Create the service to run as LocalSystem, but don't start it
# - Update the service to run as the LocalService user
# - Start the service
# Starting the service as LocalSystem then attempting to change it to LocalService causes permissions issues
# However, if the service never starts until after being updated to run as LocalService, it works perfectly

# Do this again, because installing the service adds a few files
Set-Permissions -Directory $PM2_HOME -User $ServiceUser
Set-Permissions -Directory $PM2_SERVICE_DIRECTORY -User $ServiceUser

# Switch the service user to Local Service
$PM2ServiceAccount = ($Env:PM2_SERVICE_ACCOUNT, "NT AUTHORITY\LocalService" -ne $null )[0]
$PM2ServiceAccountPassword = ($Env:PM2_SERVICE_ACCOUNT_PASSWORD, "" -ne $null )[0]
Set-ServiceUser -name "pm2.exe" -username $PM2ServiceAccount -pass $PM2ServiceAccountPassword

# Confirm the service is running
Confirm-Service -name "pm2.exe"

Write-Host "=== Creating Service Complete ==="
