Configuration HADomain {

    param (
        [string]$NodeName,
        [Parameter(Mandatory)]             
        [pscredential]$SafeModeAdministratorPassword,             
        [Parameter(Mandatory)]            
        [pscredential]$DomainAdministratorCredential        
        )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    
    Node $AllNodes.Where{$_.Role -eq "FirstDomainController"}.Nodename  {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint            
            RebootNodeIfNeeded = $true            
        }        

        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }

        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $true
             
        }        

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }            
        
        xADDomain FirstDS            
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $DomainAdministratorCredential             
            SafemodeAdministratorPassword = $SafeModeAdministratorPassword            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }        
                                                
    }

    Node $AllNodes.Where{$_.Role -eq "SecondDomainController"}.Nodename
    {

        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint            
            RebootNodeIfNeeded = $true            
        } 

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainAdministratorCredential
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        
        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $SafeModeAdministratorPassword
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xADRecycleBin RecycleBin {
            EnterpriseAdministratorCredential = $DomainAdministratorCredential
            ForestFQDN = $Node.DomainName
            DependsOn = "[xADDomainController]SecondDC"
        }
    }    
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'DC1'          
            Role = "FirstDomainController"
            DomainName = "globomantics.com"                         
            Thumbprint = '51D4687FA243B17C4547FBD369BEBEEE253DC394'
            Certificatefile = 'c:\certs\DC1.cer'        
            PSDscAllowDomainUser = $true     
        }
        @{             
            Nodename = 'DC2'          
            Role = "SecondDomainController"
            DomainName = "globomantics.com"                         
            Thumbprint = '830007966E4065F99D1A8E213FFF6D38C44EE880'
            Certificatefile = 'c:\certs\DC2.cer'
            RetryCount = 20
            RetryIntervalSec = 30            
            PSDscAllowDomainUser = $true     
        }        
                      
    )             
}

# Generate Configuration
HADomain -ConfigurationData $ConfigData `
-SafeModeAdministratorPassword (Get-Credential -UserName '(Password Only)' `
-Message "New Domain Safe Mode Administrator Password") `
-DomainAdministratorCredential (Get-Credential -UserName globomantics\administrator `
-Message "New Domain Admin Credential") -OutputPath c:\dsc\HADomain

 
Set-DscLocalConfigurationManager -Path c:\dsc\HADomain -Verbose -Force
Start-DscConfiguration -wait -force -Verbose -Path c:\dsc\HADomain