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
      NodeName = 's1'
      Certificatefile = 'c:\certs\s1.cer'
      PSDscAllowDomainUser = $true
     }
    )
}

ServerAdminsGroup -configurationdata $configdata `
-Credential (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password') `
-OutputPath c:\DSC\s1

psEdit C:\dsc\s1\s1.mof

Start-DscConfiguration -Path c:\DSC\s1 -ComputerName s1 -Wait -Force -Verbose

Invoke-Command s1 -ScriptBlock {net localgroup serveradmins}