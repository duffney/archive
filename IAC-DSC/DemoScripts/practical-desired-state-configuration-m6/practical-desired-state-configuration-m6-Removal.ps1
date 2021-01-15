Set-ADGroup -Remove:@{'Member'="CN=COLLECTOR,CN=Computers,DC=GLOBOMANTICS,DC=COM"} -Identity:"CN=Event Log Readers,CN=Builtin,DC=GLOBOMANTICS,DC=COM" -Server:"DC1.GLOBOMANTICS.COM" -Verbose

Remove-GPO -Name EventForwarding -Confirm:$false -Verbose

$cim = New-CimSession -ComputerName Collector

Invoke-Command -ComputerName $cim.ComputerName -ScriptBlock {Remove-Item "c:\Program Files\WindowsPowerShell\Modules\xWindowsEventForwarding" -Recurse -Confirm:$false -Force}
Invoke-Command -ComputerName $cim.ComputerName -ScriptBlock {Remove-Item "c:\Program Files\WindowsPowerShell\Modules\xNetworking" -Recurse -Confirm:$false -Force}

Remove-DscConfigurationDocument -CimSession $cim -Stage Current,Pending,Previous -Verbose

Invoke-Command -ComputerName $cim.ComputerName -ScriptBlock {cmd /c wecutil ds ADSecurity}

Invoke-Command -ComputerName DC4 -ScriptBlock {Remove-Item "c:\Program Files\WindowsPowerShell\Modules\xActiveDirectory" -Recurse -Confirm:$false -Force}

Invoke-Command -ComputerName dc4 -ScriptBlock {Uninstall-ADDSDomainController}