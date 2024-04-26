Write-Host "LenovoBios setting check"
Set-Variable -Name countNotcompliant -Value 0 -Scope Global
Set-Variable -Name "NotcompliantBIOSNames" -Value $null -Scope Global 

Function Check-ForLenovoDevice {
    If((Get-WmiObject -Class Win32_ComputerSystem -Property Manufacturer).Manufacturer -EQ "LENOVO"){
        return $true
    }else{
        return $false
    }
}

Function Check-LenovoBIOSSetting {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (gwmi -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "$Name"}).CurrentSetting

}

Function Check-LenovoBIOSPassword {
    If((Get-CimInstance -Namespace root/WMI -ClassName Lenovo_BiosPasswordSettings).PasswordState -eq 0){
        return $false
    }else{
        return $true
    }
}

Function Get-LenovoBIOSSetting{
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    return (gwmi -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "$Name"}).CurrentSetting
}

Function Change-LenovoBIOSSetting{
    param(
        [String]$Password,
        [Parameter(Mandatory = $true)]
        [String[]]$Settings,
        [Switch]$URL
    )
    If(!(Check-LenovoBIOSPassword)){
        If(($Password)){
            Write-Warning "Device has no password" 
        }
    }else{
        If(!($Password)){
            Write-Error "ERROR Password missing"
            Exit 1 
        }
    }
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
                Write-Information "$($splitArray[0]) Not Compliant"
                Write-Warning "Not Compliant"
                Write-Information "Changeing BIOS settings"
                Set-Variable -Name countNotcompliant -Value ($countNotcompliant + 1) -Scope Global
                Set-Variable -Name "NotcompliantBIOSNames" -Value ($NotcompliantBIOSNames + " " + $($splitArray[0])) -Scope Global
                If(!(Check-LenovoBIOSPassword)){
                    (gwmi -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("$($Setting)")
                }else{
                    (gwmi -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("$($Setting),$($Password),ascii,us")
                }
                If((Get-LenovoBIOSSetting -Name "$($splitArray[0])") -eq "$Setting"){
                    Write-Host "Setting changed" -ForegroundColor Green
                }
            }else{
                Write-Host "$($splitArray[0]) $($splitArray[1])"
                Write-Host "Compliant" -ForegroundColor Green
            }
        }else{
            Write-Host "$($splitArray[0]) is not pressent in this BIOS"
            Write-Host "Compliant" -ForegroundColor Green
        }
    }
    #Connect to the Lenovo_SaveBiosSetting WMI class
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
    If(Check-LenovoBIOSPassword){
        #Save any outstanding BIOS configuration changes (password set)
        $SaveSettings.SaveBiosSettings("$($Password),ascii,us")
    }else{
        #Save any outstanding BIOS configuration changes (no password set)
        $SaveSettings.SaveBiosSettings()
    }

}

If(Check-ForLenovoDevice){
    Write-Host "Compliant device" -ForegroundColor Green
}else{
    Write-Error "Not Compliant - NOT a Lenovo device"
    Exit 1
}

Change-LenovoBIOSSetting -Settings "UserPresenceSensing,Disable" -Password "Password"
