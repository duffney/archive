$Session = New-PSSession -ComputerName Cert

#load custom cmdlet, create self signed cert
. "C:\GitHub\IAC-DSC\Helper-Functions\New-SelfSignedCertificateEx.ps1"

Invoke-Command -Session $Session -ScriptBlock ${Function:New-SelfSignedCertificateEx} `
-ArgumentList 'CN=Cert','LocalMachine','My','Document Encryption','SelfSigned'

#Get cert info and export to authoring machine
$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -Session $Session

$cert

Export-Certificate -Cert $cert -FilePath C:\Certs\cert.cer -Force