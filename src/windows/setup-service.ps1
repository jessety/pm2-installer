# Deploys PM2 as a Windows service
# From: https://gist.github.com/mauron85/e55b3b9d722f91366c50fddf2fca07a4

param(
	[string] $Directory = $env:PM2_HOME
)

Write-Host "=== Creating Service ==="
Write-Host "Using PM2_HOME directory: $Directory"

$ErrorActionPreference = "Stop"

function Create-Pm2-Home
{
	Write-Host "Attempting to create $Directory and give FullControl to LOCAL SERVICE"
	New-Item -ItemType Directory -Force -Path  $Directory | Out-Null

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		"LOCAL SERVICE", "FullControl", "ContainerInherit, ObjectInherit",
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
	$daemonPath = "$(npm config get prefix)\node_modules\@innomizetech\pm2-windows-service\src\daemon"
	Write-Host "Attempting to create $daemonPath and give FullControl to LOCAL SERVICE"
	New-Item -ItemType Directory -Force -Path $daemonPath | Out-Null

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		"LOCAL SERVICE", "FullControl", "ContainerInherit, ObjectInherit",
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
	$path = "$(npm config get prefix)"
	Write-Host "Attempting to give FullControl of $path to LOCAL SERVICE"

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		"LOCAL SERVICE", "FullControl", "ContainerInherit, ObjectInherit",
		"None", "Allow")

	try {
		$acl = (Get-Item $path).GetAccessControl('Access')
		$acl.SetAccessRule($rule)
		Set-Acl -Path $path -AclObject $acl -ErrorAction Stop
		Write-Host "Successfully set FullControl permissions on $path"
	} catch {
		throw "$path : Failed to set permissions. Details : $_"
	}

	$path = "$(npm config get cache)"
	Write-Host "Attempting to give FullControl of $path to LOCAL SERVICE"

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
		"LOCAL SERVICE", "FullControl", "ContainerInherit, ObjectInherit",
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
	cd $Directory

	Write-Host "Running pm2-service-install.."
	& "pm2-service-install" "--unattended"
	
	# Create wrapper log file, otherwise it won't start
	$wrapperLogPath = "$(npm config get prefix)\node_modules\@innomizetech\pm2-windows-service\src\daemon\pm2.wrapper.log"
	
	if (Test-Path $wrapperLogPath) {
		Write-Debug "PM2 service wrapper log file already exists"
	} else {
		Write-Debug "PM2 service wrapper log file does not exist. Creating.."
		Out-File $wrapperLogPath -Encoding utf8
	}
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
	Write-Host "Changing PM2 to run as LOCAL SERVICE"
	Set-ServiceAcctCreds -serviceName "pm2.exe" -newAcct "NT AUTHORITY\LocalService" -newPass "" | Out-Null
}

$env:PM2_HOME =  $Directory
$env:PM2_SERVICE_PM2_DIR = "$(npm config get prefix)\node_modules\pm2\index.js"
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
