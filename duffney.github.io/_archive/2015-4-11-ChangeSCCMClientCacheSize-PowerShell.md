---
layout: post
title: Change System Center Configuration Manager Client Cache Size with PowerShell
comments: true
tags: [PowerShell, SCCM]
modified: 2015-4-11 8:00:00
date: 2015-4-11 8:00:00
---
#### Applies to: Windows PowerShell 3.0+


![error](/images/posts/2015-4-11/error.jpg "error")


The only way to set the Configuration Manager client cache size is by specifying it at installation. This was troublesome for me as I left it the default 5GB at install, but then was requested to deploy some AutoDesk packages that where of course over that 5GB limit. Knowing I could not rely on the end user to change their cache size, I knew I had to find a better solution.
I was directed to [HeLaw's blog](https://social.msdn.microsoft.com/profile/helaw), a Microsoft employee who had the answers I was looking for. I took the code he wrote and placed it into and advanced function as you see below. The function will be great for one off computers, but not for a mass deployment. Which is why you'll see several sections of code, one will cover the mass deploy scenario.

[HeLaw's blog](http://blogs.msdn.com/b/helaw/archive/2014/01/07/configuration-manager-cache-management.aspx) post deploys this with a compliance baseline in Configuration Manager, I agree something like this should be done as a compliance baseline. However, to be honest he lost me when he started talking about doing it so I created an application to deploy. Accomplishes the same goal and has reporting. The easiest way I've found to deploy PowerShell code to clients is by using [PowerShell Application Deployment Toolkit](https://psappdeploytoolkit.codeplex.com/). What it does in a nutshell is allow you to write or use a PowerShell script to feed a .exe that will execute the PowerShell script. Since we're deploying this as an application we'll need a detection method, which is listed below as well.

### Advanced Function

{% highlight powershell %}

Function Set-CCMCacheSize {
<#
.SYNOPSIS

Changes the size of the Configuration Manager cache folder.

.DESCRIPTION

This function will change the size of the Configuration Manager ccmcache folder.

.PARAMETER CCMCacheSize

Specify the size of the Cache.

.EXAMPLE

Set-CCMCacheSize -CCMCacheSize 10240

.Notes

.LINK

http://blogs.msdn.com/b/helaw/archive/2014/01/07/configuration-manager-cache-management.aspx

#>
[CmdletBinding()]

param (
  [Parameter(Mandatory=$True,HelpMessage="Enter the size of the ccmcache folder")]
  [String]$CCMCacheSize
  )

Begin {

    $CCM = New-Object -com UIResource.UIResourceMGR

    #USe GetCacheInfo method to return Cache properties
    $CCMCache = $CCM.GetCacheInfo()

    #Get the current cache location
    $CCMCacheDrive = $CCMCache.Location.Split("\")[0]

    #Check Free space on drive
    $Drive = Get-WMIObject -query "Select * from Win32_LogicalDisk where DeviceID = '$CCMCacheDrive'"

    #Convert freespace to GB for easier check
    $FreeSpace = $Drive.FreeSpace/1GB

    }

Process {

    #Check Sizes and set Cache
    If ($Freespace -ge 5 -and $Freespace -lt 15)
    {
    #Free space moderate
    $CacheSize = 5120
    }
    If ($Freespace -ge 15)
    {
    #Plenty of space
    $CacheSize = $CCMCacheSize
    }

    #Set Cache Size
    $CCMCache.TotalSize = $CacheSize

    }
End {

     Write-Verbose (Get-WMIObject -namespace root\ccm\softmgmtAgent -class CacheConfig).Size

}

}

{% endhighlight %}

### Mass Deployment Script

{% highlight powershell %}
#Initialize our CCM COM Objects
 $CCM = New-Object -com UIResource.UIResourceMGR

 #USe GetCacheInfo method to return Cache properties
 $CCMCache = $CCM.GetCacheInfo()

 #Get the current cache location
 $CCMCacheDrive = $CCMCache.Location.Split("\")[0]

 #Check Free space on drive
 $Drive = Get-WMIObject -query "Select * from Win32_LogicalDisk where DeviceID = '$CCMCacheDrive'"

 #Convert freespace to GB for easier check
 $FreeSpace = $Drive.FreeSpace/1GB

 #Check Sizes and set Cache
 If ($Freespace -ge 5 -and $Freespace -lt 15)
 {
 #Free space moderate
 $CacheSize = 5120
 }
 If ($Freespace -ge 15)
 {
 #Plenty of space
 $CacheSize = 10240
 }

 #Set Cache Size
 $CCMCache.TotalSize = $CacheSize
{% endhighlight %}

### Acknowledgements

[HeLaw's Blog Post Configuration Manager: Cache Management](http://blogs.msdn.com/b/helaw/archive/2014/01/07/configuration-manager-cache-management.aspx)