# LenovoBIOSSettings-IntuneRemediation


Detection-LenovoBIOSSetting -Settings "https://test.blob.core.windows.net/config/LenovoBIOSSettings.txt" -URL

Detection-LenovoBIOSSetting -Settings "AdaptiveThermalManagementAC,MaximizePerformance","HyperThreadingTechnology,Enable","SecurityChip,Enable","TXTFeature,Enable","VirtualizationTechnology,Enable","VTdFeature,Enable","SecureBoot,Enable","DeviceGuard,Enable","BootMode,Quick"



Change-LenovoBIOSSetting -Settings "UserPresenceSensing,Disable" -Password "password"

Change-LenovoBIOSSetting -Settings "UserPresenceSensing,Disable"

Change-LenovoBIOSSetting -Settings "https://test.blob.core.windows.net/config/LenovoBIOSSettings.txt" -Password "password" -URL
Change-LenovoBIOSSetting -Settings "https://test.blob.core.windows.net/config/LenovoBIOSSettings.txt" -URL
