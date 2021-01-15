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

        xWEFCollector Enabled {
            Ensure = "Present"
            Name = "Enabled"
        }

        Script DynamicEventSource {
            
            GetScript = {
            #Do Nothing
            }

            SetScript = {
                Write-Verbose -Message "Comparing EventSources with Domain Controllers"

                $EventSources = Invoke-Command $Using:Node.NodeName -ScriptBlock {cmd /c wecutil gs adsecurity} | `
                Select-String -SimpleMatch "Address" | % {($_).tostring().split(':')[1].trim()}
        
                $DCs = (Get-ADDomainController -filter *).HostName

                if ((Compare-Object $DCs $EventSources).length -ne 0){
            
                    Write-Verbose "EventSources Did Not Match"
            
                    Invoke-Command $Using:Node.NodeName -ScriptBlock {cmd /c wecutil ds ADSecurity}

                    Write-Verbose "Removed Subscription [ADSecurity]"
                }            
            }

            TestScript = {
                $false
            }
        }



        xWEFSubscription ADSecurity
        {
            SubscriptionID = "ADSecurity"
            Ensure = "Present"
            LogFile = 'ForwardedEvents'
            SubscriptionType = 'CollectorInitiated'
            Address = (Get-ADGroupMember 'Domain Controllers' | % {Get-ADComputer -Identity $_.SID}).DNSHostName
            DependsOn = "[xWEFCollector]Enabled","[WindowsFeature]RSATADPowerShell","[Script]DynamicEventSource"
            Query = @('Security:*')
        }      
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            NodeName = 'Collector'          
            PSDscAllowDomainUser = $true
        }                
    )             
}  

$cim = New-CimSession -ComputerName Collector

GlobomanticsCollector -ConfigurationData $ConfigData -OutputPath c:\DSC\

Start-DscConfiguration -CimSession $cim -path c:\DSC\ -Wait -Force -Verbose