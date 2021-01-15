enum Ensure
 {
     Present
     Absent
 }

 enum State
 {
    Started
    Stopped
 }

 [DscResource()]
 class TeamCityAgent
 {
     [DscProperty(Mandatory)]
     [Ensure]$Ensure

     [DscProperty(Key)]
     [string]$AgentName

     [DscProperty(Mandatory=$false)]
     [State]$State

     [DscProperty(Mandatory=$false)]
     [string]$AgentHomeDirectory

     [DscProperty(Mandatory=$false)]
     [string]$AgentWorkDirectory

     [DscProperty(Mandatory=$false)]
     [string]$AgentHostname     

     [DscProperty(Mandatory=$false)]
     [string]$AgentServiceName

     [DscProperty(Mandatory=$false)]
     [uint32]$AgentPort

     [DscProperty(Mandatory=$false)]
     [bool]$AuthorizeAgent

     [DscProperty(Mandatory=$false)]
     [string]$ServerHostname

     [DscProperty(Mandatory=$false)]
     [uint32]$ServerPort

     [DscProperty(Mandatory=$false)]
     [string]$AgentBuildParameters

     [DscProperty(Mandatory=$false)]
     [string]$JavaPath 


     [TeamCityAgent] Get () 
     {
            if ($null -eq $this.AgentServiceName){
                $this.AgentServiceName = 'TCBuildAgent-'+$this.AgentName
            }
            
            $currentResource = [TeamCityAgent]::new().VerifyTeamCityInstall($this.AgentHomeDirectory,$this.AgentServiceName)

            $this.Ensure = $currentResource.CurrentEnsure
            $this.State = $currentResource.CurrentState

            return $this

     }
     [void] Set () 
     {
         if ($this.Ensure -eq 'Absent' -and $this.State -eq 'Started')
         {
             throw "Invalid configuration: service cannot be both 'Absent' and 'Started'"
         }

        if ($null -eq $this.AgentServiceName){
            $this.AgentServiceName = 'TCBuildAgent-'+$this.AgentName
        }

        $currentResource = $this.VerifyTeamCityInstall($this.AgentHomeDirectory,$this.AgentServiceName)

        if ($this.State -eq 'Stopped' -and $currentResource.CurrentState -eq 'Started')
        {
            Stop-Service -Name $this.AgentServiceName -Force
        }

        if ($this.Ensure -eq 'Absent' -and $currentResource.CurrentEnsure -eq 'Present')
        {
            throw "Remove of TeamCity Agent currently not supported by this DSC resource..."
        }
        elseif ($this.Ensure -eq 'Present' -and $currentResource.CurrentEnsure -eq 'Absent') 
        {
            if (!(Test-Path -Path $this.AgentHomeDirectory)) 
            {
                New-Item $this.AgentHomeDirectory -ItemType Directory
            }

            $installationZipFilePath = "$($this.AgentHomeDirectory)\TeamCityAgent.zip"

            if (!(Test-Path -Path $installationZipFilePath))
            {
                $TeamCityAgentInstallationZipUrl = "http://$($this.ServerHostname):$($this.ServerPort)/update/buildAgent.zip"
                $this.RequestFile($TeamCityAgentInstallationZipUrl,$installationZipFilePath)
            }

            Expand-Archive -LiteralPath $installationZipFilePath -DestinationPath $this.AgentHomeDirectory
            
            $teamCityConfigFile = "$($this.AgentHomeDirectory)\conf\buildAgent.properties"

            $tokenValues = @{
                'serverUrl=http://localhost:8111/' = "serverUrl=http://$($this.ServerHostname):$($this.ServerPort)";
                'name=' = "name=$($this.AgentName)";
                'ownPort=9090' = "ownPort=$($this.AgentPort)";
                '#ownAddress=<own IP address or server-accessible domain name>' = "ownAddress=$($this.AgentHostname)";
                'workDir=../work' = "workDir=$($this.AgentWorkDirectory)";
            }

            if ($this.AgentBuildParameters)
            {
                $AgentBuildParameterHashtable = convertfrom-stringdata -stringdata $this.AgentBuildParameters
                $agentBuildParametersString = ''
                $AgentBuildParameterHashtable.Keys | ForEach-Object { $agentBuildParametersString += "`n$($_)=$($AgentBuildParameterHashtable.Item($_))" }
                $tokenValues.Add('#env.exampleEnvVar=example Env Value',$agentBuildParametersString)
            }

            if ($this.AuthorizeAgent) 
            {
                $autoAuthorize = "authorizationToken=`rauto_authorize=true"
                $tokenValues.Add('authorizationToken=',"$autoAuthorize")
            }

            $teamCityConfigFile = "$($this.AgentHomeDirectory)\conf\buildAgent.properties"

            $this.WriteTokenReplacedFile("$($this.AgentHomeDirectory)\\conf\\buildagent.dist.properties",$teamCityConfigFile,$tokenValues)


            $wrapperPath = "$($this.AgentHomeDirectory)\launcher\conf\wrapper.conf"

            if ($null -ne $this.JavaPath)
            {
                $this.UpdateServiceWrapper($this.AgentServiceName,$wrapperPath,$this.JavaPath)
            }
            elseif ($null -eq $this.JavaPath)
            {
                $this.UpdateServiceWrapper($this.AgentServiceName,$wrapperPath)
            }

            Push-Location -Path "$($this.AgentHomeDirectory)\bin"
            Start-Process -FilePath 'service.install.bat' -Wait -WindowStyle Hidden
            Pop-Location

            Try
            {
                $ServiceState = Get-Service -Name $this.AgentServiceName

                if ($ServiceState.Status -eq 'Stopped')
                {
                    Start-Service -Name $this.AgentServiceName
                }
            }
            catch [Microsoft.PowerShell.Commands.ServiceCommandException]
            {
                throw "Service [$($this.AgentServiceName)] was not found"
            }
        }

         
     }
     [bool] Test () 
     {
        if ($null -eq $this.AgentServiceName){
            $this.AgentServiceName = 'TCBuildAgent-'+$this.AgentName
        }         
         
         $currentResource = [TeamCityAgent]::new().VerifyTeamCityInstall($this.AgentHomeDirectory,$this.AgentServiceName)

         if (!($currentResource.CurrentEnsure -eq $this.Ensure) -or !($currentResource.CurrentState -eq $this.State)){
               return $false
         } 
         
         return $true
     }

     [object] VerifyTeamCityInstall ([string]$AgentHomeDirectory, [string]$AgentServiceName) 
     {
         
         if (Test-Path "$($AgentHomeDirectory)\bin\service.start.bat")
         {
            $currentEnsure = 'Present'
         }
         else 
         {
             $currentEnsure = 'Absent'
         }

         $currentState = 'Stopped'

         $serviceInstance = Get-Service -Name $AgentServiceName -ErrorAction SilentlyContinue
         

         if ($null -ne $serviceInstance)
            {
                Write-Verbose "Windows service: $($serviceInstance.Status)"
                if ($serviceInstance.Status -eq "Running")
                {
                    $currentState = "Started"
                } 
                elseif ($serviceInstance.Status -eq 'Stopped') 
                {
                    $currentState = 'Stopped'
                }

                if ($currentEnsure -eq 'Absent')
                {
                    Write-Verbose "Since the Windows Service is still installed, the service is present"
                    $currentEnsure = 'Present'
                }
            }
            else
            {
                Write-Verbose "Windows service: Not installed"
                $currentEnsure = 'Absent'
            }

            $ReturnObj = [PSCustomObject]@{
                AgentServiceName = $AgentServiceName
                CurrentEnsure = $currentEnsure
                CurrentState = $currentState
            }

            return $ReturnObj
     }

     [void] RequestFile ([string]$url,[string]$saveAs)
     {
         $downloader = New-Object System.Net.WebClient
         $downloader.DownloadFile($url,$saveAs)
     }

     [void] WriteTokenReplacedFile ([string]$FileToTokenReplace,[string]$OutFile,[hashtable]$TokenValues)
     {
         $fileContents = Get-Content -Raw $FileToTokenReplace

         foreach ($token in $TokenValues.GetEnumerator())
         {
             $fileContents = $fileContents -replace $token.Name, $token.Value
         }
        
         [io.file]::WriteAllText($OutFile,$fileContents)
     }
    
     [void] UpdateServiceWrapper ([string]$AgentName,[string]$WrapperPath,[String]$JavaPath)
     {
         $wrapperContent = [IO.File]::ReadAllText($wrapperPath)
         $wrapperContent = $wrapperContent.Replace("wrapper.ntservice.name=TCBuildAgent",("wrapper.ntservice.name="+$AgentName))
         $wrapperContent = $wrapperContent.Replace("wrapper.ntservice.displayname=TeamCity Build Agent",("wrapper.ntservice.displayname="+$AgentName))
         $wrapperContent = $wrapperContent.Replace("wrapper.java.command=java",("wrapper.java.command="+$JavaPath))

         [io.file]::WriteAllText($wrapperPath,$wrapperContent)
     }
     #change $agentname to agentservice name
     [void] UpdateServiceWrapper ([string]$AgentServiceName,[string]$WrapperPath)
     {
         $wrapperContent = [IO.File]::ReadAllText($wrapperPath)
         $wrapperContent = $wrapperContent.Replace("wrapper.ntservice.name=TCBuildAgent",("wrapper.ntservice.name="+$AgentServiceName))
         $wrapperContent = $wrapperContent.Replace("wrapper.ntservice.displayname=TeamCity Build Agent",("wrapper.ntservice.displayname="+$AgentServiceName))

         [io.file]::WriteAllText($wrapperPath,$wrapperContent)
     }     
}