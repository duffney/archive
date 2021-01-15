Describe 'WabApp Tests' {

    BeforeAll {
        Import-Module WebAdministration
        $path = "$env:SystemDrive\logs\webApp"
        $ACL = (Get-Item $Path).GetAccessControl('Access')
        $ar = $acl.Access | where IdentityReference -Match 'IIS APPPOOL\webApp'
        $appPool = Get-ItemProperty -Path "IIS:\AppPools\webApp" | Select-Object *
        $application = Get-WebApplication -Name webApp | Select-Object *
    }

    it "[PhysicalPath] should exist" {
        (Test-Path -Path $env:SystemDrive'\webapp\') | should be $true
    }

    it "[AppPool] name shoudl be [WebApp]" {
        $appPool.Name | should be 'WebApp'
    }

    it "[AppPool] managedRunTimeVersion v4.0" {
        $appPool.managedRuntimeVersion | should be 'v4.0'
    }

    it "[AppPool] idleTimeoutAction should be Terminate" {
        $appPool.processModel.idleTimeoutAction | should be 'Terminate'
    }

    it "[AppPool] idleTimeout should be 00:20:00" {
        ($appPool.processModel.idleTimeout).ToString() | should be '00:20:00'
    }

    it "[AppPool] cpuLimit should be 25000" {
        $appPool.cpu.limit | should be 25000
    }

    it "[AppPool] cpuAction should be ThrottleUnderLoad" {
        $appPool.cpu.action | should be 'ThrottleUnderLoad'
    }

    it "[AppPool] cpuResetInterval should be 00:05:00" {
        ($appPool.cpu.resetInterval).tostring() | should be '00:05:00'
    }

    it "[AppPool] restartTimeLimit should be 00:00:00" {
        ($appPool.recycling.periodicRestart.time).tostring() | should be '00:00:00'
    }

    it "[AppPool] restartRequestsLimit should be 0" {
        $appPool.recycling.periodicRestart.requests | should be 0
    }

    it "[AppPool] enable32bitonWin64 should be false" {
        $appPool.enable32BitAppOnWin64 | should be $false
    }

    it "[AppPool] autoStart should be true" {
        $appPool.autoStart | should be $true
    }

    it "[Application] site should be Default Web Site" {
        (Test-Path -Path "IIS:\Sites\Default Web Site\webApp") | should be $true
    }

    it "[Application] appPool should be WebApp" {
        $application.applicationPool | should be 'WebApp'
    }

    it "[Application] PreloadEnabled should be true" {
        $application.preloadEnabled | should be $true
    }

    it "[Application] EnabledProtocols should be http" {
        $application.enabledProtocols | should be 'http'
    }

    it "[Application] Anonymous authentication should be true" {
        (Get-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -PSPath "IIS:\Sites\Default Web Site\webApp").Value | should be $true

    }

    it "[Application] ServiceAutoStartEnabled should be true" {
        $application.serviceAutoStartEnabled | should be $true
    }
}
