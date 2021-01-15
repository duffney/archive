[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL
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
                ServerURL = 'https://ps-pull01.globomantics.com:8080/PSDSCPullServer.svc'
                CertificateID = '2A3DCD224519CAACE33AED52492F2A62D990FA17'
                AllowUnsecureConnection = $False
            }
	}
}

$ComputerName = 'WIN-FK9EMOE6CMG'

$Cert = Export-MachineCert -computername $ComputerName -Path C:\Certs

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

LCM_HTTPSPULL -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\DSC\HTTPS

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\HTTPS -Verbose
