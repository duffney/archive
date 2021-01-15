[DSCLocalConfigurationManager()]
Configuration SecureLCM
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
		    ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'
			ConfigurationID = $guid
            CertificateID = $thumbprint
        }
	}
}

$ComputerName = 'DC4'

$cert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Subject -eq 'CN=DC4.GLOBOMANTICS.COM'}
    } -ComputerName $ComputerName

$cim = New-CimSession -ComputerName $ComputerName

$guid=[guid]::NewGuid()

SecureLCM -ComputerName $ComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\dsc\$ComputerName

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\$ComputerName -Verbose