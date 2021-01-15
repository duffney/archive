---
layout: post
title: Creating Lab Environments with LabBuilder
comments: true
tags: [Hyper-V, DSC, PSRemoting, Lab, LabEnvironments, Desired State Configuration]
modified: 2016-6-26 8:00:00
date: 2016-6-26 8:00:00
---
#### Applies to: Windows PowerShell 5.0, Hyper-V

Stop testing in production! You've been hearing that for a while now, and so had I. However, I continued to do it. Mainly in part because I was too lazy to setup the required infrastructure
to simulate my production environments. Let's face it, most of us won't be able to mirror our production environments. Given the choice I'd nuke my production environments and start over.
Accepting the fact that I wouldn't be replicating production fully, I adopted the Minimum Viable Product (MVP) agile approach to building lab environments. 

While on my quest to stop testing my powershell code in production I ran a cross a module called [LabBuilder](https://github.com/PlagueHO/LabBuilder) created by [Daniel Scott-Raynsford](https://github.com/PlagueHO). 
It's one of many tools and modules available that help you automate the creation of your lab environments. In this post I'll be showing you how to use it to build out a lab environment to 
setup Windows Event Forwarding on a few domain controllers. My goal with this is to provide you a practical example of how to use this module.

###  Download LabBuilder
First of course, you must download the LabBuilder module. It is on GitHub, but it's on the PowerShell Gallery as well. I'll use Install-Module to install it on my Hyper-V host (Windows 10 Desktop).

{% highlight powershell %}
Find-Module LabBuilder | Install-Module -Verbose
{% endhighlight %}

### Create a New LabBuilder Environment
Now that I have download the LabBuilder module, next I'll use one of the cmdlets included in the module to setup the framework for my Windows Event Forwarding lab environment. New-Lab, is the
name of the cmdlet. This cmdlet basically creates the folder structure for everything; DSC configs, iso files, virtual machine disks and the virtual machine templates. It also generates the .xml files
which is used to define every aspect of the lab. LabBuilder reads in this .xml file and creates all the network adapters, vlans, virtual machines, etc... 


{% highlight powershell %}
New-Lab -ConfigPath $env:SystemDrive:\WEFADSecurityLogs\WEFADSecurityLogs.xml -LabPath $env:SystemDrive:\WEFADSecurityLogs -Name WEFADSecurityLogs
{% endhighlight %}


![NewLab](/images/posts/2016-6-26/NewLab.png "NewLab")

### Modify .XML Configuration File
With the framework in place, next I'll modify the .xml fit to my needs. Refer to the module samples and [documentation](https://github.com/PlagueHO/LabBuilder/blob/dev/LabBuilder/docs/labbuilderconfig-schema.md)
for more details on the .xml file. In a nutshell though, I need to define all the switches, templateVHDs, templates, and virtual machine settings in this file. Below is the .xml file I'm going to use.
It will deploy 4x Windows Server 2016 TP5 servers, three will be domain controllers and 1 will be my Event Log Collector. 

{% gist fda8d3eece7c3a15e4995715c4194818 %}

### Download ISO
Since I'm only using one operating system [Windows Server 2016 TP5](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-technical-preview), I only need to download one ISO and place it in the ISOFiles directory New-Lab created.
It's important to keep the name the same as when it downloaded or update it in your .xml file.

![ISOFiles](/images/posts/2016-6-26/ISOFiles.png "ISOFiles")

### Update DSC Configurations

For this particluar lab, I wanted a few machines that use the Member Default DSC configuration to have the Active Directory PowerShell module and the Group Policy Management console installed. So instead of doing that manually, I just modified the MEMBER_DEFAULT.DSC.ps1 file.
I added the below lines of code to it to accomplish what I needed.

{% highlight powershell %}
Windowsfeature RSATADPowerShell {
    Ensure = 'Present'
    Name = 'RSAT-AD-PowerShell'
}

Windowsfeature GPMC {
    Ensure = 'Present'
    Name = 'GPMC'
}  
{% endhighlight %}

              
### Installing the Lab
To build the lab environment use the cmdlet Install-Lab, this is the cmdlet that kicks off all the automation. Simply provide it the path for the configuration .xml and watch the magic happen! 

{% highlight powershell %}
Install-Lab -ConfigPath G:\WEFADSecurityLogs\WEFADSecurityLogs.xml -Verbose  
{% endhighlight %}

![InstallLab](/images/posts/2016-6-26/InstallLab.png "InstallLab")
