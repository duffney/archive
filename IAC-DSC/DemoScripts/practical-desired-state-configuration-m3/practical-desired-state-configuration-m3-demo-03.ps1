#Create PS session
$Session = New-PSSession -ComputerName Cert

#Install xAdcsDeployment from PSGallery
Install-Module xAdcsDeployment

#Copy module to remote node
$params =@{
    Path = (Get-Module xAdcsDeployment -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xAdcsDeployment"
    ToSession = $Session
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

Invoke-Command -Session $Session -ScriptBlock {Get-Module xAdcsDeployment -ListAvailable}

#Configure LCM
psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\LCM_SelfSigned.ps1

#Create secure DSC config
psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\Globomantics_Cert.ps1

psEdit C:\dsc\cert\Cert.mof

#Deploy ADCS
$cim = New-CimSession -ComputerName $Session.ComputerName

Start-DscConfiguration -Path C:\dsc\cert -CimSession $cim -Verbose -Wait -Force

Get-DscConfigurationStatus -CimSession $cim