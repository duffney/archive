#Obtain Certificate
$cert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Subject -eq 'CN=DC4.GLOBOMANTICS.COM'}
    } -ComputerName DC4

if (-not (Test-Path c:\certs)){mkdir -Path c:\certs}
Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\DC4.cer -Force     

#Copy xActiveDirectory to DC4
Publish-DSCResourcePush -Module xActiveDirectory -ComputerName DC4

#Configure New Domain Controller LCM
. C:\GitHub\IAC-DSC\DemoScripts\Configurations\SecureLCM.ps1

#Promote New Domain Controller
. C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsNewDomainController.ps1