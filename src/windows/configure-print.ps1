Write-Host "`n=== Printing Configuration ==="

$spacingLength = 24;

Write-Host "`nnpm config"

$NPMConfigOptions = @("prefix", "cache") # "globalconfig", "userconfig"

foreach ($key in $NPMConfigOptions) {
	$value = npm config --global get $key
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`nsystem environmental variables"

$EnvVariables = @("PM2_HOME", "PM2_SERVICE_PM2_DIR", "PM2_SERVICE_SCRIPTS", "SET_PM2_HOME", "SET_PM2_SERVICE_PM2_DIR", "SET_PM2_SERVICE_SCRIPTS")

foreach ($key in $EnvVariables) {
	$value = [System.Environment]::GetEnvironmentVariable($key, "Machine")
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`nshell environmental variables"

$EnvVariables = @("PM2_HOME", "PM2_SERVICE_PM2_DIR", "PM2_SERVICE_SCRIPTS", "SET_PM2_HOME", "SET_PM2_SERVICE_PM2_DIR", "SET_PM2_SERVICE_SCRIPTS")

foreach ($key in $EnvVariables) {
	$value = Get-Item "env:$key" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`n"
