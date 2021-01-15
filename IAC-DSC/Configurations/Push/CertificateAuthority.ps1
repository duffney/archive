Configuration CertificateAuthority
{        

    Import-DscResource -ModuleName xAdcsDeployment,PSDesiredStateConfiguration,xNetworking,xComputerManagement,xTimeZone,cNetworking
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename
    {  
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }          
        
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
            Nodename = $env:COMPUTERNAME          
            MachineName = 'ZCert01'
            Role = "PKI"             
            DomainName = "Zephyr"
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.3'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')
        }                      
    )             
}

CertificateAuthority -ConfigurationData $ConfigData

Set-DscLocalConfigurationManager -Path .\CertificateAuthority -Verbose -Force
Start-DscConfiguration -Path .\CertificateAuthority -Wait -Force -Verbose