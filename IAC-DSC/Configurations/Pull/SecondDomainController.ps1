Configuration SecondDomainController {
    param (
    [string[]]$NodeName,
    [string]$MachineName,
    [pscredential]$safemodeAdministratorCred,
    [pscredential]$domainCred        
    )
    
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module cNetworking
    Import-DscResource -Module xNetworking
    Import-DscResource -module xDHCpServer
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    Import-DscResource -ModuleName xRemoteDesktopAdmin

    
    Node $AllNodes.Where{$_.Role -eq "SecondDomainController"}.Nodename  {

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

        cDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
        }
        
        If ((gwmi win32_computersystem).partofdomain -eq $false){
            xComputer NewName {
                Name = $Node.MachineName
                DomainName = $Node.DomainName
                Credential = $Node.Credential
                DependsOn = '[cDNSServerAddress]DnsServerAddress'
            }
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
            DependsOn = '[WindowsFeature]ADDSInstall'
            LogPath = 'F:\NTDS'
        }              
                 
    }        
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'ZDC02'          
            Role = "SecondDomainController"
            MachineName = 'ZDC02'
            DomainName = "Zephyr.org"                         
            IPAddress = '192.168.2.6'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            CertificateFile = 'C:\Certs\ZDC02.cer'            
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')            
        }
                      
    )             
}   

# Save ConfigurationData in a file with .psd1 file extension#
SecondDomainController -ConfigurationData $ConfigData `
   -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
    -Message "New Domain Safe Mode Administrator Password") -OutputPath c:\dsc\SecondDomainController

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename
$guid = Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationID


$source = "C:\DSC\SecondDomainController\$($ConfigData.AllNodes.Nodename).mof"
#Mount PullServer PS Drive
New-PSDrive -Name DSCService -Root "\\zpull01\c$\Program Files\WindowsPowerShell\DscService" -PSProvider FileSystem
# Destination is the Share on the SMB pull server
$dest = "DSCService:\Configuration\$guid.mof"
Copy-Item -Path $source -Destination $dest
#Then on Pull server make checksum
New-DSCChecksum $dest

Update-DscConfiguration -CimSession $cim -Wait -Verbose