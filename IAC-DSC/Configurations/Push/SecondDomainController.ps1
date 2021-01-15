Configuration SecondDomainController {
    param (
    [string[]]$NodeName,
    [string]$MachineName,
    [pscredential]$safemodeAdministratorCred,
    [pscredential]$domainCred        
    )
    
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module xNetworking
    Import-DscResource -module xDHCpServer
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    
    Node $AllNodes.Where{$_.Role -eq "SecondDomainController"}.Nodename  {
        
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
        
        xComputer NewName {
            Name = $Node.MachineName
            DomainName = $Node.DomainName
            Credential = $Node.Credential
            DependsOn = '[xDNSServerAddress]DnsServerAddress'
        }
    
        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services" 
        }         
        
        xADDomainController DSCPromo {
            DomainAdministratorCredential = $Node.Credential
            DomainName = $Node.DomainName
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath = 'E:\NTDS' 
            DependsOn = '[xComputer]NewName','[WindowsFeature]ADDSInstall'
            LogPath = 'F:\NTDS' 
        }                
                 
    }        
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'Localhost'          
            Role = "SecondDomainController"
            MachineName = 'ZDC02'
            DomainName = "Zephyr.org"                         
            IPAddress = '192.168.2.6'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')            
        }
                      
    )             
}   

# Save ConfigurationData in a file with .psd1 file extension#
SecondDomainController -ConfigurationData $ConfigData `
   -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
    -Message "New Domain Safe Mode Administrator Password")

Set-DscLocalConfigurationManager -Path .\SecondDomainController -Verbose -Force
Start-DscConfiguration -ComputerName localhost -wait -force -Verbose -Path .\SecondDomainController