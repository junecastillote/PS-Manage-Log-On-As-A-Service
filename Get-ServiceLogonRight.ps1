# Get-ServiceLogonRight.ps1
[CmdletBinding()]
param ()

# Initialize the temporary configuration export filename
$tempConfigFile = "$env:TEMP\tempCfg.ini"

# Export the security policy
$null = $(secedit /export /cfg $tempConfigFile)

# Display the 'SeServiceLogonRight' value.
$currentSeServiceLogonRight = (Get-Content $tempConfigFile |
    Select-String "SeServiceLogonRight").ToString().Replace('SeServiceLogonRight = ', '').Split(',')

$currentSeServiceLogonRight | ForEach-Object {
    $currentAccount = $_
    if ($currentAccount -like "*S-1-5*") {
        $sid = ($currentAccount).Replace('*', '')
        try {
            [System.Security.Principal.SecurityIdentifier]::new("$($sid)").Translate([System.Security.Principal.NTAccount]).Value
        }
        catch {
            $currentAccount
        }
    }
    else {
        $currentAccount
    }
}

# Clean up
if (Test-Path $tempConfigFile) {
    Remove-Item -Path $tempConfigFile -Force -Confirm:$false
}