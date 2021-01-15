Configuration GlobomanticsHTTPSPull {
    param (
        [string]$NodeName
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

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

        WindowsFeature IISConsole 
        {
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
        }                      
    )             
}

GlobomanticsHTTPSPull -ConfigurationData $ConfigData -outputpath c:\dsc\pull

Set-DscLocalConfigurationManager -Path c:\dsc\pull -ComputerName $ComputerName -Verbose -Force
Start-DscConfiguration -Path c:\dsc\pull -ComputerName $ComputerName -Wait -Force -Verbose

Start-Process -FilePath iexplore.exe https://pull.globomantics.com:8080/PSDSCPullServer.svc