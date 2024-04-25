Write-Host "LenovoBios setting check"
Set-Variable -Name countNotcompliant -Value 0 -Scope Global
Set-Variable -Name "NotcompliantBIOSNames" -Value $null -Scope Global 

Function Check-LenovoBIOSSetting {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (gwmi -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "$Name"}).CurrentSetting

}

Function Get-LenovoBIOSSetting{
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    return (gwmi -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "$Name"}).CurrentSetting
}

Function Detection-LenovoBIOSSetting{
    param(
        [Parameter(Mandatory = $true)]
        [String[]]$Settings,
        [Switch]$URL
    )
    If($URL){
        Write-Host "Getting data from URL"
        #$URLdata = Invoke-WebRequest -Uri $Settings -UseBasicParsing
        $URLdata = Invoke-RestMethod -Uri $($Settings[0]) -Method GET
        $Settings = ($URLdata -split "`r`n")

    }

    foreach($Setting in $Settings){
        $Setting = $Setting.Trim("`"")
        $splitArray = $Setting.Split(",")
        If((Check-LenovoBIOSSetting -Name "$($splitArray[0])") -ne $null){
            If((Get-LenovoBIOSSetting -Name "$($splitArray[0])") -ne "$Setting"){
                Write-Host "$($splitArray[0]) Not Compliant"
                Write-Warning "Not Compliant"
                Set-Variable -Name countNotcompliant -Value ($countNotcompliant + 1) -Scope Global
                Set-Variable -Name "NotcompliantBIOSNames" -Value ($NotcompliantBIOSNames + " " + $($splitArray[0])) -Scope Global
            }else{
                Write-Host "$($splitArray[0]) $($splitArray[1])"
                Write-Output "Compliant"
            }
        }else{
            Write-Host "$($splitArray[0]) is not pressent in this BIOS"
            Write-Output "Compliant"
        }
    }

}

Detection-LenovoBIOSSetting -Settings "https://test.blob.core.windows.net/config/LenovoBIOSSettings.txt" -URL

Detection-LenovoBIOSSetting -Settings "AdaptiveThermalManagementAC,MaximizePerformance","HyperThreadingTechnology,Enable","SecurityChip,Enable","TXTFeature,Enable","VirtualizationTechnology,Enable","VTdFeature,Enable","SecureBoot,Enable","DeviceGuard,Enable","BootMode,Quick"
Detection-LenovoBIOSSetting -Settings "LenovoCloudServices,Disable","PCIeTunneling,Enable","AMTControl,Disable","EnhancedWindowsBiometricSecurity,Enable","BottomCoverTamperDetected,Enable","TotalMemoryEncryption,Enable","KeyboardLayout,English_US","LenovoCloudServices,Enable","UserPresenceSensing,Disable"

Write-Host $NotcompliantBIOSNames

If($countNotcompliant -gt 0){
    Write-Warning "Not Compliant $($NotcompliantBIOSNames)"
    Exit 1
}else{
    Write-Output "Compliant"
    Exit 0
}
