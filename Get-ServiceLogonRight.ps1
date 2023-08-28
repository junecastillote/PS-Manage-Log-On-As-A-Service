# Get-ServiceLogonRight.ps1
[CmdletBinding()]
param ()

# Initialize the temporary configuration export filename
$tempConfigFile = "$env:TEMP\tempCfg.ini"

# Export the security policy
$null = $(secedit /export /cfg $tempConfigFile)

# Display the 'SeServiceLogonRight' value.
(Get-Content $tempConfigFile |
Select-String "SeServiceLogonRight").ToString().Replace('SeServiceLogonRight = ', '').Split(',')

# Clean up
if (Test-Path $tempConfigFile) {
    Remove-Item -Path $tempConfigFile -Force -Confirm:$false
}