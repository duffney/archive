Configuration HTTPSPull {
    param (
        [string[]]$NodeName,        
        [string]$MachineName,
        [string]$IPAddress,
        [string]$DefaultGateway,
        [string[]]$DNSIPAddress,
        [string]$DomaniName
    )
    
    Import-DscResource –Module PSDesiredStateConfiguration
    Import-DSCResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module cNetworking
    Import-DscResource -Module xNetworking
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone

    Node $AllNodes.Where{$_.Role -eq "HTTPSPull"}.Nodename {
        
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
        
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = $Node.CertificateThumbPrint
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
        }

        xDscWebService PSDSCComplianceServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServer"
            Port                    = 9080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
        }        
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = $env:COMPUTERNAME
            MachineName = 'ZPull01'
            Role = "HTTPSPull"
            CertificateThumbPrint = '59C31226752787FE0BAB37ECA23C14B4B9524A70'
            DomainName = "Zephyr"
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.5'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')
        }                      
    )             
}

HTTPSPull -ConfigurationData $ConfigData

Set-DscLocalConfigurationManager -Path .\HTTPSPull -Verbose -Force
Start-DscConfiguration -Path .\HTTPSPull -Wait -Force -Verbose