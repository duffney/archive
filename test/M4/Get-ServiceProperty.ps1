function Get-ServiceProperty
{
    <#
    .SYNOPSIS
    Returns a list of specified properties about a service.
    .DESCRIPTION
    Uses Win32_Service to gather information about service properties.
    .PARAMETER Name
    Specifies the name of the service
    .PARAMETER Property
    Specifies the property or properties to return, accepts wildcards.
    .EXAMPLE
    Get-ServiceProperty -Name RemoteRegistry
    .EXAMPLE
    Get-ServiceProperty -Name RemoteRegistry -Property *
    .EXAMPLE
    Get-ServiceProperty -Name RemoteRegistry -Property StartName,DelayedAutoStart,PathName
    .Example
    Get-Service RemoteRegistry | Get-ServiceProperty
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,
        [string[]]$Property    )

    begin
    {


        if ($null -eq $Property -or '*' -ne $Property)
        {
            $Property = 'ExitCode', 'Name', 'ProcessID', 'StartMode', 'State', 'Status'
        }
        else
        {
            $Property + 'ExitCode', 'Name', 'ProcessID', 'StartMode', 'State', 'Status'
        }
    }

    process
    {
        $filter = "Name = '$Name'"
        $return = Get-WmiObject -Class Win32_Service -Filter $filter | Select-Object $Property

    }

    end
    {
        $return
    }
}
