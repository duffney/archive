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
                ServerURL = 'https://zpull01.zephyr.org:8080/PSDSCPullServer.svc'
                CertificateID = '59C31226752787FE0BAB37ECA23C14B4B9524A70'
                AllowUnsecureConnection = $False
            }
	}
}

$ComputerName = 'ZDC02'

$Cert = Export-MachineCert -computername $ComputerName -Path C:\Certs

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

LCM_HTTPSPULL -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\DSC\HTTPS

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\HTTPS -Verbose
