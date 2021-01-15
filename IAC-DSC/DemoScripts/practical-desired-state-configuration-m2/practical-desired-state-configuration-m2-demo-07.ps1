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
            Nodename = 'WIN-FK9EMOE6CMG'
            NewName = 'PS-S02'
            CertificateFile = "C:\Certs\WIN-FK9EMOE6CMG.cer"         
            PSDscAllowDomainUser = $true            
            Credential = (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password')
        }                   
    )             
}

#Generate Secure .mof  
RenameComputer -ConfigurationData $ConfigData -OutputPath c:\dsc\push

#establish cim and PS sessions
$cim = New-CimSession -ComputerName $ConfigData.AllNodes.NodeName
$PullSession = New-PSSession -ComputerName ps-pull01

#LCM settings
Get-DscLocalConfigurationManager -CimSession $cim

#Publish resource module on pullserver
Publish-DSCResourcePull -Module xComputerManagement -ComputerName $PullSession.ComputerName

#stage pull config on pullserver
$guid= Get-DscLocalConfigurationManager -CimSession $cim| Select-Object -ExpandProperty ConfigurationID

$source = "C:\DSC\push\$($ConfigData.AllNodes.NodeName).mof"
$dest = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $source -Destination $dest -ToSession $PullSession -force -verbose

Invoke-Command $PullSession -ScriptBlock {Param($ComputerName,$guid)Rename-Item $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$ComputerName.mof -NewName $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$guid.mof} -ArgumentList $($ConfigData.AllNodes.NodeName),$guid
Invoke-Command $PullSession -ScriptBlock {Param($dest)New-DSCChecksum $dest -Force} -ArgumentList $dest

#invoke pull
Update-DscConfiguration -CimSession $cim -Wait -Verbose