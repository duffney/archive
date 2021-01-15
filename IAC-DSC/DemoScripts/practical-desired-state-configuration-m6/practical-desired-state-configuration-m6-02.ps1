#Install and Stage DSC Resource Modules
$Modules = 'xWindowsEventForwarding','xNetworking'

foreach ($Module in $Modules)
{
    if (-not (Get-Module $Module -ListAvailable))
        {
            Install-Module $Module -Confirm:$false
        }

    $params =@{
        Path = (Get-Module $Module -ListAvailable).ModuleBase
        Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\$Module"
        ToSession = (New-PSSession -ComputerName Collector)
        Force = $true
        Recurse = $true
        Verbose = $true

    }

    Copy-Item @params
}

Invoke-Command -ComputerName Collector `
-ScriptBlock {Get-Module $Using:Modules -ListAvailable} -ArgumentList $Modules

psedit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsCollector.ps1