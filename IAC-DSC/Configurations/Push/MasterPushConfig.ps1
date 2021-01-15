Configuration MasterPushConfig {
    param (
        [string[]]$NodeName,        
        [string]$MachineName,
        [string]$IPAddress,
        [string]$DefaultGateway,
        [string[]]$DNSIPAddress,
        [string]$DomaniName,
        [Parameter(Mandatory)]
        [string]$Credential
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xNetworking
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    Import-DscResource -Module xRemoteDesktopAdmin
    Import-DscResource -ModuleName xAdcsDeployment    

    Node $AllNodes.Nodename {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }          
        
        xTimeZone SystemTimeZone {
            TimeZone = $Node.TimeZone
            IsSingleInstance = 'Yes'

        }

        If ((gwmi win32_computersystem).partofdomain -eq $false){
            xComputer NewName {
                Name = $Node.Nodename
                DomainName = $Node.DomainName
                Credential = $Node.Credential
                DependsOn = '[xDNSServerAddress]DnsServerAddress'
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
        
        xDNSServerAddress DnsServerAddress
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
    } #close all nodes
    
    Node $Allnodes.Where({$_.role -eq 'CertificateAuthority'}).Nodename {
        
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
    } #close CertificateAuthority node
    
    
}

MasterPushConfig -ConfigurationData .\DemoConfigData.psd1 `
-output c:\dsc\DemoConfig -credential `
(Get-credential -UserName zephyr\administrator -message 'Enter Password') -Verbose 

$cim = New-CimSession -ComputerName DSC

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\DemoConfig -Verbose -Force

Start-DscConfiguration -CimSession $cim -Path C:\dsc\DemoConfig -Wait -Force -Verbose