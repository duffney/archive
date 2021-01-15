---
layout: post
title:  "Using Module Versions with Invoke-DscResource"
date:   2017-09-02 09:02:00
comments: true
tags: [PowerShell, Dsc, DesiredStatConfiguration, modules, versions, moduleversion, Invoke-DscResource, ModuleSpecification, module, specification, version]
modified: 2017-09-02
---

Invoke-DscResource is a cmdlet available in PowerShell version 5 and above. It allows you to run a Dsc resource method without having to generate a mof document or even write a configuration document. In this blog post you'll learn how to use a ModuleSpecification to tell the cmdlet which version of a resource module to use. Why would you need to do that? By default, the cmdlet will use the latest version of the resource called which might not be what you want. Knowing how to specify the version will help you avoid unexpected behavior. Furthermore not specifying the module version means you have to ensure only one version exists on the target node. Which would also means you can't take advantage of PowerShell's multiple module version support in PowerShell version 5 and above.


### Table of Contents
* TOC
{:toc}

### Invoke-DscResource without a Version

Before I dive into the ModuleSpecification let's take a look at what using Invoke-DscResource looks like. For this first example, I'll be using Invoke-DscResource to test whether or not a file exists by using the built in Dsc resource File which is a part of the PSDesiredStateConfiguration module. The Invoke-DscResource has several parameters the first shown here is Name. The Name parameter is the name of the resource you want to invoke in this case it's called File. Next is the method each Dsc resource has three methods Get, Set, and Test. As I mentioned I simply want to test if the file exists. Assuming you don't have this file on your machine the results should look like the below screenshot InDesiredState should result with False. 

_If you get an access denied error, open your PowerShell editor or prompt with Admin permissions_

``` powershell
Invoke-DscResource -Name File -Method test -ModuleName PSDesiredStateConfiguration`
 -Property @{DestinationPath='C:\temp\InvokeDscResource.ps1';Ensure='Present'}
```

![FileResourceTestMethod](/images/posts/UsingModuleVersionsInvokeDscResource/FileResourceTestMethod.png "FileResourceTestMethod")


### Same Module Multiple Versions Error

As I said in the introduction, when you don't declare the module version you cannot have multiple versions of the same module on a node \ system. To demonstrate that let's take a look at what happens when I try to use Invoke-DscResource with the xGroup resource test method when two versions of that module exist on my machine. Below is a screenshot proving I have version 6.0.0.0 and 6.4.0.0 of the XPSDesiredStateConfiguration module. This is the module that xGroup belongs to.


![2versions](/images/posts/UsingModuleVersionsInvokeDscResource/2versions.png "2versions")

In example below, I'm using Invoke-DscResource to test if the group Administrators exists on the machine. The name of the resource is xGroup, I'll be using the Test method. The module name is xPSDesiredStateConfiguration and the properties I'm using from the resource are GroupName and Ensure to Test if the Administrators group is present. Now, watch what happens when I try to use Invoke-DscResource. 


``` powershell
Invoke-DscResource -Name xGroup -Method test -ModuleName xPSDesiredStateConfiguration `
-Property @{GroupName='Administrators';Ensure='Present'}
```


![resourceNotFound](/images/posts/UsingModuleVersionsInvokeDscResource/resourceNotFound.gif "resourceNotFound")


Instead of getting the InDesiredState object back we get an error message saying `Invoke-DscResource: Resource xGroup was not found`. Which we known isn't true because we verified the modules exists. The problem is Invoke-DscResource doesn't know which of the two test methods to run. Does it run the Test method from version 6.0.0.0 or 6.4.0.0? You have two solutions to this problem; option one is to remove one of the modules. If you like that option read no more, but if you don't like that option you can add a ModuleSpecification to the ModuleName parameter and declare which module version to use.


### Using a ModuleSpecification

The parameter ModuleName accepts a type called `ModuleSpecification` and you've already been using it. Just not in a way that defines a module version. If you'd like to read more about the ModuleSpecification class here is a link to the [msdn documentation](https://msdn.microsoft.com/en-us/library/microsoft.powershell.commands.modulespecification(v=vs.85).aspx). To use the parameter in a way that allows you to define a version number you have to create a hash table. One property will be ModuleName and the other will be ModuleVersion. The values of these two properties are fairly obvious. One is the name of the Dsc resource module and the other is the version of that module. 

``` powershell
$ModuleSpecification = @{ModuleName='xPSDesiredStateConfiguration';ModuleVersion='6.4.0.0 '}
```

When passing the hash table to the Invoke-DscResource cmdlet you can store it in a variable as I've done above or at the cmd line. It gets a little long that way so I put some ticks in there to span multiple lines. It will run either way, but now watch what happens when I run the cmdlet with the module version specified.

``` powershell
Invoke-DscResource -Name xGroup -Method test `
-ModuleName @{ModuleName='xPSDesiredStateConfiguration';ModuleVersion='6.4.0.0'} `
-Property @{GroupName='Administrators';Ensure='Present'}
```


![moduleSpecification](/images/posts/UsingModuleVersionsInvokeDscResource/moduleSpecification.gif "moduleSpecification")