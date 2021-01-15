Configuration JenkinsSlave {
    param (
        [string[]]$NodeName
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xPSDesiredStateConfiguration
    Node $AllNodes.Nodename {

        
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = '44C95F9F5FB8A106ECAB7A555AAFC74D8F095FF9'            
            RebootNodeIfNeeded = $true            
        }    

        $User = $Node.SvcCredential.GetNetworkCredential().UserName
        $Password = ($Node.SvcCredential.GetNetworkCredential().Password)
        
        xScript NewJNLPScheduledTask {
            
            GetScript = {
                
                return @{
                    Result=(Get-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent').State
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

                $output = $Task | Register-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -User $using:User  -Password $using:Password

                Write-Verbose -message $output
            }
 
            TestScript = {
                $ScheduledTask = Get-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -ErrorAction SilentlyContinue
                
                If ($ScheduledTask){
                    Write-Verbose -Message "ScheduledTask Jenkins [JNLP Slave Agent] exists"
                    $true
                } else {
                    Write-Verbose -Message "ScheduledTask Jenkins [JNLP Slave Agent] does not exists calling SetScript"
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