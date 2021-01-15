$PullCert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.FriendlyName -eq 'PSDSCPullServerCert'}
    } -ComputerName Cert

$PullCert

Export-Certificate -Cert $PullCert -FilePath "$env:systemdrive:\Certs\PSDSCPullServerCert.cer" -Force

$Session = New-PSSession -ComputerName Pull
Copy-Item -Path C:\Certs\PSDSCPullServerCert.cer -Destination "C:\" -ToSession $Session

Invoke-Command -ScriptBlock `
{Import-Certificate -FilePath "$env:systemdrive:\PSDSCPullServerCert.cer" `
-CertStoreLocation 'Cert:\LocalMachine\My'} ` -Session $Session

Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False