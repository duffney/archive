#Confirm DC was Promoted
(Get-ADDomainController -filter *).Name

#Reapply Collector DSC Configuration
Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose

#View Event Sources
Invoke-Command -ComputerName Collector -ScriptBlock {cmd /c wecutil gs adsecurity}

#region UpdateEventSources

#Method 1: Nuke
$Subs = cmd /c wecutil es
if ($Subs -contains 'ADSecurity'){
    Write-Output "Removing Subscription [ADSecurity]"
    cmd /c wecutil ds ADSecurity
}

#Method 2: Compare
$EventSources = cmd /c wecutil gs adsecurity | `
Select-String -SimpleMatch "Address" | % {($_).tostring().split(':')[1].trim()}
$DCs = (Get-ADDomainController -filter *).HostName

if ((Compare-Object $DCs $EventSources).length -ne 0){
    Write-Output "Removing Subscription [ADSecurity]"
    cmd /c wecutil ds ADSecurity
}


#Dynamic Collector DSC Config
psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsDynamicCollector.ps1

#Verify Subscription exists
Invoke-Command -ComputerName Collector -ScriptBlock {cmd /c wecutil gs adsecurity}
#endregion