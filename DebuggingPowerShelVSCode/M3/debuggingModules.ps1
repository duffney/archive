#region PrepTasks
<#

Run VSCode as Admin

Get-NetConnectionProfile | `
where-Object NetworkCategory -eq 'Public' | `
Set-NetConnectionProfile -NetworkCategory Private

winrm quickconfig

Set-PackageSource -Name PSGallery -Trusted

Find-Module xPSDesiredStateConfiguration -RequiredVersion '7.0.0.0' | Install-Module

Find-Module InvokeDSC -RequiredVersion '2.0.78' | Install-Module

Import-Module InvokeDSC

#>
#endregion

$config =
@"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.4.0.0"
    },
   "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
   }
}
"@

Invoke-DscConfiguration -InputObject $config -Verbose
