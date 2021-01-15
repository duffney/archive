Configuration ServerAdminsGroup {
    Param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName
    {
        Group ServerAdmins {
            GroupName = 'ServerAdmins'
            Members = 'globomantics\duffneyj'
            Ensure = 'Present'
            Credential = $Credential
        }
    }
}

$configdata = @{
    AllNodes = @(
     @{
      NodeName = 's2'
      Certificatefile = 'c:\certs\s2.cer'
      PSDscAllowDomainUser = $true
     }
    )
}

#Generate Secure .mof  
ServerAdminsGroup -ConfigurationData $ConfigData `
-Credential (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password') `
-OutputPath c:\dsc\s2

#establish cim and PS sessions
$cim = New-CimSession -ComputerName s2
$PullSession = New-PSSession -ComputerName pull

#stage pull config on pullserver
$guid = Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationID

$source = "C:\DSC\s2\$($ConfigData.AllNodes.NodeName).mof"
$dest = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $source -Destination $dest -ToSession $PullSession -force -verbose

Invoke-Command $PullSession -ScriptBlock {Param($ComputerName,$guid)Rename-Item $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$ComputerName.mof -NewName $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$guid.mof} -ArgumentList $($ConfigData.AllNodes.NodeName),$guid
Invoke-Command $PullSession -ScriptBlock {Param($dest)New-DSCChecksum $dest -Force} -ArgumentList $dest

psEdit "\\pull\C$\Program Files\WindowsPowerShell\DscService\Configuration\$guid.mof"

#invoke pull
Update-DscConfiguration -CimSession $cim -Wait -Verbose

#Query group memberships
Invoke-Command s2 -ScriptBlock {net localgroup serveradmins}