Configuration Baseline {
    Param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$Password,
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking


    Node $AllNodes.NodeName
    {

        User LocalAdmin {
            Ensure = 'Present'
            UserName = 'LocalAdmin'
            Description = 'Local Administrator Account'
            Disabled = $false
            Password = $Password
        }

        Group Administrators {
            GroupName = 'Administrators'
            MembersToInclude = 'LocalAdmin'
            Ensure = 'Present'
            DependsOn = '[User]LocalAdmin'
            Credential = $Credential
        }

        User AdministratorDisable {
            UserName = 'Administrator'
            Disabled = $true
            DependsOn = '[Group]Administrators'
        }

        Service RemoteRegistry {
            Ensure = 'Present'
            Name = 'RemoteRegistry'
            StartupType = 'Automatic'
            State = 'Running'
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

        Log Baseline {
            Message = 'Baseline configuration complete'
            DependsOn = '[Service]RemoteRegistry','[Group]Administrators','[xFirewall]EventMonitor','[xFirewall]RemoteLogManagement'
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

#Export Certificate to authoring machine
$cert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
    } -ComputerName $configdata.AllNodes.nodename

Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\$($Cert.PSComputerName).cer -Force

#Generate Secure .mof  
Baseline -ConfigurationData $ConfigData `
-password (Get-Credential -UserName LocalAdmin -Message 'Enter Password') `
-Credential (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password') `
-OutputPath c:\dsc\s2

#establish cim and PS sessions
$cim = New-CimSession -ComputerName s2
$PullSession = New-PSSession -ComputerName pull

#stage pull config on pullserver
$guid = Get-DscLocalConfigurationManager -CimSession $cim `
| Select-Object -ExpandProperty ConfigurationID

$source = "C:\DSC\s2\$($ConfigData.AllNodes.NodeName).mof"
$dest = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $source -Destination $dest -ToSession $PullSession -force -verbose

Invoke-Command $PullSession -ScriptBlock {Param($ComputerName,$guid)Rename-Item $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$ComputerName.mof -NewName $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$guid.mof -Force} -ArgumentList $($ConfigData.AllNodes.NodeName),$guid
Invoke-Command $PullSession -ScriptBlock {Param($dest)New-DSCChecksum $dest -Force} -ArgumentList $dest

#invoke pull
Update-DscConfiguration -CimSession $cim -Wait -Verbose

#Stage xNetworking Resource
. C:\GitHub\IAC-DSC\Helper-Functions\Publish-DSCResourcePull.ps1

Publish-DSCResourcePull -Module xnetworking -ComputerName $PullSession.ComputerName

Get-DscConfigurationStatus -CimSession $cim

Invoke-Command -ComputerName $cim.ComputerName `
-ScriptBlock {net localgroup administrators}

Get-Service -ComputerName $cim.ComputerName -Name RemoteRegistry