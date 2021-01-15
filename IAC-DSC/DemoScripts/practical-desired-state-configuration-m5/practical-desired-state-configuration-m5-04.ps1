Configuration ADOrganizationalUnit {
    
    param (
        [string]$NodeName   
        )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    
    Node $AllNodes.Nodename  {           
        
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
                    
        xADUser duffneyj {
            UserName = 'duffneyj'
            JobTitle = 'Senior Operations Engineer'
            UserPrincipalName = 'duffneyj@globomantics.com'
            Enabled = $true
            Ensure = 'Present'
            Password = $Node.Password
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $Node.DomainAdministratorCredential
            Path = 'OU=UserAccounts,DC=globomantics,DC=com'
            DependsOn = '[WindowsFeature]ADDSTools','[xADOrganizationalUnit]UserAccounts'
        }

        xADGroup Operations {
            GroupName = 'Operations'
            Category = 'Security'
            GroupScope = 'Global'
            Description = 'Role based group for Operations team members'
            Ensure = 'Present'
            Members = 'duffneyj'
            Path = 'OU=Groups,DC=globomantics,DC=com'
            DependsOn = '[xADOrganizationalUnit]UserAccounts'
        }

        foreach ($OrganizationalUnit in $Node.OrganizationalUnits) {
            xADOrganizationalUnit $OrganizationalUnit {
                Name = $OrganizationalUnit
                Ensure = 'Present'
                Path = "DC=globomantics,DC=com"
                ProtectedFromAccidentalDeletion = $true
            }                                                  
        }
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'DC1'
            DomainName = 'globomantics.com'          
            Certificatefile = 'c:\certs\DC1.cer'
            OrganizationalUnits = 'UserAccounts','Groups'
            Password = (Get-Credential -UserName duffneyj -Message 'Enter Password')
            DomainAdministratorCredential = (Get-Credential -UserName globomantics\administrator -Message "Domain Admin Credential")
            PSDscAllowDomainUser = $true     
        }
                      
    )             
} 

# Generate Configuration
ADOrganizationalUnit -ConfigurationData $ConfigData -OutputPath c:\dsc\ADGroup

Start-DscConfiguration -wait -force -Verbose -Path c:\dsc\ADGroup

Get-ADGroup -Identity Operations
Get-ADGroupMember -Identity Operations
