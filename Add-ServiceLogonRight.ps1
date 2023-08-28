# Add-ServiceLogonRight.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $Username
)

try {
    # Check if the user account exists.
    $null = ([System.Security.Principal.NTAccount]::new($Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
}
catch {
    # Exit the script if the user account does not exist.
    "The account [$Username] does not exist." | Out-Default
    return $null
}

$tempConfigFile = "$env:TEMP\tempCfg.ini"
$tempDatabaseFile = "$env:TEMP\tempSdb.sdb"
$null = $(secedit /export /cfg $tempConfigFile)
$null = $(secedit /import /cfg $tempDatabaseFile /db $tempDatabaseFile)
$configIni = Get-Content $tempConfigFile
$originalString = ($configIni | Select-String "SeServiceLogonRight").ToString()
$replacementString = $originalString + ',' + $Username
$configIni = $configIni.Replace($originalString, $replacementString)
$configIni | Out-File $tempConfigFile
secedit /configure /db $tempDatabaseFile /cfg $tempConfigFile /areas USER_RIGHTS

# Clean up
$tempConfigFile, $tempDatabaseFile | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Path $_ -Force -Confirm:$false
    }
}