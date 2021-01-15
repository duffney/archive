---
layout: post
title:  "Introduction to Regular Expression (Regex) Lab Setup"
date:   2017-02-01 09:02:00
comments: true
tags: [PowerShell, Regex, RegularExpression, Lability, DSC]
modified: 2017-02-01
---

![introtoregex](/images/posts/2017-02-01\introtoregex.png "introtoregex")

I'm proud to announce my second Pluralsight course titled [Introduction to Regular Expression (Regex)](https://app.pluralsight.com/library/courses/regular-expression-introduction/table-of-contents) has been released! I'll be honest, this wasn't an easy topic to cover.
Regular expression is considered difficult for a number of reasons, but I found the most challenging part to be a good reference. I put a lot of thought, time, and effort
into the logical layout of the course, which I hope makes learning regular expression easier and more digestible. Don't get me wrong great material does exist, but I found
the best material goes way too fast. It's also mostly geared towards developers and using regex in C#, Java, Perl or .Net. In this course, I chose to use my beloved language of choice
PowerShell! The rest of this blog post walks you through the lab setup required to follow along with the course. To automate the process, I'm using a PowerShell module called Lability
and Desired State Configuration (DSC). Don't know much about DSC? Well... my first course [Practical Desired State Configuration](https://app.pluralsight.com/library/courses/practical-desired-state-configuration/table-of-contents) can help. :)

### Prerequisites

* Hyper-V Host (Windows 10 or Windows Server 2012r2+)
* Internet access
* PowerShell Version 5+
* Introduction to Regular Expression (Regex) Exercise files


### Setting up Lability

Before you can begin the lab setup you'll need to download the Lability module for the PowerShell gallery. To do that I'll be using a PowerShell v5 cmdlet
called `Install-Module`. Once the module is download be sure to import it into your PowerShell session.

{% highlight powershell %}
Install-Module -Name Lability -Repository PSGallery
Import-Module Lability
{% endhighlight %}

Once the module is installed, it's time to set the default values for the lab folders. The command below sets the locations for the configuration path, hotfix path
and iso path.

{% highlight powershell %}
Set-LabHostDefault -ConfigurationPath C:\Lability\Configurations -HotfixPath C:\Lability\Hotfixes -IsoPath C:\Lability\ISOs
{% endhighlight %}

After the lab default are setup it's time to create the directory structure for Lability. To do that we'll use another cmdlet from the Lability module called
`Start-LabHostConfiguration`. Once the cmdlet runs take a look at the directory structure as shown in the screenshot below. All the directory names are fairly 
self-explanatory, but it's worth familiarizing yourself with the structure.

{% highlight powershell %}
Start-LabHostConfiguration
{% endhighlight %}

![StartLabConfig](/images/posts/2017-02-01\Start-LabHostConfiguration.png "StartLabConfig")

At this point all we've done is setup the directory structure and made sure the Hyper-V feature was turned on. It's now time to download the .iso for the
operating system we'll be using which in this Lab is Windows Server 2016. You can use Windows Server 2012r2 if you want, but you'll want to update PowerShell to v5. In the
course I used Windows Server 2016, so I recommend using that. To download the media issue the following command. _Might take awhile, even with a fast internet connection_

{% highlight powershell %}
Invoke-LabResourceDownload -MediaId 2016_x64_Datacenter_EN_Eval
{% endhighlight %}

The next step is to copy the DSC files from the course's exercise files to your Lability configuration folder. We set this to `c:\Lability\Configuration` when we used the
`Set-LabHostDefault` cmdlet. The course exercise files are located with the course on the [Pluralsight site](https://app.pluralsight.com/library/courses/regular-expression-introduction/exercise-files). 
Simply click the *Download exercise files* button to get your copy of the files. Once downloaded extract the files.

![excersiefiles](/images/posts/2017-02-01\excersiefiles.png "excersiefiles")

Within the extracted folder there will be a directory called Lability. Browse into that folder and copy _IntroToRegex.ps1_ and _IntroToRegex.psd1_ to `c:\Lability\Configuration` If you kept the folder name of regular-expression-introduction when you extracted the zip you can use the command below to copy the files.

```powershell
Download Exercises files to Downloads folder

Expand-Archive $env:USERPROFILE\Downloads\regular-expression-introduction.zip -DestinationPath $env:USERPROFILE\Downloads\regular-expression-introduction

Copy-Item C:\$env:USERPROFILE\Downloads\regular-expression-introduction\Lability\* -Destination C:\Lability\Configurations\
```


### Building the Lab with Lability

Before we can use DSC to build the lab, we first need a few DSC resources. With PowerShell v5 this is easy, use the `Find-Module` and `Install-Module` cmdlets.
Introduction to regular expression requires the xActiveDirectory module version 2.16.0.0 or higher and xWindowsEventForwarding version 1.0.0.0 or higher. 

{% highlight powershell %}
Find-Module -Name xActiveDirectory -MinimumVersion 2.16.0.0 | Install-Module
Find-Module -Name xWindowsEventForwarding -MinimumVersion 1.0.0.0| Install-Module
{% endhighlight %}

Now the fun part! It's time to generate the .mof documents that will be used to provision the environment. In order to generate the .mofs you'll need to load
the configuration into memory and then execute it. When prompted enter the password you'd like the administrator account to be.


{% highlight powershell %}
cd c:\Lability\Configurations
. C:\Lability\Configurations\IntroToRegex.ps1
IntroToRegex -ConfigurationData .\IntroToRegex.psd1 -OutputPath C:\Lability\Configurations\
{% endhighlight %}

After the DSC configuration runs, you should have two .mof files. One named _GDC01.mof_ and another named _GDC01.meta.mof_. The .mof file is the configuration for the
node and the meta.mof is the Local Configuration Manager settings for the node.

![mofs](/images/posts/2017-02-01\mofs.png "mofs")

At this point we are all set, the only thing left to do is let Lability use its magic and build out the lab environment for us. To start up the lab you need to use the
`Start-LabConfiguration` cmdlet from the Lability module. The only parameter needed is `-ConfigurationData`, which points to the _IntroToRegex.psd1_ file we copied from the
exercise files. I chose to use the `-Verbose` parameter as well so I could see a detailed log of what was happening. When prompted enter the local administrator password, the
same one entered at the time of generating the DSC configurations.

*Delete all external adapters on your Hyper-V host before running this command*


{% highlight powershell %}
Start-LabConfiguration -ConfigurationData .\IntroToRegex.psd1 -Verbose
{% endhighlight %}

_Coffee break ETA 10 minutes_


Once Lability has finished building out the virtual machine, you'll want to power it on. To do that you can go inside the Hyper-V manager and start the vm or
you can use PowerShell to power it up. Below is the command for that. 


{% highlight powershell %}
Start-VM -Name IntroToRegex-GDC01
{% endhighlight %}

At this point we've used Lability to create the virtual machine. Behind the scenes Lability copied DSC resources to the machine, injected the .mof documents and started the DSC configuration.
Once you power on the virtual machine Lability will be in the process of applying the DSC configuration. The configuration that I wrote isn't that long, but does create a domain and that
requires a reboot. Every time I generated this lab, it took around 10-15 minutes for the DSC configuration to apply. Since you've already got some coffee, I'd recommend starting the course
now and come back to the blog post when the DSC configuration has finished. The last step is optional, it copies the exercise files to the vm. You can do this manually if you'd like as well.

_Tip if the virtual machine get stuck at the Hyper-V screen for more than 15 minutes hit the reset button_


Assuming you extracted the exercise files to a folder named `regular-expression-introduction` in your Downloads directory the following section of code will copy the exercise files
into the virtual machine created by Lability. Once the exercise files are in place on the virtual machine, you are ready to follow along with the demos throughout the entire course.

_Tip some of the demos reference specific file paths, you'll need to update them to reflect the new path to the files_

{% highlight powershell %}
$session = New-PSSession -VMName IntroToRegex-GDC01 -Credential globomantics\administrator
Invoke-Command -Session $session -ScriptBlock {New-Item -Type Directory -Name Intro-To-Regex -Path 'C:\'}
Copy-Item -Path "C:\$env:USERPROFILE\Downloads\regular-expression-introduction\*" -Destination 'c:\Intro-To-Regex\' -ToSession $session -Recurse
{% endhighlight %}

## Non-Hyper-V Hosts Instructions

In case you are not using Hyper-V as your hypervisor you can still use the Dsc documents to provision the lab environment. You will need to create a virtual machine by some means
on your host. Whether that be by mounting an ISO and installing from disk or by using some other provisioning like vagrant. The following set of instructions assumes you've created a virtual machine and install a Windows Server operation system 2012R2 or higher with PowerShell version 5 installed.

### Setting up the Virutal Machine


Before you can run the Dsc configuration you have to download the required resource modules from the PSGallery. The following command will find and install the two required modules.
You might be promopted when it starts the download to allow it, click `Yes To All` when prompted.

{% highlight powershell %}
Find-Module xactivedirectory,xwindowseventforwarding | Install-Module
{% endhighlight %}

The configuration used in this lab requires the server name to be `GDC01`, issue the below command in a PowerShell prompt to rename the computer.

{% highlight powershell %}
{% endhighlight %}


### Download Exercise Files & Run the Configuration


Next you will need to download the excercise files found [here](https://app.pluralsight.com/library/courses/regular-expression-introduction/exercise-files). Copy the IntroToRegex.ps1 and IntroToRegex.psd1 into the new virtual machine. Save them to any location you'd like. Once both files are copied open then both up in the PowerShell ISE. You can do that by right clicking and selecting edit.

Within the IntroToRegex.psd1 add `$ConfigData =` at the start of line 1, so it looks like the below snippet. Select all the code by hitting `ctrl + a` and hit F8 to run the code. This will give you the configuration data in a variable called `$ConfigData`. Which will be used with the Dsc configuration in the next step.

{% highlight powershell %}
$ConfigData = @{
{% endhighlight %}

With the `$ConfigData` loaded into memory, switch the PowerShell ISE to the IntroToRegex.ps1 file. Hit F5 to run the entire configuration, this will load it into memory so we can execute it. After the configuration in loaded into memory execute the below line in the interactive PowerShell console. When prompted for credential enter the local administrator password and click Ok. When the configuration finishes generating the mof you'll see an output of the 

{% highlight powershell %}
IntroToRegex -ConfigurationData $ConfData -OutputPath `c:\dsc`
{% endhighlight %}

The last few stepss are to apply the Local Configuration Manager settings and run the Dsc configuration. To do that issue the below commands pointing the path parameter to the folder that contains the GDC01.mof and GDC01.meta.mof files.

{% highlight powershell %}
Set-DscLocalConfigurationManager -Path 'C:\dsc`\' -Force -Verbose
Start-DscConfiguration -Path 'C:\dsc`' -Wait -Verbose -Force
{% endhighlight %}

After applying the configuration, you'll be forced for a restart. Because the GDC01.meta.mof contain some settings to allow reboots and to continue the configuration after reboot no intervention is required. *Configuration takes 3-5 minutes to run* 


*Thank you for your interest in my course, I hope you enjoy it and happy learning!*