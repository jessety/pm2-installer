param(
  [string] $Force = $true
)

# & .\src\windows\configure-policy.ps1

# Instead of calling the following script, unlock the script file, then call it directly with the same execution policy it might be setting
# This is entirely to supress the otherwise incredibly bad-looking notice that will pop up if you change an execution policy from a script executing from within a context that doesn't share that policy
# E.g. if this script is invoked with -ExecutionPolicy Bypass, and the user opts to alter their user-level execution policy, it'll throw a large error-looking message of red text even if it works
# "Windows PowerShell updated your execution policy successfully, but the setting is overridden by a policy defined at a more specific scope."
$script_path = ".\src\windows\configure-policy.ps1"
Unblock-File -Path $script_path
powershell.exe -NoLogo -ExecutionPolicy RemoteSigned -Command "$script_path -Force $Force"
