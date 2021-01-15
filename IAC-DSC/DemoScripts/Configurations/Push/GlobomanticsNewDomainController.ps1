Configuration NewDomainController {
    param (
    [string[]]$NodeName,
    [pscredential]$safemodeAdministratorCred,
    [pscredential]$domainCred        
    )
    
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    
    Node $AllNodes.Where{$_.Role -eq "NewDomainController"}.Nodename  {

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services" 
        }         
        
        xADDomainController DSCPromo {
            DomainAdministratorCredential = $Node.Credential
            DomainName = $Node.DomainName
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = '[WindowsFeature]ADDSInstall'
        }                
                 
    }        
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'DC4'          
            Role = "NewDomainController"
            DomainName = "globomantics.com"
            Certificatefile = 'c:\certs\DC4.cer'
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'globomantics\duffneyj' -message 'Enter admin pwd')            
        }
                      
    )             
}   

NewDomainController -ConfigurationData $ConfigData `
   -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
    -Message "New Domain Safe Mode Administrator Password") -outputpath c:\dsc\NewDomainController

Start-DscConfiguration -ComputerName DC4 -wait -force -Verbose -Path c:\dsc\NewDomainController