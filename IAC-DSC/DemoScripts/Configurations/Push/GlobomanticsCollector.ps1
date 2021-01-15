configuration GlobomanticsCollector {
  
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWindowsEventForwarding
    Import-DscResource -ModuleName xNetworking

    node $AllNodes.NodeName
    {
        Windowsfeature RSATADPowerShell{
                Ensure = 'Present'
                Name = 'RSAT-AD-PowerShell'
        }

        xWEFCollector Enabled {
            Ensure = "Present"
            Name = "Enabled"
        }

        xWEFSubscription ADSecurity
        {
            SubscriptionID = "ADSecurity"
            Ensure = "Present"
            LogFile = 'ForwardedEvents'
            SubscriptionType = 'CollectorInitiated'
            Address = (Get-ADDomainController -Filter *).HostName
            Query = @('Security:*')            
            DependsOn = "[xWEFCollector]Enabled","[WindowsFeature]RSATADPowerShell"
        }

        xFirewall RemoteLogManagement {
            Name = 'EventLog-Forwarding'
            Group = 'Remote Event Log Management'
            Ensure = 'Present'
            Enabled = 'True'
            Action = 'Allow'
            Profile = 'Domain'
        }

        xFirewall EventMonitor {
            Name = 'Remote Event Monitor'
            Group = 'Remote Event Monitor'
            Ensure = 'Present'
            Enabled = 'True'
            Action = 'Allow'
            Profile = 'Domain'
        }

      
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            NodeName = 'Collector'          
        }                
    )             
}  

#Create Cim Session
$cim = New-CimSession -ComputerName Collector


#Copy DSC Resources to Collector
$Modules = 'xWindowsEventForwarding','xNetworking'

Publish-DSCResourcePush -Module $Modules `
-ComputerName $cim.ComputerName

Invoke-Command -ComputerName $cim.ComputerName `
-ScriptBlock {Get-Module $Using:Modules -ListAvailable} -ArgumentList $Modules

#Generate & Deploy Collector DSC Config
GlobomanticsCollector -ConfigurationData $ConfigData -OutputPath c:\DSC\

Start-DscConfiguration -CimSession $cim -path c:\DSC\ -Wait -Force -Verbose