---
layout: post
title: Fix 0KB Driver Packages in System Cennter Configuration Manager 2012 with PowerShell
comments: true
tags: [PowerShell, SCCM]
modified: 2015-4-10 8:00:00
date: 2015-4-10 8:00:00
---
#### Applies to: Windows PowerShell 3.0+, SCCM

There is a known issue with System Center Configuration Manager 2012, where after importing or creating a driver package the size could be 0KB. The problem is, it causes a task sequence that is using the driver package to fail. Since the size is 0, it thinks that the driver package isn't distributed to the distribution points. To resolve this you must perform the following actions in the console. Make sure the driver pack is distributed then remove one driver from the driver package and add it back in along with redistributing it. This may not seem like something worth scripting, but let me assure you it is. Once you have 40+ driver packages the console takes an extremely long time to load, around 10 minutes for me. Another reason is I import several packages at a time and updating them all one by one takes a lot of time.

Below is a script I've written along with a function for adding drivers to a driver package online. The script will search for any driver packages that have a size of 0KB and then remove the first driver listed in the driver package, add it back in and then update the driver package. Sometimes the first driver won't update the size, so I change the 0 in line 32 to 1 and run the script again to remove and re-add driver 2. You'll need to replace SiteCode and Server on lines 2 and 3 with information from your environment.

{% highlight PowerShell %}
$DriverPacks = (Get-CMDriverPackage | Where-Object PackageSize -EQ "0").PackageID
$SiteCode = 'SiteCode'
$CMServer = 'Server'

Function Add-DriverContentToDriverPackage
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Site code")]
              $SiteCode,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Name")]
              $SiteServer,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Driver Name")]
              $DriverCI,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Driver Package Name")]
              $DriverPackageName
         )     

    $DriverPackageQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_DriverPackage -ComputerName $SiteServer -Filter "Name='$DriverPackageName'"
    $DriverQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_Driver -ComputerName $SiteServer -Filter "CI_ID='$DriverCI'"
    $DriverContentQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_CIToContent -ComputerName $SiteServer -Filter "CI_ID='$($DriverQuery.CI_ID)'"

    $DriverPackageQuery.AddDriverContent($DriverContentQuery.ContentID,$DriverQuery.ContentSourcePath,$False)
}

Foreach ($DriverPack in $DriverPacks) {

$DriverPackSize = (Get-CMDriverPackage -Id $DriverPack).PackageSize
Write-Host $DriverPackSize -ForegroundColor Green

$Drivers = (Get-CMDriver -DriverPackageId $DriverPack).CI_ID
$Driver = $Drivers[0]
Write-host $Driver -ForegroundColor Green

$DriverPackName = (Get-CMDriverPackage -Id $DriverPack).Name
Write-Host $DriverPackName -ForegroundColor Green

Write-Host "Removing $Driver from $DriverPackName..." -ForegroundColor Green
Remove-CMDriverFromDriverPackage -DriverId $Driver -DriverPackageId $DriverPack -Force -Confirm:$false

Write-Host "Adding $Driver from $DriverPackName..." -ForegroundColor Green
Add-DriverContentToDriverPackage -SiteCode $SiteCode -SiteServer $CMServer -DriverCI $Driver -DriverPackageName $DriverPackName

$DriverPackSize = (Get-CMDriverPackage -Id $DriverPack).PackageSize
Write-host $DriverPackSize -ForegroundColor Green

}
{% endhighlight %}