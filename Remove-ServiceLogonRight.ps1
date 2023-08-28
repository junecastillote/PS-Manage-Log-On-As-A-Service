# Remove-ServiceLogonRight.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $UserOrGroup
)

$currentSeServiceLogonRight = [System.Collections.ArrayList](.\Get-ServiceLogonRight.ps1)
$index = $currentSeServiceLogonRight.IndexOf("$($UserOrGroup)")
if ($index -gt -1) {
    $tempConfigFile = "$env:TEMP\tempCfg.ini"
    $tempDatabaseFile = "$env:TEMP\tempSdb.sdb"
    $null = $(secedit /export /cfg $tempConfigFile)
    $null = $(secedit /import /cfg $tempDatabaseFile /db $tempDatabaseFile)
    $configIni = Get-Content $tempConfigFile
    $originalString = ($configIni | Select-String "SeServiceLogonRight").ToString()
    $currentSeServiceLogonRight.RemoveAt($index)
    $replacementString = "SeServiceLogonRight = $($currentSeServiceLogonRight -join ",")"
    $configIni = $configIni.Replace($originalString, $replacementString)
    $configIni | Out-File $tempConfigFile
    secedit /configure /db $tempDatabaseFile /cfg $tempConfigFile /areas USER_RIGHTS
}
else {
    "The user account [$UserOrGroup] is not included in the 'Log on as a service' assignment. No action taken." | Out-Default
}

# Clean up
$tempConfigFile, $tempDatabaseFile | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Path $_ -Force -Confirm:$false
    }
}
