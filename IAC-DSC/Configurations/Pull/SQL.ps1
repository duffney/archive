Configuration SQL {
    param (
        [string[]]$NodeName,        
        [string]$IPAddress,
        [string]$DefaultGateway,
        [string[]]$DNSIPAddress,
        [string]$DomaniName
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cNetworking
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xTimeZone
    Import-DscResource -ModuleName xRemoteDesktopAdmin

    Node $AllNodes.Where{$_.Role -eq "SQL"}.Nodename {
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }

        If ((gwmi win32_computersystem).partofdomain -eq $false){
            xComputer NewName {
                Name = $Node.NodeName
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
        
        Group LocalAdmins {
            GroupName = 'Administrators'
            Credential = $Node.Credential
            Ensure = 'Present'
            MembersToInclude = $Node.MembersToInclude
        }                
            }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'ZSQL01'
            Role = "SQL"
            DomainName = "Zephyr"
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.4'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            CertificateFile = 'C:\Certs\ZSQL01.cer'
            MembersToInclude = 'zephyr\SGD-ServerAdmins'
            Credential = (Get-Credential -UserName 'zephyr\administrator' -message 'Enter admin pwd')
        }                      
    )             
}

SQL -ConfigurationData $ConfigData -OutputPath c:\dsc\sql


$cim = New-CimSession -ComputerName zsql01
$guid=Get-DscLocalConfigurationManager -CimSession $cim| Select-Object -ExpandProperty ConfigurationID


$source = "C:\DSC\sql\$($ConfigData.AllNodes.Nodename).mof"
#Mount PullServer PS Drive
New-PSDrive -Name DSCService -Root "\\zpull01\c$\Program Files\WindowsPowerShell\DscService" -PSProvider FileSystem
# Destination is the Share on the SMB pull server
$dest = "DSCService:\Configuration\$guid.mof"
Copy-Item -Path $source -Destination $dest -Force -Verbose
#Then on Pull server make checksum
New-DSCChecksum $dest -Force


Update-DscConfiguration -CimSession $cim -Wait -Verbose