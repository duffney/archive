#View Subscription
Invoke-Command -ComputerName Collector -ScriptBlock {cmd /c wecutil es}
Invoke-Command -ComputerName Collector -ScriptBlock {cmd /c wecutil gs adsecurity}

#Confirm EventForwarding is working
Get-WinEvent -ComputerName collector -LogName ForwardedEvents -MaxEvents 50 | `
select MachineName,TimeCreated,ID,Message

#Start Event Viewer
Start-Process "c:\windows\system32\eventvwr.msc" -ArgumentList "/s"

#RDP to Collector
Start-Process "C:\Windows\system32\mstsc.exe"