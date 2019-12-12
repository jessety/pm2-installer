param(
	[string] $Directory = "c:\ProgramData\npm"
)

Write-Host "=== Configuring npm to use $Directory ==="

$Directory_npm = "$Directory\npm"
$Directory_modules = "$Directory\npm\node_modules"
$Directory_cache = "$Directory\npm-cache"

function Create-NPM-Directories {

  if (Test-Path $Directory) {
    Write-Host "Directory $Directory already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory"
	  New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  if (Test-Path $Directory_npm) {
    Write-Host "Directory $Directory_npm already exists, no need to create it."
  } else {
    Write-Host "Creating $Directory_npm"
	  New-Item -ItemType Directory -Force -Path $Directory_npm | Out-Null
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
  
  Write-Host "Setting npm prefix to $Directory_npm"

  npm config --global set prefix $Directory_npm

  Write-Host "Setting npm cache to $Directory_cache"
  
  npm config --global set cache $Directory_cache
}

function Update-Path {

  param(
	  [string] $NewPath
  )

  Write-Host "Updating path.."

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

Create-NPM-Directories
Set-NPM-Config
Update-Path($Directory_npm)

Write-Host "=== Configuring npm Complete ==="
