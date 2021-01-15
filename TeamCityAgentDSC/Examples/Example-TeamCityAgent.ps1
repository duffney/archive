configuration TeamCityAgent_config {

    Import-DscResource -ModuleName 'TeamCityAgentDsc'
    node localhost {

        TeamCityAgent Integration_Test {
            AgentName = 'Agent'
            AgentHostname = $env:COMPUTERNAME
            AgentPort = 9090
            AuthorizeAgent = $false
            AgentHomeDirectory = "$env:SystemDrive\TeamCity\Agent"
            AgentWorkDirectory = "$env:SystemDrive\TeamCity\Agent\work"
            State = 'Started'
            ServerHostname = 'TeamCityServer'
            ServerPort = 80
            Ensure = 'Present'
        }
    }
}