#Discovering DSC Resource Modules
Find-Module -Includes DscResource
Find-Module -Tag DSC
Find-Module -Name *Networking*  -Includes DscResource

#Discovering DSC Resources
Find-DscResource
Find-DscResource -moduleName xNetworking
Find-DscResource | Where-Object Name -like *IP*
Find-DscResource -Name xIPAddress


#Installing DSC Resource Modules
Install-Module xnet*
Install-Module -Name xNetworking
Install-Module -Name xNetworking -Force
Install-Module -Name xNetworking -Scope CurrentUser -Force
Find-Module xActiveDirectory | Install-Module

#DSC Resource Module Versions
Get-Module -Name xnetworking -ListAvailable | select Name,Version,ModuleBase

#Finding DSC Resource Syntax & Properties
Get-DscResource xDNSServerAddress
Get-DscResource xDNSServerAddress | select -ExpandProperty Properties | ft -AutoSize
Get-DscResource xDNSServerAddress -Syntax

#Examine DSC Resources
Start-Process "C:\Program Files (x86)\Microsoft VS Code\Code.exe"