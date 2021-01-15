#Set Trusted Hosts
winrm set winrm/config/client '@{TrustedHosts="DC1"}'
winrm set winrm/config/client '@{TrustedHosts="DC2"}'

#Copy xActiveDirectory
Copy-Item D:\DSCResources\xActiveDirectory -Recurse `
-Destination 'C:\Program Files\WindowsPowerShell\Modules' -Force

$Session = New-PSSession -ComputerName DC2 -Credential administrator

Copy-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\xActiveDirectory' `
-Recurse -Destination 'C:\Program Files\WindowsPowerShell\Modules' -ToSession $Session

#Create Self Signed Certificates
$Params = @{
    Subject = 'CN=DC1'
    StoreLocation = 'LocalMachine'
    StoreName = 'My'
    EnhancedKeyUsage = 'Document Encryption'
    FriendlyName = 'SelfSigned'
}

New-SelfSignedCertificateEx @Params

Invoke-Command -Session $Session -ScriptBlock ${Function:New-SelfSignedCertificateEx} `
-ArgumentList 'CN=DC2','LocalMachine','My','Document Encryption','SelfSigned'

#Export Certificates
$cert = Get-ChildItem Cert:\LocalMachine\my | 
Where-Object {$_.Subject -eq 'CN=DC1'}

if (-not (Test-Path c:\certs)){mkdir -Path c:\certs}
Export-Certificate -Cert $cert -FilePath C:\Certs\DC1.cer -Force

$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.Subject -eq 'CN=DC2'}
     } -Session $Session

Export-Certificate -Cert $cert -FilePath C:\Certs\DC2.cer -Force