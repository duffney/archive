Configuration GlobomanticsCertNotSecure
{        
Param (
    [String[]]$WindowsFeature
)
    Import-DscResource -ModuleName xAdcsDeployment
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename
    {  
        
        WindowsFeature ADCS-Cert-Authority {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
        }
                
        Foreach ($Feature In $WindowsFeature){
            Write-Verbose -message [$Feature]
            WindowsFeature $Feature {
                Name = $Feature
                Ensure = 'Present'
                IncludeAllSubFeature = $true                
                DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
            }
        }          
        
        xADCSCertificationAuthority ADCS {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }
         
        xADCSWebEnrollment CertSrv {
            Ensure = 'Present'
            IsSingleInstance = 'Yes'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        }
                             
    }  
}

$WindowsFeature = 'RSAT-ADCS','Web-Mgmt-Console','ADCS-Web-Enrollment'

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'Cert'          
            Role = "PKI"
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'globomantics\duffneyj' -message 'Enter admin pwd')
        }                      
    )             
}

GlobomanticsCertNotSecure -ConfigurationData $ConfigData -WindowsFeature $WindowsFeature -OutputPath c:\dsc\cert
