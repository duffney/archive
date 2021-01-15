---
layout: post
title: Compare Active Directory and System Center Configuration Manager Active Devices
comments: true
tags: [PowerShell, SCCM]
modified: 2014-8-9 8:00:00
date: 2014-8-9 8:00:00
---
#### Applies to: Windows PowerShell 3.0+, SCCM


The purpose of this script is to check a list of computers provided by a text file against Active Directory and System Center Configuration Manager to determine whether or not they are active. You might use this script if you manage System Center Configuration Manager and frequently need to validate devices that are active in both Active Directory and System Center Configuration Manager.

To use this script we'll need to place valid values for all the parameters called after the function in line 57 of the script. The information we'll require is; the server name of the system center configuration manager server, the site code used by that configuration manager server and the location of the text file that contains the computer names you wish to check. The text file should contain one computer name per line for the script to work. Modify line 57 to match your environment, below is an example. The computer running this script requires both the Active Directory Module and System Center Configuration Manager Module be available.

{% highlight PowerShell %}
DeviceCheck -SiteServerName ServerName -SiteCode SiteCode -ComputerList "D:\Scripts\computers.txt"
{% endhighlight %}

### DeviceCheck Function

{% highlight PowerShell %}
# ---------------------------------------------------
# Version: 3.0
# Author: Joshua Duffney
# Date: 07/15/2014
# Updated: 8/9/2014
# Description: Using PowerShell to check for a list of devices in SCCM and AD then returning the results in a table format.
# Comments: Populate computers.txt with a list of computer names then run the script.
# References: @thesurlyadm1n, @adbertram
# ---------------------------------------------------

Function DeviceCheck {
    Param(
        [string]$SiteServerName = 'ServerName',
        [string]$SiteCode = 'SiteCode',
        [string]$ComputerList
        )

## Connect to SCCM
    $ErrorActionPreference = "stop"

    if (!(Test-Path "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1")) {
        Write-Error 'Configuration Manager module not found. Is the admin console installed?'
        } elseif (!(Get-Module 'ConfigurationManager')) {
            Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
        }
        Set-Location "$($SiteCode):"

## Looking for device in SCCM

foreach ($computer in (Get-Content $ComputerList))
{
$value = Get-CMDevice -Name $computer
if ($value -eq $null){$Results = "NO"}
else{$Results = "Yes"}

## Looking for device in Active Directory

try {
    Get-ADComputer $computer -ErrorAction Stop | Out-Null
    $computerResults = $true
}
Catch {
    $computerResults = $false

}

[PSCustomObject]@{
        Name = $computer
        SCCM = $Results
        AD = $computerResults
        }

}

}

DeviceCheck -SiteServerName ServerName -SiteCode SiteCode -ComputerList "D:\Scripts\computers.txt"
{% endhighlight %}