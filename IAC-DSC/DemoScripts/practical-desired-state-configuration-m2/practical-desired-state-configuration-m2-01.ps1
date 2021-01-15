Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )

    Import-DscResource -ModuleName xComputerManagement 
            
    Node $AllNodes.NodeName {         
    
    xComputer RenameComputer {
        Name = $Node.NewName
    }
    
    } #end node block
    
} #end configuration

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'WIN-6J22PI2U9RJ'
            NewName = 'PS-S01'            
        }                   
    )             
}

RenameComputer -ConfigurationData $ConfigData -OutputPath C:\dsc\push