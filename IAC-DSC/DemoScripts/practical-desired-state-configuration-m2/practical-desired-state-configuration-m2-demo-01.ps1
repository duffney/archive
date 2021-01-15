# Discovering DSC Resource Modules
Find-Module -Includes DscResource
Find-Module -Tag DSC
Find-Module -Name *Networking*  -Includes DscResource

# Finding Different Module Versions
Find-Module xnetworking -AllVersions
Find-Module xnetworking -MaximumVersion 2.5.0.0
Find-Module xnetworking -MinimumVersion 2.7.0.0
Find-Module xnetworking -RequiredVersion 2.6.0.0

# Discovering DSC Resources
Find-DscResource
Find-DscResource -moduleName xNetworking
Find-DscResource -moduleName xNetworking -RequiredVersion 2.4.0.0
Find-DscResource -Name xIPAddress

# if ($Possible){ Filter left} 
Find-DscResource -Filter "network"
Find-DscResource | Where-Object Name -like *IP*