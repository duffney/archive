Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )
    
    Import-DscResource -ModuleName xComputerManagement
    
    Node $AllNodes.NodeName {        
        
        xComputer NewName {
            Name = $Node.NewName
            DomainName = $Node.DomainName
            Credential = $Node.Credential
        } #end xComputer resource
        
    } #end node block
    
} #end configuration

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'WIN-6J22PI2U9RJ'
            NewName = 'PS-S01'
            DomainName = 'Globomantics.com'
            Credential = (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password')
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true            
        }                   
    )             
}  

RenameComputer -ConfigurationData $ConfigData -OutputPath c:\dsc\push

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.NodeName

Start-DscConfiguration -CimSession $cim -Path C:\dsc\push -Wait -Verbose -Force