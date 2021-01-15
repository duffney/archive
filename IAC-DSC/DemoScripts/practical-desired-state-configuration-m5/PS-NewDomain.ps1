#Define Static IP and SafeModePassword Variables
$IPAddress = '192.168.2.10' 
$PrefixLength = '24' 
$DefaultGateway = '192.168.2.1'
$DNS = '192.168.2.10','127.0.0.1' 
$InterfaceIndex = (Get-NetAdapter | where Name -EQ 'Internal').ifIndex
$pwd = ConvertTo-SecureString 'P@ssw0rd' -AsPlaintext -Force

#Remove Current IPAddress
Remove-NetIPAddress -InterfaceIndex $InterfaceIndex -Confirm:$false
Remove-NetRoute -ifindex $InterfaceIndex -NextHop $DefaultGateway -Confirm:$false

#Set Static IP Address
New-NetIPAddress -IPAddress $IPAddress -PrefixLength $PrefixLength -InterfaceIndex $InterfaceIndex -DefaultGateway $DefaultGateway

#Set DNS Addresses
Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $DNS

#Install and Import AD Domain Services
Install-WindowsFeature AD-Domain-Services
Import-Module ADDSDeployment

#Create New AD Domain
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2012R2" `
-DomainName "globomantics.com" `
-DomainNetbiosName "GLOBOMANTICS" `
-SafeModeAdministratorPassword $pwd `
-ForestMode "Win2012R2" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true