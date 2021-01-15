function Publish-DSCResourcePush
{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    Param
    (
        [string[]]$Module,
        $ComputerName
    )

    Begin
    {
    }
    Process
    {
        foreach ($Item in $Module)
        {
            if (-not (Get-Module $Item -ListAvailable))
                {
                    Install-Module $Item -Confirm:$false
                }

            $params =@{
                Path = (Get-Module $Item -ListAvailable).ModuleBase
                Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\$Item"
                ToSession = (New-PSSession -ComputerName $ComputerName)
                Force = $true
                Recurse = $true
                Verbose = $true

            }

            Copy-Item @params
        }
    }
    End
    {
    }
}