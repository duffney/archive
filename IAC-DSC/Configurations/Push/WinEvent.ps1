configuration SetupCollector
{
    Import-DscResource -ModuleName xWindowsEventForwarding

    Windowsfeature RSAT-AD-PowerShell{
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
        Address = (Get-ADGroupMember 'Domain Controllers' | % {Get-ADComputer -Identity $_.SID}).DNSHostName
        DependsOn = "[xWEFCollector]Enabled"
        Query = @('Security:*')
    } 
}
SetupCollector -OutputPath c:\DSC\ 
Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose