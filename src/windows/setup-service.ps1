# Deploys PM2 as a Windows service
# Adapted from: https://gist.github.com/mauron85/e55b3b9d722f91366c50fddf2fca07a4

param(
	[string] $Directory = "C:\ProgramData\pm2"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Creating Service ==="
Write-Host "Using PM2_HOME directory: $Directory"

# Query for the name of the Local Service user by its security identifier
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
$localServiceSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-19")
$User = ($localServiceSID.Translate([System.Security.Principal.NTAccount])).Value

function Create-Pm2-Home
{
	Write-Host "Attempting to create $Directory and give FullControl to $User"
	New-Item -ItemType Directory -Force -Path  $Directory | Out-Null

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		$User, "FullControl", "ContainerInherit, ObjectInherit",
		"None", "Allow")

	try {
		$acl = Get-Acl -Path  $Directory -ErrorAction Stop
		$acl.SetAccessRule($rule)
		Set-Acl -Path  $Directory -AclObject $acl -ErrorAction Stop
		Write-Host "Successfully set FullControl permissions on  $Directory"
	} catch {
		throw " $Directory : Failed to set permissions. Details : $_"
	}
}

function Set-Daemon-Permissions
{
	$daemonPath = "$(npm config get prefix --global)\node_modules\@innomizetech\pm2-windows-service\src\daemon"
	Write-Host "Attempting to create $daemonPath and give FullControl to $User"
	New-Item -ItemType Directory -Force -Path $daemonPath | Out-Null

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		$User, "FullControl", "ContainerInherit, ObjectInherit",
		"None", "Allow")

	try {
		$acl = (Get-Item $daemonPath).GetAccessControl('Access')
		$acl.SetAccessRule($rule)
		Set-Acl -Path $daemonPath -AclObject $acl -ErrorAction Stop
		Write-Host "Successfully set FullControl permissions on $daemonPath"
	} catch {
		throw "$daemonPath : Failed to set permissions. Details : $_"
	}
}

function Set-Npm-Folder-Permissions
{
	$path = "$(npm config get prefix --global)"
	Write-Host "Attempting to give FullControl of $path to $User"

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		$User, "FullControl", "ContainerInherit, ObjectInherit",
		"None", "Allow")

	try {
		$acl = (Get-Item $path).GetAccessControl('Access')
		$acl.SetAccessRule($rule)
		Set-Acl -Path $path -AclObject $acl -ErrorAction Stop
		Write-Host "Successfully set FullControl permissions on $path"
	} catch {
		throw "$path : Failed to set permissions. Details : $_"
	}

	$path = "$(npm config get cache --global)"
	Write-Host "Attempting to give FullControl of $path to $User"

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		$User, "FullControl", "ContainerInherit, ObjectInherit",
		"None", "Allow")

	try {
		$acl = (Get-Item $path).GetAccessControl('Access')
		$acl.SetAccessRule($rule)
		Set-Acl -Path $path -AclObject $acl -ErrorAction Stop
		Write-Host "Successfully set FullControl permissions on $path"
	} catch {
		throw "$path : Failed to set permissions. Details : $_"
	}
}

function Install-Pm2-Service
{

	# node-windows creates services with the current working directory
	# pm2-service-install doesn't currently allow manually specifying the working directory when it invokes node-windows
	# However, if we just cd into the correct place before creating the service, it's almost good enough

	$wd = (Get-Item -Path '.\' -Verbose).FullName

	cd $Directory

	Write-Host "Running pm2-service-install.."
	& "pm2-service-install" "--unattended"
	
	# Create wrapper log file, otherwise it won't start
	$wrapperLogPath = "$(npm config get prefix --global)\node_modules\@innomizetech\pm2-windows-service\src\daemon\pm2.wrapper.log"
	
	if (Test-Path $wrapperLogPath) {
		Write-Debug "PM2 service wrapper log file already exists"
	} else {
		Write-Debug "PM2 service wrapper log file does not exist. Creating.."
		Out-File $wrapperLogPath -Encoding utf8
	}

	# Return back where we came from
	cd $wd
}

# From http://stackoverflow.com/a/4370900/964356
function Set-ServiceAcctCreds
{
	param([string] $serviceName, [string] $newAcct, [string] $newPass)

	$filter = "Name='$serviceName'"

	$tries = 0
	
	while (($service -eq $null -and $tries -le 3)) {
		if ($tries -ne 0) {
			sleep 2
		}
		$service = Get-WMIObject -namespace "root\cimv2" -class Win32_Service -Filter $filter
		$tries = $tries + 1
	}

	if ($service -eq $null) {
		throw "Could not find '$serviceName' service"
	}

	$service.Change($null,$null,$null,$null,$null,$null,$newAcct,$newPass)

	$service.StopService()

	while ($service.Started) {
		sleep 2
		$service = Get-WMIObject -namespace "root\cimv2" -class Win32_Service -Filter $filter
	}
	$service.StartService()
}

function Change-Pm2-Service-Account
{
	Write-Host "Changing PM2 to run as $User"
	Set-ServiceAcctCreds -serviceName "pm2.exe" -newAcct "$User" -newPass "" | Out-Null
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

& Create-Pm2-Home
& Set-Npm-Folder-Permissions
& Install-Pm2-Service
& Set-Daemon-Permissions
& Change-Pm2-Service-Account

Write-Host "=== Creating Service Complete ==="
