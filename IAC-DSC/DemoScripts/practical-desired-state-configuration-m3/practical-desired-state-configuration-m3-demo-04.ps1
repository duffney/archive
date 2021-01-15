#Start Certificate Authority Console mmc
$mmcPath = "c:\Windows\System32\mmc.exe"
$mscPath = "c:\Windows\system32\certsrv.msc"
Start-Process -FilePath $mmcPath -ArgumentList $mscPath

#Create New-GPO
$comment = "AutoEnrolls Computers for the DscCert issued by the ADCS Cert server"
New-GPO -Name Cert-AutoEnroll -comment $comment

#Change GPO Status
(get-gpo "Cert-AutoEnroll").gpostatus="UserSettingsDisabled"

#Open Group Policy Management
$mmcPath = "c:\Windows\System32\mmc.exe"
$mscPath = "c:\Windows\System32\gpmc.msc"
Start-Process -FilePath $mmcPath -ArgumentList $mscPath