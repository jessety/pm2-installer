Write-Host "=== Checking npm Configuration ==="

$prefix = "$(npm config --global get prefix)"
$cache = "$(npm config --global get cache)"

$valid = $true

if ($prefix -like "*\AppData\Roaming\*") {
  Write-Warning "Global npm prefix location does not seem to be in a global location: $prefix"
  $valid = $false
} else {
  Write-Host "Global npm prefix location appears valid: $prefix"
}

if ($cache -like "*\AppData\Roaming\*") {
  Write-Warning "Global npm cache location does not seem to be in a global location: $cache"
  $valid = $false
} else {
  Write-Host "Global npm cache location appears valid: $cache"
}

# Decide whether to proceed

if ($valid -eq $false) {

  Write-Host "`nThe npm prefix and cache must be somewhere accessible to the LocalService user, or the service will not run."
  Write-Host "(To fix this automatically, execute ``npm run configure`` beforehand to use C:\ProgramData\npm)"

  $confirmation = Read-Host -Prompt "Are you absolutely sure you want to proceed anyway? (Y/N)"

  while ($confirmation -ne "y" -and $confirmation -ne "Y") {

    if ($confirmation -eq 'n' -or $confirmation -eq 'N') {
      # Inform the script that called this that we're not going forward
      Write-Output "n"
      exit
    }

    $confirmation = Read-Host -Prompt "(Y/N)"
  }

}

Write-Host "=== Checking npm Configuration Complete ==="

# Ensure the script that called this knows to proceed
Write-Output "y"
