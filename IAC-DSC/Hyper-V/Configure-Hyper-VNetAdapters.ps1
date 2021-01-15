Get-NetAdapter | where Virtual -EQ $false | Select Name,InterfaceDescription,MacAddress #Select NetAdpter with internet access

$NetAdapterName = (Get-NetAdapter | where Virtual -EQ $false).Name
New-VMSwitch -NetAdapterName $NetAdapterName -Name 'External' #Create External adapter provding internet
New-VMSwitch -SwitchType Internal -Name 'Internal'