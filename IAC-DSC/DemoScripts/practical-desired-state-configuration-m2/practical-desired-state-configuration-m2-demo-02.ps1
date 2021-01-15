# Installing DSC Resource Modules
Install-Module -Name xNetworking
Install-Module -Name xNetworking -Force
Install-Module -Name xNetworking -Scope CurrentUser -Force
Find-Module xActiveDirectory | Install-Module

# DSC Resource Module Locations
Get-Module -Name xnetworking -ListAvailable | select Name,Version,ModuleBase