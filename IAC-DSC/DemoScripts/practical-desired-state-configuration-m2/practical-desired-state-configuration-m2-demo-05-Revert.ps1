Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )
    
    Import-DscResource -ModuleName xComputerManagement
    
    Node $AllNodes.NodeName {        
        
        xComputer NewName {
            Name = $Node.NewName
            Credential = $Node.Credential
        } #end xComputer resource
        
    } #end node block
    
} #end configuration

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'PS-S01'
            NewName = 'WIN-6J22PI2U9RJ'
            Credential = (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password')
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true            
        }                   
    )             
}  

RenameComputer -ConfigurationData $ConfigData -OutputPath c:\dsc\push

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.NodeName

Start-DscConfiguration -CimSession $cim -Path C:\dsc\push -Wait -Verbose -Force

Start-Sleep -Seconds 10

Restart-Computer -ComputerName $ConfigData.AllNodes.NodeName -Wait -Force -For PowerShell

icm -ComputerName $ConfigData.AllNodes.NodeName -ScriptBlock {Remove-Item 'C:\Program Files\WindowsPowerShell\Modules\xComputerManagement' -Recurse -Confirm:$false -Verbose -Force}

icm -ComputerName $ConfigData.AllNodes.NodeName -ScriptBlock {Remove-DscConfigurationDocument -Stage Pending,Current,Previous -Verbose}
