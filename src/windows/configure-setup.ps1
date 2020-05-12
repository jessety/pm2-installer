param(
  [string] $Directory = "$($env:ProgramData)\npm"
)

Write-Host "=== Configuring npm to use $Directory ==="

$Directory_prefix = "$Directory\npm"
$Directory_modules = "$Directory\npm\node_modules"
$Directory_cache = "$Directory\npm-cache"

function Create-Directories {

  if (Test-Path $Directory) {
    Write-Host "Directory $Directory already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory"
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  if (Test-Path $Directory_prefix) {
    Write-Host "Directory $Directory_prefix already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory_prefix"
    New-Item -ItemType Directory -Force -Path $Directory_prefix | Out-Null
  }

  if (Test-Path $Directory_modules) {
    Write-Host "Directory $Directory_modules already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory_modules"
    New-Item -ItemType Directory -Force -Path $Directory_modules | Out-Null
  }

  if (Test-Path $Directory_cache) {
    Write-Host "Directory $Directory_cache already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory_cache"
    New-Item -ItemType Directory -Force -Path $Directory_cache | Out-Null
  }
}

function Set-NPM-Config {

  $currentPrefix = "$(npm config --global get prefix)"

  if ((Join-Path $currentPrefix '') -eq (Join-Path $Directory_prefix '')) {
    Write-Host "npm prefix config is already set to $Directory_prefix, no need to update it."
  } else {
    Write-Host "Changing npm prefix config from $currentPrefix to $Directory_prefix"
    npm config --global set prefix $Directory_prefix
  }

  $currentCache = "$(npm config --global get cache)"

  if ((Join-Path $currentCache '') -eq (Join-Path $Directory_cache '')) {
    Write-Host "npm cache config is already set to $Directory_cache, no need to update it."
  } else {
    Write-Host "Changing npm cache config from $currentCache to $Directory_cache"
    npm config --global set cache $Directory_cache
  }
}

function Update-Path {

  param(
    [string] $NewPath
  )

  $Paths = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) -split ';'

  if ($Paths -notcontains $NewPath) {

    Write-Host "Path does not contain $NewPath. Adding it.."

    $Paths = $Paths + $NewPath | where { $_ }

    [Environment]::SetEnvironmentVariable('Path', $Paths -join ';', [EnvironmentVariableTarget]::Machine)

    # Also update session path
    $Env:Path += ";$NewPath"

  } else {

    Write-Host "Path already contains $NewPath, no need to update it."
  }
}

Create-Directories
Set-NPM-Config
Update-Path($Directory_prefix)

Write-Host "=== Configuring npm Complete ==="
