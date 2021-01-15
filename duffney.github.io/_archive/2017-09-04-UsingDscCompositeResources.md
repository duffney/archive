---
layout: post
title:  "Using Desired State Configuration (DSC) Composite Resources"
date:   2017-10-08 09:02:00
comments: true
tags: [PowerShell, DSC, DesiredStatConfiguration, Composite, CompositeResource, Resource]
modified: 2017-10-08
---
### Table of Contents
* TOC
{:toc}


Composite resources can be thought of as help functions, but instead of helper functions for your PowerShell scripts it's a helper resource for your DSC configurations. They help solve the same problem helper functions do by modularizing your code. Which reduces the length and complexity of your code. Here is a comparison between a DSC configuration one without using a composite resource and with using a composite resource. As you can probably guess the shorter configuration is the one using a composite resource. Taking some of the logic out of the main DSC configuration helps you maintain the code by breaking it apart.


![compositevsnoncomposite](/images/posts/UsingDscCompositeResources/compositevsnoncomposite.png "compositevsnoncomposite")


### Understanding Composite Resources


Composite resources work just like mof based resources. They must be placed in the` $env:psmodulepath` to be used, they even follow a similar folder structure--where you have a resource module folder and then all the resources themselves living under a sub folder called DSCResources. The main difference between a composite and a mof based resource is a composite resource uses a `.schema.psm1` file instead of a normal PowerShell module `.psm1` file. Composite resource still contain a .psd1 as a manifest, but that simply points to the `.schema.psm1`. 


In the example below, the resource module is called CompositeModule, which is the top-level folder. Under that folder is the CompositeModule.psd1 file, which is the module manifest for the composite module. At the root of the CompositeModule folder is a directory called DSCResources. If you have written DSC resources before, this folder will look familiar. This is the directory that contains all the actual DSC resources and code responsible for making the DSC configuration work. Each composite resource you create will exist under this folder. In the example shown above, there is only one composite resource with the name CompositeResource. Inside that directory are two files: CompositeResource.psd1 and CompositeResource.schema.psm1. CompositeResource.psd1 is the manifest for the composite resource, and the CompositeResource.schema.psm1 file is where all the code goes for your composite resource.


* CompositeModule
    * CompositeModule.psd1
    * DSCResources
        * CompositeResource
            * CompositeResource.psd1
            * CompositeResource.schema.psm1





### DSC Without a Composite Resource


Now that you have an understanding of what makes up a composite resource, let’s take a look at what a normal DSC configuration looks like. For this example, I have a web server baseline configuration. It uses the built-in DSC module, PSDesiredStateConfiguration, and a custom DSC resource module, xWebAdministration. Since this configuration is a baseline, it needs to be applied to every web server in the environment. However, I have different types of web servers, so this section of code is repeated over and over again in several separate configurations. Just like when writing PowerShell functions or modules, you should condense repeated code if possible, and that's what a composite resource allows us to do.


``` powershell
configuration WebServerBaseline
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    node localhost
    {
        WindowsFeature WebServer
        {
           Ensure = "Present"
           Name   = "web-server"
        }

        WindowsFeature WebMgmtTools
        {
           Ensure = "Present"
           Name   = "Web-Mgmt-Tools"
        }

        WindowsFeature NETNonHTTPActiv
        {
           Ensure = "Present"
           Name   = "NET-Non-HTTP-Activ"
        }

        File Globomantics
        {
            Ensure          = "Present"
            DestinationPath = "$env:systemdrive"+"\Globomantics"
            Type            = "Directory"
        }

        xWebAppPool GlobomanticsAppPool
        {
            Name = 'Globomantics'
            Ensure = 'Present'
            ManagedRuntimeVersion = 'v4.0'
            IdleTimeoutAction = 'Terminate'
            cpuAction = 'ThrottleUnderLoad'
            autoStart = $true
            restartRequestsLimit = 0
            enable32bitApponWin64 = $false
        }
    }
}
```


### Creating Composite Resources


At this point, we have a baseline configuration we want to condense—that's the problem we're trying to solve with a composite resource. So we have the configuration code, but how do we create a composite resource? Luckily, someone has already solved that problem by creating a helper function that generates the composite resource for you. The helper function can be found on GitHub, and it's called [New-DscCompositeResource](https://github.com/PowerShellOrg/DSC/blob/master/Tooling/DscDevelopment/New-DscCompositeResource.ps1). After you look at the code, you'll notice several parameters, but the important ones are -Path, -ModuleName, and -ResourceName. All are self explanatory, but make sure you specify a $env:psmodulepath for the path so the resource can be used.


_Be sure to load the helper function New-DscCompositeResource in to memory before running the below code_


```powershell
$splat = @{
    Path = ($env:PSModulePath -split ';')[1]
    ModuleName = 'WebServerComposite'
    ResourceName = 'WebServerBaseline'
    Author = 'Josh Duffney'
    Company = 'duffneyio'
}

New-DscCompositeResource @splat
```


After running the code above, you should see the same folder structure as shown below in the tree output screenshot.


![tree](/images/posts/UsingDscCompositeResources/tree.png "tree")


You've now got a composite resource, but it won't do anything because we've not added any logic into the composite resources themselves. The composite resource I created for the web server baseline is called WebServerBaseline. To update that resource, I have to edit the WebServerBaseline.schema.psm1 file. When you open it, the code should look like the configuration shown below.


```powershell
Configuration WebServerBaseline
{
}
```


At the moment, it's an empty configuration called WebServerBaseline. Since we already have the DSC code required for this composite, we can simply copy and paste it in. However, there is one change we have to make to the DSC configuration before it can be used in this composite resource. In order for it to work, we have to remove the node block from the configuration. If we don't, we'll get an error when trying to compile the MOF.

![nodeblockerror](/images/posts/UsingDscCompositeResources/nodeblockerror.png "nodeblockerror")


After removing the node block, the WebServerBaseline.schema.psm1 file should look exactly like the code snippet below.

```powershell
configuration WebServerBaseline
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

        WindowsFeature WebServer
        {
           Ensure = "Present"
           Name   = "web-server"
        }

        WindowsFeature WebMgmtTools
        {
           Ensure = "Present"
           Name   = "Web-Mgmt-Tools"
        }

        WindowsFeature NETNonHTTPActiv
        {
           Ensure = "Present"
           Name   = "NET-Non-HTTP-Activ"
        }

        File Globomantics
        {
            Ensure          = "Present"
            DestinationPath = "$env:systemdrive"+"\Globomantics"
            Type            = "Directory"
        }

        xWebAppPool GlobomanticsAppPool
        {
            Name = 'Globomantics'
            Ensure = 'Present'
            ManagedRuntimeVersion = 'v4.0'
            IdleTimeoutAction = 'Terminate'
            cpuAction = 'ThrottleUnderLoad'
            autoStart = $true
            restartRequestsLimit = 0
            enable32bitApponWin64 = $false
        }

}
```


### Using Composite Resources


Now that we've updated the WebServerBaseline composite resource, it's now time to write a new DSC configuration that uses that composite resource. For this example, I'll name the new configuration UsingAComposite. The first thing you should do is import the composite module. You do that the same way as you would a normal DSC resource module with the Import-DscResource cmdlet. Right after the Import-DscResource cmdlet, create a node block. I'll just specify local host for my node. Inside the node block is where you declare the composite resource you want to use. In our case, it is WebServerBaseline. Now the next part might throw you off a bit. Inside the WebServerBaseline resource, I do not define any properties. I'll get to why in a minute, but if you take a look at the syntax for the WebServerBaseline resource `Get-DscResource webserverbaseline -Syntax`, you'll notice there are only two options: DependsOn and PsDscRunAsCredential. Both of those are optional, and I don't need to specify them in my configuration; it will work without them. Notice that the configuration is only 10 lines now, not 45?


![syntax](/images/posts/UsingDscCompositeResources/syntax.png "syntax")


```powershell
configuration UsingAComposite
{
    Import-DscResource -ModuleName WebServerComposite
    
    node localhost
    {
        WebServerBaseline Test {
        }
    }
}
```


The next thing to do is to apply the configuration to make sure it executes properly. To do that, you must load the configuration into memory, generate the MOF document, and then apply the configuration. For this example, I'll just use Push mode and issue a Start-DscConfiguration command. I have the UsingAComposite.ps1 file saved on my target machine, so I can just dot source it in if I have the configuration open in vscode, or I can just load it into memory there. Once the configuration is loaded, I can generate the MOF file by calling the configuration. I specified the outputpath parameter because I wanted to specify the directory the MOF would end up in. After that, apply the configuration to your target server. As I mentioned, I’ll do this with the `Start-DscConfiguration` cmdlet.


```powershell
. .\UsingAComposite.ps1
UsingAComposite -OutputPath C:\DSC
Start-DscConfiguration -Path C:\DSC -Wait -Verbose
```


![DscVerbose](/images/posts/UsingDscCompositeResources/DscVerbose.png "DscVerbose")


### Adding Properties to a Composite Resource


Typically, DSC resources have at least one mandatory property, but the WebServerBaseline composite resource we wrote doesn't. The reason for that is I didn't include any mandatory parameters in the composite configuration when I updated the WebServerBaseline.schema.psm1 file. Parameters are how you create both optional and mandatory properties for your composite resources. In order for us to create a mandatory property, we'll have to update the WebServerBaseline.schema.psm1 file with a parameter. As an example, let's say Globomantics isn't the only possible app pool name for a web server baseline. Therefore, we want to make that a value we can input as a parameter, but we also want to make it mandatory because the configuration will fail without it. In order to do that, we simply add a mandatory parameter to the WebServerBaseline.schema.psm1 file called $AppPoolName.


```powershell
configuration WebServerBaseline
{
    param
    (
        [Parameter(Mandatory)]
        [string]$AppPoolName
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

        WindowsFeature WebServer
        {
           Ensure = "Present"
           Name   = "web-server"
        }

        WindowsFeature WebMgmtTools
        {
           Ensure = "Present"
           Name   = "Web-Mgmt-Tools"
        }

        WindowsFeature NETNonHTTPActiv
        {
           Ensure = "Present"
           Name   = "NET-Non-HTTP-Activ"
        }

        File Globomantics
        {
            Ensure          = "Present"
            DestinationPath = "$env:systemdrive"+"\Globomantics"
            Type            = "Directory"
        }

        xWebAppPool AppPool
        {
            Name = $AppPoolName
            Ensure = 'Present'
            ManagedRuntimeVersion = 'v4.0'
            IdleTimeoutAction = 'Terminate'
            cpuAction = 'ThrottleUnderLoad'
            autoStart = $true
            restartRequestsLimit = 0
            enable32bitApponWin64 = $false
        }

}
```


Now, when I run `Get-DscResource webserverbaseline -Syntax`, I see a new property called AppPoolName.


![appPoolParam](/images/posts/UsingDscCompositeResources/appPoolParam.png "appPoolParam")


Because we updated the composite resource, we of course have to update our DSC configuration that uses that composite resource:


```powershell
configuration UsingAComposite
{
    Import-DscResource -ModuleName WebServerComposite
    
    node localhost
    {
        WebServerBaseline Test {
            AppPoolName = 'AnyAppPoolName'
        }
    }
}
```


And lastly, if we want to apply this new configuration, we'll have to re-load the configuration into memory, generate a MOF document, and then apply the configuration. The only change should be to add a new app pool with the name of AnyAppPoolName.


```powershell
. .\UsingAComposite.ps1
UsingAComposite -OutputPath c:\DSC
Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force
```

To check if the app pool got created, import the WebAdministration module and get the contents of IIS:\AppPools:


```powershell
Import-Module WebAdministration;Get-ChildItem -Path IIS:\AppPools
```

![appPools](/images/posts/UsingDscCompositeResources/appPools.png "appPools")

### Summary


In the end it is up to you to decide if you want to use DSC composite resources or not. They have their advantages as you've seen in this post, but they also have a disadvantage. Which is another set of code in this case a composite PowerShell module that needs deployed to all your target nodes.