configuration Firewall {

Import-DscResource -ModuleName xNetworking -ModuleVersion 2.8.0.0

Node $AllNodes.NodeName {

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
            Nodename = $env:COMPUTERNAME          
        }                      
    )             
}


Firewall -OutputPath C:\dsc\wefdc -ConfigurationData $ConfigData