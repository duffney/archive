[DSCLocalConfigurationManager()]
Configuration s2_LCM
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid,

            [Parameter(Mandatory=$true)]
            [string]$thumbprint

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
                CertificateID = '9C22E73CCC78D2A0798C1EA2855BC1FD703521D0'
                AllowUnsecureConnection = $False
            }
	}
}

$ComputerName = 'S2'

$cert = invoke-command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
     } -computername $ComputerName

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

s2_LCM -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\DSC\s2

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\s2 -Verbose

Get-DscLocalConfigurationManager -CimSession $cim

Get-DscLocalConfigurationManager -CimSession $cim | select -ExpandProperty ConfigurationDownloadManagers