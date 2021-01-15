Configuration IntroToRegex {
    param (
        [Parameter()] [ValidateNotNull()] [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')        
    )

    Import-DscResource -Module PSDesiredStateConfiguration, xActiveDirectory, xWindowsEventForwarding;


        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode = 'ApplyOnly';
        }
        
        WindowsFeature ADDSTools {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }
                            
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $true
            
        }

        WindowsFeature RSATADTools {
            Ensure = 'Present'
            Name = 'RSAT-AD-PowerShell'
        }
                
        xADDomain FirstDS            
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $Credential             
            SafemodeAdministratorPassword = $Credential            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }

        xADUser SamSmith { 
            DomainName = $node.DomainName;
            UserName = 'ssmith';
            Surname = 'Sam'
            GivenName = 'Smith'            
            Description = 'Manager';
            Password = $Credential;
            Ensure = 'Present';
            DependsOn = '[xADDomain]FirstDS';
        }

        xADUser JasonGreen { 
            DomainName = $node.DomainName;
            UserName = 'jgreen';
            Ensure = 'Present';
            Surname = 'Jason'
            GivenName = 'Green'
            Manager = 'CN=ssmith,CN=Users,DC=globomantics,DC=com'
            Password = $Credential
            DependsOn = '[xADDomain]FirstDS';
            OfficePhone = '402-583-5366'
        }

        xADUser BrandonBailey { 
            DomainName = $node.DomainName;
            UserName = 'bbailey';
            Ensure = 'Present';
            Surname = 'Brandon'
            GivenName = 'Bailey'
            Manager = 'CN=ssmith,CN=Users,DC=globomantics,DC=com'
            Password = $Credential
            OfficePhone =  '3956'
            DependsOn = '[xADDomain]FirstDS';
        }

        xADUser GraceBailey { 
            DomainName = $node.DomainName;
            UserName = 'gbailey';
            Ensure = 'Present';
            Surname = 'Grace'
            GivenName = 'Bailey'
            Manager = 'CN=ssmith,CN=Users,DC=globomantics,DC=com'
            Password = $Credential
            OfficePhone = '1-760-410-9010'
            DependsOn = '[xADDomain]FirstDS';
        }

        xADUser svc_account { 
            DomainName = $node.DomainName;
            UserName = 'svc_account';
            Ensure = 'Present';
            Surname = 'svc'
            GivenName = 'account'
            Password = $Credential
            DependsOn = '[xADDomain]FirstDS';
        }

        xADGroup Sales {
            GroupName = 'Sales'
            Ensure = 'Present'
            Members = 'jgreen' 
        }

        xADGroup SalesManagers {
            GroupName = 'SalesManagers'
            Ensure = 'Present'
            Members = 'ssmith' 
        }

        xADGroup SalesEngineers {
            GroupName = 'SalesEngineers'
            Ensure = 'Present'
            Members = 'gbailey','bbailey' 
        }

        xWEFCollector Enabled {
            Ensure = 'Present'
            Name = 'Enabled'
        }

        xWEFSubscription AppEvents {
            SubscriptionID = 'AppEvents'
            Ensure = 'Present'
            SubscriptionType = 'CollectorInitiated'
            Address = 'GDC01.globomantics.com'
            DependsOn = '[xWEFCollector]Enabled'
        }


} #end Configuration Example

$configdata = @{
    AllNodes = @(
      @{
        NodeName = 'GDC01'
        DomainName = 'globomantics.com'
        PSDscAllowPlainTextPassword = $true;    
        Folders = 'Sales','Sales Engineers','Sales Managers'
      }
  )
}

IntroToRegex -ConfigurationData $configdata -OutputPath C:\dsc\IntroToRegex

Start-DscConfiguration -Path C:\dsc\IntroToRegex -Wait -Verbose -Force