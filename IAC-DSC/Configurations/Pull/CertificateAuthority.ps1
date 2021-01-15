Configuration CertificateAuthority
{        

    Import-DscResource -ModuleName xAdcsDeployment
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cNetworking
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xTimeZone
    Import-DscResource -ModuleName xRemoteDesktopAdmin
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename
    {         
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }

        If ((gwmi win32_computersystem).partofdomain -eq $false){
            xComputer NewName {
                Name = $Node.MachineName
                DomainName = $Node.DomainName
                Credential = $Node.Credential
                DependsOn = '[cDNSServerAddress]DnsServerAddress'
            }
        }

        xIPAddress NewIPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
 
        }

        xDefaultGatewayAddress NewDefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = 'Ethernet'
            Address = $Node.DefaultGateway
            DependsOn = '[xIPAddress]NewIpAddress'

        }
        
        cDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
        }
        
        xRemoteDesktopAdmin RemoteDesktopSettings {
            Ensure = 'Present'
            UserAuthentication = 'Secure'
        }
        
        xFirewall AllowRDP {
            Name = 'DSC - Remote Desktop Admin Connection'
            Group = 'Remote Desktop'
            Ensure = 'Present'
            Enabled = $true
            Action = 'Allow'
            Profile = 'Domain'
        }          
        
        WindowsFeature ADCS-Cert-Authority {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
        }

        WindowsFeature RSAT-ADCS {
            Ensure = 'Present'
            Name = 'RSAT-ADCS'
            IncludeAllSubFeature = $true
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        
        xADCSCertificationAuthority ADCS {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }
        
        WindowsFeature ADCS-Web-Enrollment {
            Ensure = 'Present'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        
        xADCSWebEnrollment CertSrv {
            Ensure = 'Present'
            Name = 'CertSrv'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        }
        
        WindowsFeature Web-Mgmt-Console {
            Ensure = 'Present'
            Name = 'Web-Mgmt-Console'
            IncludeAllSubFeature = $true            
        }         
    }  
}


$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'ZCert01'          
            MachineName = 'ZCert01'
            Role = "PKI"             
            DomainName = "Zephyr"
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.3'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            CertificateFile = 'C:\Certs\ZCert01.cer'            
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')
        }                      
    )             
}

CertificateAuthority -ConfigurationData $ConfigData -OutputPath c:\dsc\CertificateAuthority

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename
$guid = Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationID


$source = "C:\DSC\CertificateAuthority\$($ConfigData.AllNodes.Nodename).mof"
#Mount PullServer PS Drive
New-PSDrive -Name DSCService -Root "\\zpull01\c$\Program Files\WindowsPowerShell\DscService" -PSProvider FileSystem
# Destination is the Share on the SMB pull server
$dest = "DSCService:\Configuration\$guid.mof"
Copy-Item -Path $source -Destination $dest
#Then on Pull server make checksum
New-DSCChecksum $dest

Update-DscConfiguration -CimSession $cim -Wait -Verbose