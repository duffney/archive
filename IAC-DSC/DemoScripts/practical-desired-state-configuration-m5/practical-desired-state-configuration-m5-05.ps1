Configuration ADComputer {
    
    param (
        [string]$NodeName   
        )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.12.0.0
    
    Node $AllNodes.Nodename  {           

    for ($i = 0; $i -lt 10; $i++)
    { 
        $ComputerName = 'PC' + (Get-Random -Maximum 1000)

        xADComputer $ComputerName {
            ComputerName = $ComputerName
        } 
    }                   

    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'DC1'
        }                 
    )             
} 

# Generate Configuration
ADComputer -ConfigurationData $ConfigData -OutputPath c:\dsc\ADComputer

Start-DscConfiguration -wait -force -Verbose -Path c:\dsc\ADComputer