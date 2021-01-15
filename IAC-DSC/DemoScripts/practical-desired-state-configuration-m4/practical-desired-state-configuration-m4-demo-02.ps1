[DSCLocalConfigurationManager()]
Configuration HTTPS_LCM
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid,

            [Parameter(Mandatory=$true)]
            [string]$thumbprint,

            [Parameter(Mandatory=$true)]
            [string]$Pullthumbprint            

        )
	Node $ComputerName {

		Settings {

			AllowModuleOverwrite = $True
		    ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            CertificateID = $thumbprint
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = 'https://pull.globomantics.com:8080/PSDSCPullServer.svc'
                CertificateID = $PullCertThumbPrint
                AllowUnsecureConnection = $False
            }
	}
}

$ComputerName = 'S2'
$PullServer = 'Pull'

$cert = invoke-command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
     } -computername $ComputerName

$PullCertThumbPrint = Invoke-Command -Computername $PullServer -ScriptBlock `
{Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "PSDSCPullServerCert"} | Select-Object -ExpandProperty ThumbPrint}     

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

HTTPS_LCM -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -PullThumbprint $PullCertThumbPrint -OutputPath c:\DSC\s2

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\s2 -Verbose

Get-DscLocalConfigurationManager -CimSession $cim

Get-DscLocalConfigurationManager -CimSession $cim | select -ExpandProperty ConfigurationDownloadManagers