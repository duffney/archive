$Global:ModuleName = 'TeamCityAgentDsc'
$Global:DscResourceName = 'TeamCityAgent'

# Unit Test Template Version: 1.2.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:ModuleName `
    -DSCResourceName $Global:DscResourceName `
    -TestType Unit -ResourceType class

function Invoke-TestSetup {

}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

try 
{
    Invoke-TestSetup

    InModuleScope -ModuleName TeamCityAgent {
        Describe 'Test Method' {
            $TeamCityAgentResource = [TeamCityAgent]::new()
            $TeamCityAgentResource.AgentName = 'Agent'

            Context 'Type Test' {
                It 'Test should return a bool' {
                    $TeamCityAgentResource.Ensure = [Ensure]::Present
                    $TeamCityAgentResource.Test() | should BeofType bool
                }
            }

            Context 'Ensure Absent' {
                $TeamCityAgentResource.Ensure = [Ensure]::Absent
                $TeamCityAgentResource.AgentHomeDirectory = 'C:\TeamCity\Work'
                $TeamCityAgentResource.State = [State]::Stopped

                It "Test should return true when service is absent" {
                    Mock -CommandName Get-Service -MockWith {}
                    $TeamCityAgentResource.Test() | should be $true
                }
            }

            Context 'Ensure Present' {
                $TeamCityAgentResource.Ensure = [Ensure]::Present
                $TeamCityAgentResource.AgentHomeDirectory = 'C:\TeamCity\Work'                

                It 'Test should return false when service is missing' {
                    Mock -CommandName Get-Service -MockWith {}
                    $TeamCityAgentResource.Test() | should be $false
                }

                It 'Test should return true when service is present' {
                    Mock -CommandName Get-Service -MockWith {[PSCustomObject]@{Name='TCBuildAgent-Agent'}}
                    Mock -CommandName Test-Path -MockWith {$true}
                    $TeamCityAgentResource.Test() | should be $true
                }
            }
        }

        Describe 'Get Method' {

            Context 'With valid State' {
                $TeamCityAgentDsc = [TeamCityAgent]::new()
                $TeamCityAgentDsc.Ensure = [Ensure]::Present
                $TeamCityAgentDsc.AgentName = 'Agent'
                $TeamCityAgentDsc.AgentHomeDirectory = 'C:\TeamCity\Work'
                Mock -CommandName Get-Service -MockWith {[PSCustomObject]@{Name='TCBuildAgent-Agent';Status='Running'}}
                Mock -CommandName Test-Path -MockWith {$true}

                it 'Get should return State of Started' {
                    $object = $TeamCityAgentDsc.Get()

                    $object.GetType().Name | Should be 'TeamCityAgent'
                    $object.Ensure | Should be 'Present'
                    $object.AgentName | Should be 'Agent'
                    $object.AgentHomeDirectory | should be 'C:\TeamCity\Work'
                    $object.AgentServiceName | Should be 'TCBuildAgent-Agent'
                    $object.State | should be 'Started'
                }
            }

            Context "With invalid State" {
                $TeamCityAgentDsc = [TeamCityAgent]::new()
                $TeamCityAgentDsc.Ensure = [Ensure]::Present
                $TeamCityAgentDsc.AgentName = 'Agent'
                $TeamCityAgentDsc.AgentHomeDirectory = 'C:\TeamCity\Agent'
                Mock -CommandName Get-Service -MockWith {}
                Mock -CommandName Test-Path -MockWith {$false}

                It 'Get should return State of Stopped' {
                    $object = $TeamCityAgentDsc.Get()

                    $object.GetType().Name | Should be 'TeamCityAgent'
                    $object.Ensure | Should be 'Absent'
                    $object.AgentName | Should be 'Agent'
                    $object.AgentHomeDirectory | should be 'C:\TeamCity\Agent'
                    $object.AgentServiceName | Should be 'TCBuildAgent-Agent'
                    $object.State | should be 'Stopped'
                }
            }
        }

        Describe 'Set Method' {
            
            Context 'Ensure Present & Absent' {
                $TeamCityAgentResource = [TeamCityAgent]::new()
                $TeamCityAgentResource.AgentName = 'Agent'
                $TeamCityAgentResource.AgentHomeDirectory = 'C:\TeamCity\Agent'
                $TeamCityAgentResource = $TeamCityAgentResource | Add-Member -MemberType ScriptMethod -Name RequestFile -Value { throw 'TeamCity server was not found' } -Force -PassThru
                
                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName Stop-Service -MockWith {} -Verifiable
                

                It 'Set Should throw with Ensure present' {
                    $TeamCityAgentResource.Ensure = [Ensure]::Present
                    {$TeamCityAgentResource.Set()} | Should Throw 'TeamCity server was not found'
                }

                It 'Set Should not throw with Ensure absent State stopped' {
                    $TeamCityAgentResource.Ensure = [Ensure]::Absent
                    $TeamCityAgentResource.State = [State]::Stopped
                    {$TeamCityAgentResource.Set()} | Should Not Throw
                }

                It 'Set Should throw with Invalid configuration' {
                    $TeamCityAgentResource.Ensure = [Ensure]::Absent
                    $TeamCityAgentResource.State = [State]::Started
                    {$TeamCityAgentResource.Set()} | Should Throw "Invalid configuration: service cannot be both 'Absent' and 'Started"
                }
            }

            Context 'State Stopped Current State Started' {
                $TeamCityAgentResource = [TeamCityAgent]::new()
                $TeamCityAgentResource.AgentName = 'Agent'
                $TeamCityAgentResource.AgentHomeDirectory = 'C:\TeamCity\Agent'
                $TeamCityAgentResource.State = [State]::Stopped                   
                Mock -CommandName Get-Service -MockWith {[PSCustomObject]@{Name='TCBuildAgent-Agent';Status='Running'}}
                Mock -CommandName New-Item -MockWith {}
                Mock -CommandName Stop-Service -MockWith {} -Verifiable                    
                    
                It 'Set Should stop service' {
                    $TeamCityAgentResource.Set()
                    Assert-MockCalled -CommandName Stop-Service -Times 1 -Exactly
                }
            }

            Context 'Set Should invoke mocks' {
                $TeamCityAgentResource = [TeamCityAgent]::new()
                $TeamCityAgentResource.AgentName = 'Agent'
                $TeamCityAgentResource.AgentHomeDirectory = 'C:\TeamCity\Agent'
                $TeamCityAgentResource.ServerHostName = 'Server'
                $TeamCityAgentResource.ServerPort = 80
                $TeamCityAgentResource = $TeamCityAgentResource | Add-Member -MemberType ScriptMethod -Name RequestFile -Value {} -Force -PassThru
                $TeamCityAgentResource = $TeamCityAgentResource | Add-Member -MemberType ScriptMethod -Name WriteTokenReplacedFile -Value {} -Force -PassThru
                $TeamCityAgentResource = $TeamCityAgentResource | Add-Member -MemberType ScriptMethod -Name UpdateServiceWrapper -Value {} -Force -PassThru

                Mock -CommandName Get-Service -MockWith {} -Verifiable
                Mock -CommandName Test-Path -MockWith {$false} -Verifiable
                Mock -CommandName New-Item -MockWith {} -Verifiable
                Mock -CommandName Expand-Archive -MockWith {} -Verifiable
                Mock -CommandName Push-Location -MockWith {} -Verifiable
                Mock -CommandName Start-Process -MockWith {} -Verifiable
                Mock -CommandName Pop-Location -MockWith {} -Verifiable

                It "All mocks Should be verifiable within Set method" {
                    $TeamCityAgentResource.Set()
                    Assert-VerifiableMocks
                }

            }
        }

        Describe 'VerifyTeamCityInstall method' {

            Context 'Ensure Absent' {
                $TeamCityAgentResource = [TeamCityAgent]::new()

                Mock -CommandName Get-Service -MockWith {}
                Mock -CommandName Test-Path -MockWith {$false}
                
                It 'Should return Status Stopped Ensure Absent' {
                    $object = $TeamCityAgentResource.VerifyTeamCityInstall('C:\TeamCity\Agent','TCBuildAgent-Agent')
                    $object.AgentServiceName | Should be 'TCBuildAgent-Agent'
                    $object.currentEnsure | Should be 'Absent'
                    $object.currentState | Should be 'Stopped'
                }
            }

            Context 'Ensure Present' {
                $TeamCityAgentResource = [TeamCityAgent]::new()

                Mock -CommandName Get-Service -MockWith {[PSCustomObject]@{Name='TCBuildAgent-Agent';Status='Running'}}
                Mock -CommandName Test-Path -MockWith {$true}
                
                It 'Should return Status Started Ensure Present' {
                    $object = $TeamCityAgentResource.VerifyTeamCityInstall('C:\TeamCity\Agent','TCBuildAgent-Agent')
                    $object.AgentServiceName | Should be 'TCBuildAgent-Agent'
                    $object.currentEnsure | Should be 'Present'
                    $object.currentState | Should be 'Started'
                }
            }
        }
    }
} 
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}