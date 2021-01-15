[DSCLocalConfigurationManager()]
Configuration LCM_SelfSigned
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
			RefreshMode = 'Push'
			ConfigurationID = $guid
            CertificateID = $thumbprint
            }
	}
}

$ComputerName = 'Cert'

$cert = invoke-command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -computername cert

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

LCM_SelfSigned -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\dsc\Cert

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\Cert -Verbose

Get-DscLocalConfigurationManager -CimSession $cim