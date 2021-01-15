---
layout: post
title:  "Configuring an HTTPS Pull Server for Desired State Configuration PowerShell Version 5"
date:   2017-03-10 09:02:00
comments: true
tags: [PowerShell, DSC, DesiredStateConfiguration, LCM, Pull, PullServer, HTTPS]
modified: 2017-03-10
---
#### Applies to: Windows PowerShell 5.0


In a previous [blog post](http://duffney.io/Configure-HTTPS-DSC-PullServer) I walked through the setup of an HTTPS pull server, at the time of the writing there was only one way to setup a pull server with HTTPS. Since that blog post was published, Microsoft has released another version of the Pull server which I'll refer to as version 2. The offical Microsoft documentation for setting up a pull server can be found [here](https://msdn.microsoft.com/en-us/powershell/dsc/pullserver). There are a few key differences between version 1 and version 2. First off, there is no longer a compliance server. Secondly, you now use a registration key to connect to the pull server instead of a configuration ID. A third difference is you can now call out which configurations a node should request from the pull server by name. You no longer have to rename the .mof documents on the pull server with the GUI used for the configuration ID. Keep in mind that both methods still work, however the new method does make combining DSC configuration a lot easier.

This blog post will be a complete guide for setting up an HTTPS pull server to deliver DSC configurations. Before you can use a pull server you need an Active Directory domain as well as a certificate authority. I'll start this blog post by showing you how to use Lability and DSC to automate the provision of that environment. After the domain is built, I'll walk you through the process of requesting a web server certificate for the pull server. Once you obtained the certificate, I'll show you how to write a DSC configuration for setting up the pull server itself. I then, show you how to publish DSC configurations and DSC resources to the pull server. After that, I show you how to set up the LCM of a client node and requesting a configuration from the pull server. By the end of this blog post, you'll have all the knowledge necessary for standing up your own pull secure server for both a lab environment or production environment.


* TOC
{:toc}

## Setting up the AD Domain and Certificate Authority with Lability

### Install Lability
Before you can begin the lab setup you'll need to download the Lability module for the PowerShell gallery. To do that I'll be using a PowerShell v5 cmdlet
called `Install-Module`. Once the module is download, be sure to import it into your PowerShell session.


{% highlight powershell %}
Install-Module -Name Lability -Repository PSGallery
Import-Module Lability
{% endhighlight %}


Once the module is installed, it's time to set the default values for the lab folders. The command below sets the locations for the configuration path, hotfix path, and iso path.


### Setup Lab Host Defaults & Directories
{% highlight powershell %}
Set-LabHostDefault -ConfigurationPath C:\Lability\Configurations -HotfixPath C:\Lability\Hotfixes -IsoPath C:\Lability\ISOs
{% endhighlight %}


After the lab defaults are set up, it's time to create the directory structure for Lability. To do that we'll use another cmdlet from the Lability module called
`Start-LabHostConfiguration`. Once the cmdlet runs, take a look at the directory structure as shown in the screenshot below. All the directory names are fairly 
self-explanatory, but it's worth familiarizing yourself with the structure.


{% highlight powershell %}
Start-LabHostConfiguration
{% endhighlight %}


![StartLabConfig](/images/posts/2017-02-01\Start-LabHostConfiguration.png "StartLabConfig")


At this point all we've done is setup the directory structure and made sure the Hyper-V feature was turned on. It's now time to download the .iso for the
operating system we'll be using, which in this Lab, is Windows Server 2016. You can use Windows Server 2012r2 if you want, but you'll want to update PowerShell to v5. In the course I used Windows Server 2016, so I recommend using that. To download the media, issue the following command. _It might take awhile, even with a fast internet connection_


### Install Windows Server 2016 Media
{% highlight powershell %}
Invoke-LabResourceDownload -MediaId 2016_x64_Datacenter_EN_Eval
{% endhighlight %}



### Provision DSC Lab Environment
Now that you have the Lability directories set up and the Windows Server 2016 media downloaded, it's time to build the lab environment. In order for Lability to work you'll need two
files [DSCPullServerLab.ps1](https://gist.github.com/Duffney/d62d05b3fd42b4308014bae8c586e184) and [DSCPullServerLab.psd1](https://gist.github.com/Duffney/77f038437abbd742fa3b0614bf6471a4). You can either copy and paste the code in the GitHub gists and save the code into the two files mentioned or use the following commands to create the two files within your `C:\Lability\Configurations` directory. _DSCPullServerLab.ps1_ is the DSC configuration Lability will use to automate the setup of the AD domain and certificate authority. _DSCPullServerLab.psd1_ is the configuration data used by the DSC configuration. It also contains some Lability specific information that provide details on what OS to use for the environment as well as much memory and CPU to give the virtual machine. Once both files are created, your configurations directory should look like the screenshot below.



{% highlight powershell %}
$URI = 'https://gist.githubusercontent.com/Duffney/d62d05b3fd42b4308014bae8c586e184/raw/ec7dad827e7e0a0cd10395d6342e82c0aef2337f/DSCPullServerLab.ps1'
$content = (Invoke-WebRequest -Uri $URI).content
New-Item -Path C:\Lability\Configurations\ -Name DSCPullServerLab.ps1 -Value $content

$URI = 'https://gist.githubusercontent.com/Duffney/77f038437abbd742fa3b0614bf6471a4/raw/e9cb784edad0758bf2244e475e40cfc80fa06cfd/PullServerLab.psd1'
$content = (Invoke-WebRequest -Uri $URI).content
New-Item -Path C:\Lability\Configurations\ -Name DSCPullServerLab.psd1 -Value $content
{% endhighlight %}


![configurationsdir](/images/posts/DSCHTTPSPullServerPSv5/configurationsdir.png "configurationsdir")


With both of these files in place you're now ready to run the DSC configuration, but before you can do that you have to load the configuration into memory. To do that I'll dot source _DSCPullServerLab.ps1_ into memory and then execute it with the configuration data provided by _DSCPullServerLab.psd1._ After the configuration is executed it will generate two .mof documents. One will be called pull.mof and the other will be called pull.meta.mof. If you're not yet familiar with these two files I recommend getting a copy of [The DSC Book](https://leanpub.com/the-dsc-book). It does a great job of breaking down all the components of DSC.


{% highlight powershell %}
cd c:\Lability\Configurations
. .\DSCPullServerLab.ps1
Pull -ConfigurationData .\DSCPullServerLab.psd1 -OutputPath C:\Lability\Configurations\
{% endhighlight %}


![RunLabilityConfig](/images/posts/DSCHTTPSPullServerPSv5/RunLabilityConfig.gif "RunLabilityConfig")


Now that both .mof files are created it is now time to start the lab configuration. The cmdlet to do that is `Start-LabConfiguration`. The only mandatory parameter you have to use is `-ConfigurationData`. I however, prefer to add the `-Verbose` parameter as well, so I can see what Lability is doing. When promptedenter the local administrator password, the same one entered at the time of generating the DSC configurations.


*Delete all external adapters on your Hyper-V host before running this command*


{% highlight powershell %}
Start-LabConfiguration -ConfigurationData .\DSCPullServerLab.psd1 -Verbose
{% endhighlight %}


Once Lability has finished building out the virtual machine, you'll want to power it on. To do that you can go inside the Hyper-V manager and start the vm or
you can use PowerShell to power it up. Below is the command for that.


{% highlight powershell %}
Start-VM -Name DSC-Pull
{% endhighlight %}


_Coffee break ETA 10 minutes_



## Generate Pull Server Web Certificate


Once the virtual machine has finished booting up it should be configured as both a domain controller and a certificate authority. Log into the virtual machine with the username of administrator and use the password you created when generating the .mof documents. Next, open up the PowerShell ISE. We now have to generate the web server certificate that the pull server will use for HTTPS traffic. I'll be using the certutil command line utility and PowerShell to request the certificate. All the code required to obtain the certificate is listed below. If you'd like to walk through the process in the GUI, follow the steps in my previous [blog post](http://duffney.io/Configure-HTTPS-DSC-PullServer). You could also use a PowerShell function called [New-DomainSignedCertificate](https://gist.github.com/Duffney/d78b3d9beebcf31aa053256e802ad34f), which I found on Stack. It basically wraps the certutil inside a PowerShell function.


{% highlight powershell %}
$inf = @"
[Version] 
Signature="`$Windows NT`$"

[NewRequest]
Subject = "CN=Pull, OU=IT, O=Globomantics, L=Omaha, S=NE, C=US"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
FriendlyName = PSDSCPullServerCert
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

$infFile = 'C:\temp\certrq.inf'
$requestFile = 'C:\temp\request.req'
$CertFileOut = 'c:\temp\certfile.cer'

mkdir c:\temp
$inf | Set-Content -Path $infFile

& certreq.exe -new "$infFile" "$requestFile"

& certreq.exe -submit -config Pull.globomantics.com\globomantics-PULL-CA -attrib "CertificateTemplate:WebServer" "$requestFile" "$CertFileOut"

& certreq.exe -accept "$CertFileOut"
{% endhighlight %}


## Writing the Pull Server DSC Config


We now have everything we need to build a pull server. Because DSC is meant to automate the configuration of Windows Servers, I will of course use a DSC configuration to setup the pull server. This configuration has three parameters: Nodename, CertificateThumbPrint, and RegistrationKey. Nodename will be the name of the pull server. CertificateThumbPrint is the certificate thumbprint of the web server certificate we generated previously. This part can be tricky, because if you're using certificates to encrypt the mofs, there will be a different thumbprints. Just keep in mind this is the thumbprint of the web server certificate which encrypts the HTTPS traffic not the .mof files. The last parameter, RegistrationKey, needs a little explaining. In version "2" of the pull server, this registration key is used to authenticate the client node with the pull server. It's nothing more than a GUID stored in a text file, but it's very important. This replaces the configuration ID used by version "1" of the pull server. This registration key will be used again when we configure the LCM of the client node that connects to the pull server.


The pull server configuration consists of three DSC resources: WindowsFeature, xDscWebService, and File. WindowsFeature and File are built-in DSC resources that are part of the PSDesiredStateConfiguration module. These two are included with every Windows Server that works with DSC. The WindowsFeature resource is being used to install the Windows feature _DSC-Service_, which is required for the pull server to work. The File resource is being used to create a file called _RegistrationKeys.txt_ and to set the contents. The contents of the file is the registration key and as I mentioned previously, this key is just a GUID. _xDscWebService_ is the DSC resource that is setting up the pull server. Since it's a HTTPS "Web" pull server it will be performing some IIS tasks. 


Within the configuration block of _xDscWebService_ there are several properties worth mentioning. EndpointName is the name of the pull server service. Port, is of course the port the pull server will use for it's communications. PhysicalPath is the physical path for the web service. CertificateThumbPrint is the thumbprint of the web server certificate we generated previously, this is populated by the certificateThumbPrint parameter. ModulePath is the path the pull server will store the modules it distributes to the client nodes. ConfigurationPath is the path where the pull server stores the DSC configurations for the client nodes. UseSecurityBestPractices is a boolean value, when it's set to true, it enforces the use of stronger encryption cypher. For more information about this setting, read the read.me of the [xPSDesiredStateConfiguration](https://github.com/PowerShell/xPSDesiredStateConfiguration). There are a few other properties, but they're self explanatory.


{% gist 1bd49fae18da35c811488326cfb441cb %}


## Deploying the Pull Server Config
    
Since it's the pull server we are configuring, we can't have it pull it's own configuration just yet. We'll have to push the configuration you just wrote above to the pull server, which is easily done. I'll be performing this task on the pull server, but you could easily deploy it from a remote authoring machine as well. Before we can start the DSC configuration, we'll need two things: a GUID and the certificate thumbprint of the web server certificate. Generating a new GUID is easy, just use the newGUID method of the GUID class like this `[guid]::newGuid()`. I always store it inside a variable `$guid` so, if for any reason, I can use it again later. Obtaining the certificate thumbprint isn't difficult either. Since we provided a nice and friendly name of _PSDSCPullServerCert_ it's easily found with `Get-ChildItem`. The path to the certificate is `Cert:\LocalMachine\My`, I'll use Where-Object to filter the results `Get-ChildItem Cert:\LocalMachine\My | where {$_.FriendlyName -eq 'PSDSCPullServerCert'}`. Again, I typically store this in a variable so I can reuse it later if needed. I normally name that variable `$cert`.


{% highlight powershell %}
$guid = [guid]::newGuid()

$cert = Get-ChildItem Cert:\LocalMachine\My | where {$_.FriendlyName -eq 'PSDSCPullServerCert'}
{% endhighlight %}


Now that we have both the GUID and the certificate information we can run the pull server dsc configuration which will generate the pull server .mof document! Remember to load the configuration into memory before attempting to execute the configuration. Once the configuration is loaded into memory you can execute it by specifying the name and then any parameters it had. I've named this configuration _DscPullServer_, you'll have to provide all the parameters as I've done below. The value for the certificateThumbPrint is $cert.Thumbprint because the thumbPrint is a property of the $cert variable object. -RegistrationKey is the guid we generated and I'm also providing a specific output path for the mof file once it's generated. 


{% highlight powershell %}
DscPullServer -certificateThumbPrint $cert.Thumbprint -RegistrationKey $guid -OutputPath c:\dsc
{% endhighlight %}


With the mof document generated, the last thing we need to do before you have an operational pull server, is to push the configuration. The cmdlet for that is `Start-DscConfiguration`. The only mandatory parameter is -Path, which is used to provide the path to the mof document you just generated. I also recommend using -Wait and -Verbose, so you can see what the configuration is doing. By default, the cmdlet creates a background job to run the configuration in, using the -Wait pushes the output to the console. -Verbose displays the pretty blue output text. 


{% highlight powershell %}
Start-DscConfiguration -Path C:\dsc -Wait -Verbose
{% endhighlight %}


![pullconfigverbose](/images/posts/DSCHTTPSPullServerPSv5/pullconfigverbose.png "pullconfigverbose")

## Testing the Pull Server


Before we move on, it's a good idea to confirm that the pull server is operating correctly. To test the pull server, open up Internet Explorer and to go ` https://pull:8080/PSDSCPullServer.svc`. You should get some xml results returned to you. If you do, congratulations! You have a pull server! _If you changed the name of the pull server, you'll have to update this URL_. If you want to do it the *PowerShell* way, you can use `Invoke-WebRequest` as well. The pull server works nicely with server core, so learning the PowerShell way is always a good choice. When using the Invoke-WebRequest method, make sure the StatusCode returns 200, and the content contains some xmls stuff.


{% highlight powershell %}
Invoke-WebRequest -Uri 'https://pull:8080/PSDSCPullServer.svc/' -UseBasicParsing
{% endhighlight %}


![verifypullserver](/images/posts/DSCHTTPSPullServerPSv5/verifypullserver.png "verifypullserver")


## Publishing Content to the Pull Server


At this point, you now have an operational DSC HTTPS pull server. It's now time to author some DSC configurations that you want the clients of the pull server to pull down and have them configure themselves with those configurations. There are a few steps involved with this process, which consists of the following.


1. Download required DSC resource modules
2. Author the DSC configuration
3. Publish content to the pull server
    1. Generate checksum for DSC configuration
    2. Copy configuration and checksum to the specified  directory
    3. Archive DSC resource module
    4. Copy DSC resource modules and checksums to specified directory


### Downloading Required DSC Resource Modules


In my example, I'll be writing a simple webserver configuration. Within this configuration I needed to create a virtual directory within IIS. To accomplish this I'll be using the _xWebVirtualDirectory_ DSC resource, which is within the _xWebAdministration_ module. Because of that, I'll need to download that module before I can write my DSC configuration. Without the module, I won't be able to compile the mof document. To install the module, I'll simply use `Install-Module`. This cmdlet is only available in PowerShell v5 or later.


{% highlight powershell %}
Install-Module xWebAdministration
{% endhighlight %}


### Authoring the Pull Server Client DSC Configuration


The next step is to write the DSC configurations you want the clients of the pull server to pull down. The configuration I'm using installs the windowsfeature web-server, as well as creates a folder at the root of C: called Globomantics. The last thing it does is create a virtual directory in IIS with a physical path of the folder created at C:\Globomantics. Creating the virtual directory requires the external DSC resource _xWebAdministration_, which I previously downloaded. After you run the configuration you also need to generate a checksum for that configuration, as outlined in step 3.1 shown above. Luckily enough, there is a cmdlet that will do this for, you called `New-DscChecksum`. All you need to do is provide the path of the mof document and it will generate a checksum for you. Once the mof document and checksum are generated, it's now time to publish them to the pull server.


{% gist 4bf617655382d8e6fe7dc7a18b67c62c %}


### Publishing Content to the Pull Server

Before I go into the steps required for publishing the content on the pull server, let's review a snippet of code from the DSC configuration that setup the pull server. Within the xDSCWebService resource we specified a few directories. One of them was called _ModulePath_, this is the location where we need to publish the _xWebAdministration_ module to. This is used by the pull server clients when they don't have the module or modules required for the DSC configuration. By providing it on the pull server they can dynamically pull down which resource modules they need, which is one huge benefit of a pull server. The next directory we specified was _ConfigurationPath_, this is the location on the pull server we need to publish or copy our new mof and checksum files. This is where the pull server clients look for configurations. You can see that both of these directories are located at _$env:PROGRAMFILES\WindowsPowerShell\DscService_. Now that we know where the pull server is looking for these files, we can complete the process by copying them there.


{% highlight powershell %}
xDscWebService PSDSCPullServer
        {
        Ensure = 'present'
        EndpointName = 'PSDSCPullServer'
        Port = 8080
        PhysicalPath = "$env:SystemDrive\inetpub\PSDSCPullServer\"
        CertificateThumbPrint = $certificateThumbPrint
        ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
        ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
        State = 'Started'
        DependsOn = '[WindowsFeature]DSCServiceFeature'
        UseSecurityBestPractices = $true
        }
{% endhighlight %}


Let's first start by copying the WebServerConfig and it's checksum to the _ConfigurationPath_. As you can see above, I chose `$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration`, as the configuration directory so that's where I'll need to copy these files to. You can use any method you'd like to copy the files. In this demonstration I'm going to be using the pull server to update it's own configuration. So in my example, the pull server is both the server and the client. If you're using a different node to author the configurations you'll have to copy these files to the pull server. 


_Tip: PowerShell version 5 Copy-Item supports copying over a remote session, an example can be found [here](https://github.com/Duffney/IAC-DSC/blob/master/Helper-Functions/Copy-ItemResources.ps1)_


{% highlight powershell %}
$WebConfigPath = "$env:SystemDrive"+'\dsc\WebServer\*'
$PullConfigPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $WebConfigPath -Destination $PullConfigPath -Recurse
{% endhighlight %}


Looking at steps 3.3 and 3.4 from above, it mentions archiving the module. This means we'll have to zip up the DSC resource modules. When you do this, a specific naming format is required, otherwise it will not work properly on the pull server. Which would result in the clients not getting the DSC resource modules they need. The naming standard is _ModuleName_VersionNumber.zip_. You can of course do this all through the GUI if you'd like and I'd recommend that if it's your first time doing that. However, after about three times there isn't much value in manually doing it so instead you can use PowerShell to perform all these actions. Writing some helper functions around the code I'm about to show you is a great idea. After all the files have been generated and copied to the pull server locations, the directories should look like the screenshot below.


{% highlight powershell %}
$ModuleName = 'xWebAdministration'
$Version = (Get-Module $ModuleName -ListAvailable).Version
$ModulePath = (Get-Module $ModuleName -ListAvailable).modulebase+'\*'

$DestinationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($Version).zip"

Compress-Archive -Path $ModulePath -DestinationPath $DestinationPath
New-DscChecksum -Path $DestinationPath
{% endhighlight %}


![pullserverdirs](/images/posts/DSCHTTPSPullServerPSv5/pullserverdirs.png "pullserverdirs")


## Pulling Configurations


You now have an operational pull server and have published both a DSC configuration and a DSC resource module to the pull server. The next and final step is to pull that configuration from the pull server. Before you can pull the configuration, you have to configure the client node's LCM _Local Configuration Manager_, this is what connects the client node with the pull server. Since we have to write the LCM configuration before we can apply, let's talk about that next. 


### Write the Client LCM Configuration


In PowerShell version 5 or higher, a special line of code is used at the beginning of a DSC configuration to indicate that it's a LCM configuration. That line of code is `[DSCLocalConfigurationManager()]’, which you'll see on line 1 of the configuration below. Besides this, the rest of the configuration is just like a normal DSC configuration.
The first resource _Settings_ configures the configuration mode and refresh mode. Configuration mode is how the LCM applies the configuration. There are a few options that I won't list here, to learn more check out [Configuring the Local Configuration Manager](https://msdn.microsoft.com/en-us/powershell/dsc/metaconfig). I've chosen to set it to ApplyAndAutoCorrect. Refresh mode only has two settings, push and pull. We of course want to set this to pull, because we are going to start using our pull server to deliver DSC configurations. 

The next resource _ConfigurationRepositoryWeb_ sets up the configuration repository as the name implies. In a nutshell, it's just telling the LCM where to get it's configurations from. ServerURL is the path to the DSC configurations, in my example it's `https://pull:8080/PsDscPullserver.svc`. The only thing you'd ever need to change is the server name and possibly the port number if you decided to not use 8080. Because we set up an HTTPS pull server, we want to make sure we set AllowUnsecureConnection to $false, so it rejects http traffic and forces https. Next is the RegistrationKey, which we set when we configured the pull server. If you don't remember what it is, don't worry, it's stored in a .txt file on the pull server at `$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt` or wherever you told it to be stored in the pull server DSC configuration. The last property set within the ConfigurationRepositoryWeb are the ConfigurationNames. ConfigurationNames replaces the ConfigurationID, previously used. It now allows you to specify multiple configurations. I'm only using one, which is _WebServerConfig_. It's an array, so adding more than one is simple, just make sure the name used here matches the name of the .mof document on the pull server. 

ResourceRepositoryWeb is the last resource used in this LCM configuration. It sets up the location where the pull client will look for DSC resource modules. When we update the configuration and it detects that it doesn't have the xWebAdministration module, it will look here to download it. The ServerURL is the same as the ConfigurationRepositroyWeb, which is `https://pull:8080/PsDscPullserver.svc`. AllowUnsecureConnection is set to false here as well, to avoid http requests. The registration key is also used here to authenticate the client with the pull server. 

{% gist 69acfa13e0b3756a69b70443fa42d393 %}

### Set the LCM and Pull the DSC Configuration

The moment of truth has arrived! The last few things you need to do in order to complete the pull server is generate the LCM meta.mof document, apply the LCM configuration, and then update the DSC configuration from the pull server. Seems like a lot, but it's really just three lines of code. Before you can run the LCM_Pull configuration shown above, you had to load it into memory. Before continuing, do that first. After the configuration is loaded into memory, execute it by running the configuration by name `LCM_Pull`. This will generate the meta.mof document used to configure the LCM of the client node. Again, in my example, the pull server is both the server and client. Once the meta.mof document is created, you can apply it by using the cmdlet `Set-DSCLocalConfigurationManager`. You'll need to specify the path to the directory where the meta.mof file is. Do not specify the full path to the meta.mof, just the folder it's in. I like to turn on both -Verbose and -Force so I can see what's going on. -Force, of course overwrites any existing settings. With the LCM configured, the only thing left is to update the DSC configuration and see if it can successfully pull down a new configuration. The cmdlet for that is `Update-DscConfiguration`, you'll need to provide a computer name to this cmdlet. I again use the -Verbose and -Wait parameters so I can see the verbose output as well as see it in the console window.


{% highlight powershell %}
LCM_Pull

Set-DscLocalConfigurationManager -ComputerName pull -Path .\LCM_Pull -Verbose -Force

Update-DscConfiguration -ComputerName pull -Verbose -Wait
{% endhighlight %}


![updateconfig](/images/posts/DSCHTTPSPullServerPSv5/updateconfig.gif "updateconfig")

### Future Learnings, Sources, and Credits

You now have a fully functional DSC pull server! Once you've run through this a few times it becomes very easy. There are a lot of moving parts which confused me early on and I hope this blog post helps you through the process. I often see reddit posts or tweets asking where should I go to learn DSC, so there is my compiled list. I've personally watched or read most of these sources of information and can vouch for their usefulness.


## Best Sources for Learning DSC

*Free Video Training*


[Getting Started with PowerShell Desired State Configuration (DSC)](https://mva.microsoft.com/en-US/training-courses/getting-started-with-powershell-desired-state-configuration-dsc-8672?l=ZwHuclG1_2504984382)


[Advanced PowerShell Desired State Configuration (DSC) and Custom Resoures](https://mva.microsoft.com/en-US/training-courses/advanced-powershell-desired-state-configuration-dsc-and-custom-resources-8702?l=3DnsS2H1_1504984382)


[What's New in PowerShell v5](https://mva.microsoft.com/en-US/training-courses/whats-new-in-powershell-v5-16434?l=Oq4Os59VC_2506218965)


*Paid Video Training*


[Windows PowerShell Desired State Configuration Fundamentals](https://www.pluralsight.com/courses/powershell-desired-state-configuration-fundamentals)


[Advanced Windows PowerShell Desired State Configuration](https://www.pluralsight.com/courses/advanced-powershell-dsc)

_My course thanks for watching!_


[Practical Desired State Configuration (DSC)](https://www.pluralsight.com/courses/practical-desired-state-configuration)


_Books_


[The DSC Book](https://leanpub.com/the-dsc-book)


## Sources


[The DSC Book](https://leanpub.com/the-dsc-book) - You should pick up a copy :)


[Configuring the Local Configuration Manager](https://msdn.microsoft.com/en-us/powershell/dsc/metaconfig)

[Setting up a DSC web pull server](https://msdn.microsoft.com/en-us/powershell/dsc/pullserver)

[http://duffney.io/Configure-HTTPS-DSC-PullServer](http://duffney.io/Configure-HTTPS-DSC-PullServer)


## Credit


[Arie H](https://disqus.com/by/ArieHein/) left a comment on my blog letting me know that a previous blog post of mine was out of date and there was a new version documented on msdn. He explained the shortcomings of my previous post and pointed out what was different between v1 and v2 at a high level. It was his comment that motivated me to write this blog post. I'll be honest, I didn't want to write it as first because of the time commitment, but I knew he was right, I should write it, so I did! Thanks for the motivation Arie H.
