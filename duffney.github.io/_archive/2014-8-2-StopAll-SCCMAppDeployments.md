---
layout: post
title: Stop All System Center Configuration Manager Application Deployments
comments: true
tags: [PowerShell, SCCM]
modified: 2014-8-2 8:00:00
date: 2014-8-2 8:00:00
---
#### Applies to: Windows PowerShell 3.0+, SCCM

In the process of migrating to a new System Center Configuration Manager installation, I was tasked with stopping all of the old Configuration Manager application deployments. I didn't end up counting how many there were, but it was more than I was willing to manually remove! Which brings us to why I'm writing this blog post. When you use the Remove-CMDeployment cmdlet in PowerShell you need two pieces of information, the application name and the collection name. At first I thought this was rather useless, because if I knew that I'd be looking at the deployment already in the console and could delete it then.

However after some brain storming, I discovered a Config Manager report that lists all application deployments with several columns of  data. Two of the columns fortunately had the application name and collection name listed in it. The name of this report is "All application deployments (advanced)". Which can be found under the following path Software Distribution > Application Monitoring > All application deployments (advanced). Since this report contains several other unneeded fields, I exported it to a .csv file then removed all unnecessary columns. Now that we know the application name and the collection name, we can easily automate the removal of these deployments with PowerShell! Below is a screen shot of the report for reference and below that is the PowerShell code to use for removing the application deployments.

![sccmreport](/images/posts/2014-8-2/sccmreport.png "sccmreport")

{% highlight PowerShell %}
# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney
# Date: 07/31/2014
# Description: Pulls ApplicationName and Collection name from a .csv file to remove\stop the application deployment.
# Comments: Refer to the RemoveCMApplication.csv file for a template. Run the SCCM report Software Distribtuion > Application Monitoring > All application deployments (advanced) to get a list of application names and collections they are deployed to.
# ---------------------------------------------------

Function RemoveCMDeployments {

    Param(
    [string]$SiteServerName,
    [string]$SiteCode,
    [string]$csvPath
)
   
   ## Import SCCM Console Module
    Try
    {
    Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -ErrorAction Stop
    Set-Location "$($SiteCode):"
    }
    Catch [System.IO.FileNotFoundException]
    {
        "SCCM Admin Console not installed"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }
    Finally
    {
        "This Script attempted to import the SCCM module"
    }
    
    $pkgs = Import-Csv "$csvPath"

    $ApplicationName = $pkg.ApplicationName    

    foreach($pkg in $pkgs){
        Try{
        Remove-CMDeployment -ApplicationName $pkg.ApplicationName -CollectionName $pkg.CollectionName -Force -ErrorAction Stop | Out-Null
        Write-Host "$ApplicationName was removed" -ForegroundColor Green
        }
        Catch
        {
        }
    }

}

RemoveCMDeployments -SiteServerName ServerName -SiteCode SiteCode -csvPath "C:\scripts\RemoveCMApplication.csv"
{% endhighlight %}