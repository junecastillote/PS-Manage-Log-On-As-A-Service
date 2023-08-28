# Remove-ServiceLogonRight.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $Username
)

$tempConfigFile = "$env:TEMP\tempCfg.ini"
$tempDatabaseFile = "$env:TEMP\tempSdb.sdb"
$null = $(secedit /export /cfg $tempConfigFile)
$null = $(secedit /import /cfg $tempDatabaseFile /db $tempDatabaseFile)
$configIni = Get-Content $tempConfigFile
$originalString = ($configIni | Select-String "SeServiceLogonRight").ToString()
$currentSeServiceLogonRight = [System.Collections.ArrayList]($originalString.Replace('SeServiceLogonRight = ', '').Split(','))
$index = $currentSeServiceLogonRight.IndexOf("$($Username)")

if ($index -gt -1) {
    $currentSeServiceLogonRight.RemoveAt($index)
    $replacementString = "SeServiceLogonRight = $($currentSeServiceLogonRight -join ",")"
    $configIni = $configIni.Replace($originalString, $replacementString)
    $configIni | Out-File $tempConfigFile
    secedit /configure /db $tempDatabaseFile /cfg $tempConfigFile /areas USER_RIGHTS
}
else {
    "The user account [$Username] is not included in the 'Log on as a service' assignment. No action taken." | Out-Default
}

# Clean up
$tempConfigFile, $tempDatabaseFile | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Path $_ -Force -Confirm:$false
    }
}
