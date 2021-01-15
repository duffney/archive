#Create PS session
$Session = New-PSSession -ComputerName Pull

#Install xAdcsDeployment from PSGallery
Install-Module xPSDesiredStateConfiguration -MaximumVersion 3.9.0.0

#Copy module to remote node
$params =@{
    Path = (Get-Module xPSDesiredStateConfiguration -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration"
    ToSession = $Session
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

Invoke-Command -Session $Session -ScriptBlock {Get-Module xPSDesiredStateConfiguration -ListAvailable}

#HTTPS Pull Server DSC config
psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\Globomantics_HTTPSPull.ps1

Start-Process -FilePath iexplore.exe https://pull.globomantics.com:8080/PSDSCPullServer.svc