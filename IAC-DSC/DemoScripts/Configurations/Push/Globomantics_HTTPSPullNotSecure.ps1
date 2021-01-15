Configuration GlobomanticsHTTPSPull {
    param (
        [string[]]$NodeName,        
    )
    
    Import-DscResource –Module PSDesiredStateConfiguration
    Import-DSCResource -Module xPSDesiredStateConfiguration

    Node $AllNodes.Where{$_.Role -eq "HTTPSPull"}.Nodename {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }          
        
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = $Node.CertificateThumbPrint
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
        }       
    }
}

$ComputerName = 'Pull'
$CertificateThumbPrint = Invoke-Command -Computername $ComputerName `
{Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "PSDSCPullServerCert"} | Select-Object -ExpandProperty ThumbPrint}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = $ComputerName
            Role = "HTTPSPull"
            CertificateThumbPrint = $CertificateThumbPrint
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'globomantics\duffneyj' -message 'Enter admin pwd')
        }                      
    )             
}

GlobomanticsHTTPSPull -ConfigurationData $ConfigData -outputpath c:\dsc\pull

Set-DscLocalConfigurationManager -Path c:\dsc\pull -Verbose -Force -ComputerName $ComputerName
Start-DscConfiguration -Path c:\dsc\pull -Wait -Force -Verbose