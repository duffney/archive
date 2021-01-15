#Create PS Sessions
$s1_session = New-PSSession -ComputerName s1
$s2_session = New-PSSession -ComputerName s2

#Confirm Certificate was Issued
Invoke-Command -Session $s1_session,$s2_session -ScriptBlock {Get-ChildItem Cert:\LocalMachine\My}

Invoke-Command -Session $s1_session -ScriptBlock `
{Get-ChildItem Cert:\LocalMachine\My | select Thumbprint,Subject,Issuer}

Invoke-Command -Session $s1_session,$s2_session -ScriptBlock `
{Get-ChildItem Cert:\LocalMachine\My | Where Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}

#Exporting Certificates
$certs = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
    } -Session $s1_session,$s2_session

$certs

foreach ($Cert in $Certs)
{
    Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\$($Cert.PSComputerName).cer -Force     
}
