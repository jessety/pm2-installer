param(
  [string] $Force = $false
)

Write-Host "=== Checking PowerShell Execution Policy ==="

$policy = Get-ExecutionPolicy -Scope CurrentUser

if ($policy -ne "Restricted" -and $policy -ne "Undefined") {
  Write-Host "The current user's execution policy appears valid: $policy"
  Write-Output $true
  exit
}

Write-Host "The current user's execution policy is `"$policy`", which may interfere with your ability to interface with pm2."

$preferred = "RemoteSigned"

if ($Force -eq $false) {

  $confirmation = Read-Host -Prompt "Would you like to update it to `"$preferred`"? (Y/N)"

  while ($confirmation -ne "y" -and $confirmation -ne "Y") {

    if ($confirmation -eq 'n' -or $confirmation -eq 'N') {
      Write-Output $false
      exit
    }

    $confirmation = Read-Host -Prompt "(Y/N)"
  }
}

Write-Host "Updating current user's execution policy to $preferred..."
Set-ExecutionPolicy $preferred -Scope CurrentUser -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Write-Host "Complete."
