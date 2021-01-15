---
layout: post
title:  "Create Jenkins JNLP Scheduled Tasks with PowerShell"
date:   2016-9-5 09:02:00
comments: true
tags: [PowerShell, Jenkins, JNLP]
modified: 2016-9-5
---


In this post, you will learn how to create a scheduled task with PowerShell that connects a Jenkins slave to the master with
[JNLP](https://docs.oracle.com/javase/tutorial/deployment/deploymentInDepth/jnlp.html). This is just one of several ways to connect
a Jenkins slave to a Jenkins master, but I've found it to be the most reliable method. Before I begin I am assuming a few things.
I'm assuming you have already added the node to Jenkins and that you've copied over the slave.jar to some work directory on the new
slave node. You will also need to install Java on the slave node before continuing. To learn more about that process be sure to read [Lanch Java Web Start slave agent via Windows Scheduler](https://wiki.jenkins-ci.org/display/JENKINS/Launch+Java+Web+Start+slave+agent+via+Windows+Scheduler)
on the Jenkins Wiki.

### Create the Action

I'll start by creating the actions for the scheduled task and storing it into a variable $Actions. I'm using a technique called splatting
to provide the execute, argument, and workdirectory parameters to New-ScheduledTaskAction. Execute providing the location of the java.exe,
argument specifies the Java command that connects the slave to the master and workdirectory is the location of the slave.jar file I mentioned
previously.

{% highlight PowerShell %}
$ActionParams = @{
    Execute = 'C:\Program Files\Java\jdk1.8.0_102\bin\java.exe'
    Argument = '-jar slave.jar -jnlpUrl http://master/computer/Slave/slave-agent.jnlp -secret 37e93023c74ae1529db72342d511e508c5ec929138484c7b358be29b1196c7ed'
    WorkingDirectory = 'C:\Checkouts'
}

$Action = New-ScheduledTaskAction @ActionParams
{% endhighlight %}

### Defining the Trigger

Next, I am defining the trigger and storing that in a variable called $Trigger. You'll want the trigger to be upon start up, but I also
discovered that adding a random delay within 5 minutes helps ensure the scheduled tasks connects to the master. I ran into issues where
the scheduled task would start up before the environment variables were loaded. This caused Git issues when running jobs that relied on
those environment variables.

{% highlight PowerShell %}
$Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup
{% endhighlight %}

### Configure the Scheduled Tasks Settings

With the Action and Trigger defined, it's now time to configure the settings and store those into another variable called $Settings.
I've chosen to turn off the stop on idle, set the restart interval to 1 minute, the restart count to 10 and start the scheduled task
when available. Lastly I'm unchecking the box "Stop the task if it runs longer than:" with $Settings.ExecutionTimeLimit = "PT05".
This is a very important setting because you never want this task to end.

{% highlight PowerShell %}
$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"
{% endhighlight %}

### Create and Register the Scheduled Tasks

Lastly, I am creating the scheduled task and then registering it. $Task will contain the entire scheduled task. It contains the actions,
triggers and settings. After creating $Task, I'm piping it to Register-ScheduledTask. If you do not register the scheduled task, it will
disappear when you exit the PowerShell session. Because I want to run this scheduled task to run as a service account I need to specify
the user and password parameters. Then provide the username and password for the service account. If you don't like storing passwords
in clear text, check out [Create Scheduled Tasks with Secure Passwords](http://duffney.io/Create-ScheduledTasks-SecurePassword).

{% highlight PowerShell %}
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
$Task | Register-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -User 'svc_jenkins' -Password 'P@ssw0rd'
{% endhighlight %}

### Starting the Scheduled Task

You have two options for starting the scheduled task. Option 1, is to just restart the computer and let the scheduled task start. Option 2,
is use the Start-ScheduledTask cmdlet. There is a caveat to Start-ScheduledTask, you must run the cmdlet as the user who is specified
with Register-ScheduledTask.

{% highlight PowerShell %}
Restart-Computer -ComputerName slave -Force

Invoke-Command -ComputerName slave -ScriptBlock {Start-ScheduledTask 'Jenkins JNLP Slave Agent'}  -Credential winops\svc_jenkins
{% endhighlight %}

### Complete Script

{% highlight PowerShell %}
$ActionParams = @{
    Execute = 'C:\Program Files\Java\jdk1.8.0_102\bin\java.exe'
    Argument = '-jar slave.jar -jnlpUrl http://master/computer/Slave/slave-agent.jnlp -secret 37e93023c74ae1529db72342d511e508c5ec929138484c7b358be29b1196c7ed'
    WorkingDirectory = 'C:\Checkouts'
}

$Action = New-ScheduledTaskAction @ActionParams
$Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup
$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings

$Task | Register-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -User 'svc_jenkins' -Password 'P@ssw0rd'

Invoke-Command -ComputerName slave -ScriptBlock {Start-ScheduledTask 'Jenkins JNLP Slave Agent'}  -Credential winops\svc_jenkins
{% endhighlight %}
