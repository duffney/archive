---
layout: post
title: Setting up an HTTP Pull Server for DSC
excerpt: "0 to DSC in a single blog post"
comments: true
tags: [PowerShell, DSC, Pull, Server]
modified: 2015-08-25 8:00:00
date: 2015-08-25 8:00:00
---
#### Applies to: Windows PowerShell 5.0

In this blog post, we'll be walking through how to setup and configure an HTTP pull server for Desired Stat Configurations. HTTP is only one of the three pull methods, the other two are SMB and HTTPS. It is not recommended you setup HTTP for production, but will work for a Lab without having to configure PKI (public key infrastructure). Belows lists the steps we'll take to accomplish setting up a pull server and the prerequisites.The content of this blog post came from [Getting Started with PowerShell Desired State Configuration (DSC)](https://www.microsoftvirtualacademy.com/en-US/training-courses/getting-started-with-powershell-desired-state-configuration-dsc--8672).

#### Order of Operations

1. Download the xPSDesiredStateConfiguration module.
2. Generate pull server configuration.
2. Push http pull Server DSC config to pull Server.
3. Verify DSC webservices are running.
4. Deploy LCM configurations to target machines.
5. Generate configs for target machnes.
6. Pull DSC configs from http pull server.

#### Prerequisites

* Active Directory Domain (servers joined to domain)
* Minimum 2 Servers 2012R2 with WMF 5.0 Preview (or 2016 Server Preview)
* PowerShell Remoting enabled
* Network connectivity between servers

#### Downloading xPSDesiredStateConfiguration

With PowerShell v5 this is rather simple, PowerShell Get allows us to search the Gallery and then install the module. Without v5, you'd have to find it, download it, extract it and then place it in the modules directoies. To find all the module directories enter this snippit ($env:PSModulePath -split ";"). Since we're using v5, issue the following line of code.

{% highlight powershell %}
Find-Module -name xPSDesired* | Install-Module
{% endhighlight %}

Verify the module got installed

{% highlight powershell %}

Get-Module xPSDesiredStateConfiguration

{% endhighlight %}

#### Generate and push pull server configuration

Microsoft has written a DSC resource to configure the pull servers. Yes, we will be setting up the DSC pull server with DSC! The below code when executed will create a .mof file which we can then push to the pull server to configure it. You could set this all up manually, but why? Be sure to replace W2016P3 with the name of your pull server.

{% gist 97c764e17373b82635cc %}

Issue the below lines of code to generate and push the pull server configuration mof file.

{% highlight powershell %}

HTTPPullServer -OutputPath C:\DSC\HTTP

Start-DscConfiguration -Path C:\DSC\HTTP -ComputerName W2016P3 -Verbose -Wait

{% endhighlight %}

#### Verify Webservices
Replace WS2016P3 with the name of your server, you should see similar output to the screenshot below.

{% highlight powershell %}

Start-Process -FilePath iexplore.exe http://WS2016P3:8080/PSDSCPullServer.svc

{% endhighlight %}

![an image alt text]({{ site.baseurl }}/images/IISPullServer.PNG   "IIS Running")

#### Configure target machines LCM (Local Configuration Manager)

The LCM is the mechanism that informs the server on how it should be getting it's configurtion and how to handle drift. Without settings this up the target systems would never look to our pull server for configs. The following section of code will generate two files for us that we can then push to our target systems. To clarify I'm calling the servers that should connect to the pull server "Target systems". Change the ServerURL in the script to your pull server's name and also change DC02 and DC03 to one or more target system names. Once it's updated execute the entire script to generate the configuration files. You'll notice they are named meta.mof, that's because these files configure the LCM and .mof configures the server.

{% gist a41aa64efac5b2c36355 %}

Walking through this script, we notice that it's changing the ConfigurationMode to ApplyandAutoCorrect. This means when the server drifts from it's desired state it will auto correct itself. The next thing to notice is the RefreshMode, we are now setting it to Pull. This is key, this is what's telling the server to look for a pull server. ServerURL is the URL of the pull server that we tested a few steps back. Finally we're setting AllowUnsecureConnection to true so we can use HTTP.

#### But wait! What are these GUIDs? 

You might be asking the same question I had the first time I saw it. Why is there a GUID? One simple reason, we want to uniquely identify a server. I failed to mention above this section of the LCM configuration, ConfigurationID which accpets a parameter $GUID. What we did here was create a GUID with PowerShell then assign it to the server's LCM. Now when we create or author configurations for that user they will be called GUID.mof not computername.mof. If you want several servers to share the same config then just use the same GUID on all of them. 

#### Pushing the target server LCM settings

With the meta.mof files created we can now set the target server's LCM settings. Replace DC02, DC03 with your server names and execute this code.

{% highlight powershell %}

Set-DSCLocalConfigurationManager -ComputerName DC02,DC03 -Path c:\DSC\HTTP –Verbose

{% endhighlight %}

#### Generate simple configurations for target machines

Execute the below code to generate a simple SMTP configuration for our target servers. 

{% gist 0757e689506cb47dbc7b %}

#### Pull DSC configs from http pull server

The first line below will verify that the SMTP isn't installed, we then invoke an update on the server to update it's config. Since it's now configured to look at the pull server it will pull down it's .mof and install SMTP. The last line confirms the settings took and SMTP is indeed installed.

{% highlight powershell %}

Get-WindowsFeature -ComputerName DC02 -name *SMTP* #Shouldn't be installed yet.
Update-DscConfiguration -ComputerName DC02 #Check to see if it installs
Get-WindowsFeature -ComputerName DC02 -name *SMTP* # Should have installed by now

{% endhighlight %}




