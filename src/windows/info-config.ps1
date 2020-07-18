Write-Host "`n=== Printing npm Configuration ==="

# Print out the versions of this package, node, and npm

node src\bundle-info\current.js

$spacingLength = 24;

Write-Host "`nnpm config"

$NPMConfigOptions = @("prefix", "cache") # "globalconfig", "userconfig"

foreach ($key in $NPMConfigOptions) {
  $value = npm config --global get $key
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`nsystem environmental variables"

$VariableKeys = @("PM2_HOME", "PM2_SERVICE_DIRECTORY", "PM2_INSTALL_DIRECTORY")

foreach ($key in $VariableKeys) {
  $value = [System.Environment]::GetEnvironmentVariable($key, "Machine")
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`nshell environmental variables"

foreach ($key in $VariableKeys) {
  $value = Get-Item "env:$key" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
  Write-Host "$($key.PadRight($spacingLength,' ')) $value"
}

Write-Host "`n"
