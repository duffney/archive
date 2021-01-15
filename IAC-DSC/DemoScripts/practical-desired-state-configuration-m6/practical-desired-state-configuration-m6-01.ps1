#Add Collector to Event Log Readers Group
Set-ADGroup -Add:@{'Member'="CN=COLLECTOR,CN=Computers,DC=GLOBOMANTICS,DC=COM"} `
-Identity:"CN=Event Log Readers,CN=Builtin,DC=GLOBOMANTICS,DC=COM" `
-Server:"DC1.GLOBOMANTICS.COM" -Verbose

#Confirm Computer Object was Added
Get-ADGroupMember -Identity 'Event Log Readers'


#Create New-GPO
$comment = "Enables auditing and provides read access to security logs for NetworkService account"
New-GPO -Name EventForwarding -comment $comment

#Change GPO Status
(get-gpo "EventForwarding").gpostatus="UserSettingsDisabled"

#Allow Network Service Account Read & Enabling Auditing
Start-Process C:\windows\system32\gpmc.msc

<#
Configure Log Access
Computer Management > Preferences > Administrative Template > Windows Component > Event Log Service > Security > Configure log Access
Value: O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)

Enable Active Directory Auditing
Computer Management > Polices > Windows Settings > Security Settings > Local Polices > Audit Policy
#>

#Link GPO to Domain Controllers
New-GPLink -Name EventForwarding -Target 'OU=Domain Controllers,DC=GLOBOMANTICS,DC=COM' -Verbose

#Reboot DCs to apply GPO change
$DCs = (Get-ADDomainController -filter *).Name
$DCs | % {Restart-Computer -ComputerName $_ -Wait -For PowerShell -Force}