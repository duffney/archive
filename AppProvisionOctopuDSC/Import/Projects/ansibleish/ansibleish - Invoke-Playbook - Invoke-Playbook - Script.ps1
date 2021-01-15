#Requires -Version 5

. "$Path\scripts\Invoke-Playbook.ps1"

$splat = @{
        Path = $Path
        HostName = $HostName
        Repository = $Repository
        inventoryName = $inventoryName
    }
    if ($Include)
    {
        $Include = $Include -split ','
        $splat.Add('Include',$Include)
    }
    elseif ($Exclude)
    {
        $Exclude = $Exclude -split ','
        $splat.Add('Exclude',$Exclude)
    }

Invoke-Playbook @splat