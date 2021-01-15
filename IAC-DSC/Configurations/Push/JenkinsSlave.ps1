Configuration JenkinsSlave {
    param (
        [string[]]$NodeName
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module cChoco

    Node $AllNodes.Nodename {

        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = '44C95F9F5FB8A106ECAB7A555AAFC74D8F095FF9'            
            RebootNodeIfNeeded = $true            
        }

        WindowsFeature NetFrameworkCore
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = 'D:\sources\sxs'
        }

        cChocoInstaller installChoco
        {
            InstallDir = "c:\choco"
            DependsOn = "[WindowsFeature]NetFrameworkCore"
        }        

        cChocoPackageInstaller installJdk8
        {
            Name = "jdk8"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        File Checkouts
        {
            Ensure          = "Present"
            DestinationPath = 'C:\Checkouts'
            Type            = "Directory"       
        }        
                            
        Environment Password {
            Ensure = 'Present'
            Name = 'Password'
            Value = ($Node.SvcCredential.GetNetworkCredential().Password)
        }

        Environment UserName {
            Ensure = 'Present'
            Name = 'UserName'
            Value = $Node.SvcCredential.GetNetworkCredential().UserName
        }

        xScript NewJNLPScheduledTask {
            GetScript = {
                return @{
                    Result=(Get-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent').TaskName
                }
            }
 
            SetScript = {
                
                $ActionParams = @{
                    Execute = 'C:\Program Files\Java\jdk1.8.0_102\bin\java.exe'
                    Argument = '-jar slave.jar -jnlpUrl http://master/computer/Slave/slave-agent.jnlp -secret 37e93023c74ae1529db72342d511e508c5ec929138484c7b358be29b1196c7ed'
                    WorkingDirectory = 'C:\Checkouts' 
                }

                $Action = New-ScheduledTaskAction @ActionParams
                $Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup
                $Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
                $Settings.ExecutionTimeLimit = "PT0S"
                $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings

                $output = $Task | Register-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -User $env:UserName -Password $env:Password

                Write-Verbose -message $output
            }
 
            TestScript = {
                $ScheduledTask = Get-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -ErrorAction SilentlyContinue
                
                If ($ScheduledTask){
                    Write-Verbose -Message "ScheduledTask Jenkins [JNLP Slave Agent] exists"
                    $true
                } else {
                    Write-Verbose -Message "ScheduledTask Jenkins [JNLP Slave Agent] did not exists calling SetScript"
                    $false
                }
            }
        }                
                
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'slave'
            Certificatefile = 'c:\certs\slave.cer'            
            SvcCredential = (Get-Credential -UserName 'winops\svc_jenkins' -message 'Enter admin pwd')
        }                      
    )             
}

JenkinsSlave -ConfigurationData $ConfigData -OutputPath c:\dsc -Verbose

$cim = New-CimSession -ComputerName slave
Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\ -Verbose -Force
Start-DscConfiguration -CimSession $cim -Path c:\dsc -Wait -Force -Verbose