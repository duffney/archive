---
layout: post
title:  "Getting Started with Invoke-Build"
date:   2017-09-19 09:02:00
comments: true
tags: [PowerShell, Modules, ContinuousIntegration, CI, Continuous, Integration, Invoke-Build, InvokeBuild]
modified: 2017-09-19
---
### Table of Contents
* TOC
{:toc}

### What is InvokeBuild?

Invoke-Build is a build automation tool written in PowerShell. What does that mean? Well, just like anything written in PowerShell the purpose of it is to automate something and in this case it's to automate the building of software artifacts. What does building software have to do with PowerShell development? Well, if you've gotten into building your own PowerShell modules and publishing them to a file share, internal feed, or PSGallery you'll see the value in this tool. Before we dive into how to use Invoke-Build, let's take a look at what you might automate with Invoke-Build.

As I mentioned Invoke-Build is used to automate the building of artifacts for software. In the case of PowerShell development that artifact means a .zip file or .nuget file containing a PowerShell module. Invoke-Build is used to automate the creation of that artifact and the publishing of that artifact to some destination be it the PSGallery or an internal feed. Before you can automate something you have to understand the manual process, so let's take a look at a typical workflow for creating a PowerShell module artifact.

### PowerShell Module Development Workflow

PowerShell module development by no means has a _standard process_ with that said I'll explain my workflow as it relates to the building of a module artifact with the intent of distributing the module to other systems besides my client computer. This example workflow starts after you have created or made a change to a PowerShell module and you now wish to package it up and distribute it. I won't be covering PowerShell module design patterns in this post. The process I follow for creating a module artifact goes something like this; install dependencies, analyze code with a linting tool `PSScriptAnalyzer`, execute Pester tests, update the module manifest with new functions and increase module version, generate an artifact, and publish the artifact. The rest of this blog post will cover how you use Invoke-Build to automate this workflow.

*Workflow*
1. Install Dependencies
1. Analyze Code
2. Test Code
3. Update Module Manifest
4. Archive & Publish New Artifact

### Creating The InvokeBuild Script

For this example I'm going to be creating build scripts for a class based resource I wrote called TeamCityAgentDSC. I got much of the logic from the mof based DSC resource [teamcity-agent-DSC](https://github.com/girwin/teamcity-agent-dsc). The first thing I have to do is create the build script and after taking a quick look at the [InvokeBuild Script Tutorial](https://github.com/nightroman/Invoke-Build/wiki/Script-Tutorial) I learned that you have to name the build script `.build.ps1`. This is similar to the naming convention of Pester tests with the `.Tests.ps1`. I've noticed that a lot of people tend to use the name convention `$ModuleName.build.ps1`. So, for this example my build script will be `TeamCityAgentDSC.build.ps1`. I'll create it at the root of the git repository as shown below.

![InvokeBuildScript](/images/posts/GettingStartedWithInvokeBuild/InvokeBuildScript.png "InvokeBuildScript")

### Creating the Install Dependencies InvokeBuild Task

Now that we have the build script it is time to start creating some tasks the fist item in our workflow is to install the dependencies. What are those dependencies? Well, that depends on your module but for the TeamCityAgentDsc the only dependency I have at this point is the Pester module to run my unit tests. InvokeBuild has a DSL (Domain Specific Language) that allows you to write what it calls tasks. These tasks are what carry out the actions you wish to take. You can think of these tasks as functions, they need to be defined in the build script and called out somewhere in the file. The example below shows how you'd define a task called InstallDependencies. The task uses the Install-Module cmdlet to obtain the Pester module. Notice that I have a task that defines the InstallDependencies task and another task command that calls the InstallDependencies. Again think of the tasks as functions one is defining the function and the other is executing or calling the function. You can call multiple tasks at once which you'll see later.


```powershell
task InstallDependencies

task InstallDependencies {
    Install-Module Pester -Force
}
```

To run the build script just run the cmdlet `Invoke-Build` in the same directory the build script is in or use the File parameter of the Invoke-Build cmdlet.

```powershell
Invoke-Build
```


![InstallDependencies](/images/posts/GettingStartedWithInvokeBuild/InstallDependencies.png "InstallDependencies")

### Adding Linting with PSScriptAnalyzer

The next step in the module development process is to add linting. If you're not familiar with what linting is, it is the process of running a program that analyzes code for potential errors and best practice patterns. The most popular lining tool for PowerShell is PSScriptAnalyzer. PSScriptAnalyzer is a PowerShell module that is available on the PSGallery and with that said we just discovered another dependency so before we move on to how to add linting to the process let's update the InstallDependencies task to include PSScriptAnalyzer.

```powershell
task InstallDependencies {
    Install-Module Pester -Force
    Install-Module PSScriptAnalyzer -Force
}
```

To add linting to the process we need to add another task to our build script. I'll call the task Analyze and inside that task I need to write the code that would invoke the PSScriptAnalyzer tool. The cmdlet for that is `Invoke-ScriptAnalyzer`. If you look at the help for this cmdlet you'll see a lot of parameters. The first and most important is the Path parameter this specifies the location of the script or scripts you want to analyze. In my example I really only care about linting the dsc resource I wrote which is under the DSCClassResources\TeamCityAgent folder in my module. Because the whole point of creating a build script is to run it from anywhere I do not want to hard code the path of the directory in my build script. Luckily, InvokeBuild has a special variable called $BuildRoot, which is the full path to the build directory (place InvokeBuild ran from). Which is exactly what I need, with that variable my path is `"$BuildRoot\DSCClassResources\TeamCityAgent\"`. The next parameter I'll add is Severity. PSScriptAnalyzer has several severity levels, but the only two I care about are Error and Warning. I'll also want to use the Recurse switch parameter because I'm pointing at a directory with multiple scripts. I also want to use the ExcludeRule parameter and exclude the rule PSUseDeclaredVarsMoreThanAssignments because in my codebase I had some future code included but don't want to see the error it generates. Writing that all out on a single line would look awful and for that reason I'll create a hash table and splat the parameters to the Invoke-ScriptAnalyzer cmdlet.

```powershell
task Analyze {
    $scriptAnalyzerParams = @{
        Path = "$BuildRoot\DSCClassResources\TeamCityAgent\"
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }
}
Invoke-ScriptAnalyzer @scriptAnalyzerParams
```

By default the Invoke-ScriptAnalyzer cmdlet does not throw a terminating error. This is a problem for us because if the linting fails we ideally want the build to fail and some error to be thrown. To accomplish that I'll store the results of Invoke-ScriptAnalyzer to a variable and then use an if statement to check the results. PSScriptAnalyzer only outputs what it finds wrong so if the variable we create isn't null we should throw an error. I also chose to output the results and format it as a table if any errors or warnings were found so we could see them in the output.


```powershell
task Analyze {
    $scriptAnalyzerParams = @{
        Path = "$BuildRoot\DSCClassResources\TeamCityAgent\"
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}
```


To test our new build tasks we can use the Invoke-Build cmdlet and specify the task with the `Task` parameter.


```powershell
Invoke-Build -Task Analyze
```


![InvokeBuildTaskAnalyze](/images/posts/GettingStartedWithInvokeBuild/InvokeBuildTaskAnalyze.png "InvokeBuildTaskAnalyze")


### Testing the Code with Pester

So far we've created a task that setups the environment by installing dependencies and another task that lint tests the code with PSScriptAnalyzer. It's now time to add in some unit tests and to do that we'll use Pester. Learning to test your code is a discipline itself so I won't be covering any of that here. I'm assuming you've already written some unit tests and you want to add them to your release process. If you're new to testing your PowerShell code I highly recommend [The Pester Book](https://leanpub.com/pesterbook) by Adam Bertram. 


When I created the InstallDependencies task I knew the Pester module was a dependency so I don't have to add that. I do however need to create yet another task inside my build script. I'll name it Test and inside the task I need to use the `Invoke-Pester` cmdlet to run all my unit tests. Just like InvokeBuild Pester looks for specific file names. In the case of Pester it looks for `.tests.ps1` files. Because of that I can run Pester from the root of my module and it will invoke the tests. To determine if the tests failed or passed I put the results of Invoke-Pester into a variable called $testResults and then assert whether or not the FailedCount is equal to zero if the FailedCount is greater than zero I fail the build.


```powershell
task Test {
    $invokePesterParams = @{
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    $numberFails = $testResults.FailedCount
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
}
```


Again I can invoke just the Test task by specifying the Task parameter.

```powershell
Invoke-Build -Task Test
```


![InvokeBuildTest](/images/posts/GettingStartedWithInvokeBuild/InvokeBuildTest.gif "InvokeBuildTest")


### Updating the Module Manifest

At this point we have a module that is ready to be distributed, but before we do that it's a good idea to increase the version number on the module manifest so we can keep track of what changes happened in what versions. As you might of already guessed we need to create another task that handles the updating of the module manifest. I won't dive into the code for this task because it involves a fair about of regex. The task I'll use simply gets the current module number from the module manifest and creates a version object that is updated by one each time the build is ran. If you want to learn more about regex you can check out my Pluralsight course [Introduction to Regular Expression](https://app.pluralsight.com/library/courses/regular-expression-introduction/table-of-contents). 


```powershell
task UpdateVersion {
    try 
    {
        $moduleManifestFile = ((($BuildFile -split '\\')[-1] -split '\.')[0]+'.psd1')
        $manifestContent = Get-Content $moduleManifestFile -Raw
        [version]$version = [regex]::matches($manifestContent,"ModuleVersion\s=\s\'(?<version>(\d+\.)?(\d+\.)?(\*|\d+))") | ForEach-Object {$_.groups['version'].value}
        $newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build + 1)

        $replacements = @{
            "ModuleVersion = '.*'" = "ModuleVersion = '$newVersion'"            
        }

        $replacements.GetEnumerator() | ForEach-Object {
            $manifestContent = $manifestContent -replace $_.Key,$_.Value
        }
        
        $manifestContent | Set-Content -Path "$BuildRoot\$moduleManifestFile"
    }
    catch
    {
        Write-Error -Message $_.Exception.Message
        $host.SetShouldExit($LastExitCode)
    }
}
```

### Generating an Artifact

The final task in the module development workflow is to generate an artifact. There are several different types of artifacts you can generate the most common are .zip and .nuget. For this example I'll stick with a simple .zip file that could be used to distribute the module. A new cmdlet called `Compress-Archive` was introduced in PowerShell version 5, which makes creating a .zip file super simple. But, where do we place that artifact? Great question, and of course the answer to that question is _it depends_. Sometimes you'll want to put it on a file share or perhaps you want to upload it to artifactory or the PSGallery. All of this is totally possible, but for this example I'll keep it simple and store it locally on the system running the build script. Build scripts are of course meant to be ran from some build system like TeamCity or Jenkins so keeping that in mind I'll just create a folder called artifacts at the root of the module directory. This begs to ask the question how am I going to create the folder and how do I keep it _clean_ of old artifacts? The answer to that one is to create a clean task that takes care of creating the folder if it doesn't exist and removes all the contents.


```powershell
task Clean {
    $Artifacts = "$BuildRoot\Artifacts"
    
    if (Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force
}
```


Add the clean task to the build script then run the clean task so it creates the directory.


```powershell
Invoke-Build -Task Clean
```


With the artifact directory created, we can now focus on the archive task. Because I like to keep things as dynamic as possible I'll use the special variables discovered previously to populate two variables $Artifacts and $ModuleName. $Artifacts is the path to the new folder and $ModuleName is the name of the module we're building. I'll use these variables to name the .zip file. Next, I need to decide what files I want to include in the module artifact. Looking at the directory I don't need the Tests folder, the artifacts folder of course, I also don't need a lot of the files at the root like the read.me, and I certainly don't need to include the build script itself. I do however need the .psd1 at the root, the DSCClassResources folder and the examples folder would be nice as well.


```powershell
task Archive {
    $Artifacts = "$BuildRoot\Artifacts"
    $ModuleName = ($buildroot -split '\\')[-1]
    Compress-Archive  -LiteralPath .\TeamCityAgentDSC.psd1 -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\DSCClassResources -Update -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\Examples -Update -DestinationPath "$Artifacts\$ModuleName.zip"
}
```


With the archive task completed we can now run the clean and archive task together to generate the artifact.


```powershell
Invoke-Build -Task clean,archive
```


I now have a .zip file that can be copied around and placed in the $env:PSModulePath and will get picked up by PowerShell! There is one last thing we need to do and that's to update line one with all the tasks we just created. This way when we use Invoke-Build with no parameters it will run all of the necessary build tasks.


```powershell
task . InstallDependencies, Analyze, Test, UpdateVersion, Clean, Archive
```

Now, if we run invoke build it will run all the defined tasks in the order we specified and are left with a brand new artifact!


![InvokeBuild](/images/posts/GettingStartedWithInvokeBuild/InvokeBuild.png "InvokeBuild")


The lesson here is never stop automating! This blog post doesn't cover everything InvokeBuild can do. I'm positive some of the things I'm doing in this build script can be done better, but it's a start. Feel free to provide feedback in the comments.

_Link to entire build script_
[TeamCityAgentDSC Build Script Gist](https://gist.github.com/Duffney/6c587aee88a26f513fa0f084ce4421ef)

_In a future post I'll be covering how to use InvokeBuild to publish the artifacts to the PSGallery with appveyor, so stay tuned! Happy Automating!_

### Sources

[Hitchhikers Guide to the PowerShell Module Pipeline](https://xainey.github.io/2017/powershell-module-pipeline/)