[DSCLocalConfigurationManager()]
Configuration s1_LCM
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$thumbprint

        )
	Node $ComputerName {

		Settings {

			AllowModuleOverwrite = $True
		    ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'
            CertificateID = $thumbprint
            }
	}
}

$ComputerName = 'S1'

$cert = invoke-command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
     } -computername $ComputerName

$cim = New-CimSession -ComputerName $ComputerName

s1_LCM -ComputerName $ComputerName -Thumbprint $Cert.Thumbprint -OutputPath c:\dsc\s1

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\s1 -Verbose

Get-DscLocalConfigurationManager -CimSession $cim | select RefreshMode,ConfigurationMode,CertificateID