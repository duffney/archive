---
layout: post
title: Create Scheduled Tasks with Secure Passwords
comments: true
tags: [PowerShell, ScheduledTask, Passwords, Secure]
modified: 2016-6-22 8:00:00
date: 2016-6-22 8:00:00
---
#### Applies to: Windows PowerShell 3.0,4.0,5.0

While writing the DSC configuration for some Jenkins slaves, I discovered the Register-ScheduledTask cmdlet only accepts string variables. 
This forced me to store my service account password as clear text, which made me cringe. I knew there had to be a better way, even if the cmdlet
did not allow a credential object to be passed to it. In this post you'll learn how to extract the password from a PS Credential object.
I'll store those properties in variables and then provide them to the Register-ScheduledTask cmdlet.

### Create the Action

The below section of code creates the trigger for the ScheduledTask, I'll use this later when I create the ScheduledTask. It simply calls the script named
PowerShellscript.ps1 from C:\script and execute it. 

{% highlight powershell %}
$Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShellv1.0\powershell.exe' -Argument "-NonInteractive -NoLogo `
-NoProfile -File 'C:\scripts\PowerShellscript.ps1'" -WorkingDirectory "C:\scripts"
{% endhighlight %}


### Define the Trigger

Next I'm defining the trigger and storing it into a variable called $Trigger. I'm having it run upon startup, but delaying it 5 minutes
after the machine is online.

{% highlight powershell %}
$Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup
{% endhighlight %}

### Configure the Settings

This was the trickiest part, trying to determine which parameters matched the GUI settings. Below I'm telling the task to; not stop when the idle ends, 
setting the restart interval to 1 minute, setting the reset count to 10 tries, starting when available, and removing the idle timeout option. $Settings.ExecutionTimeLimit = "PT0S"
is removing the idle timeout, that took a bit to figure out. 

{% highlight powershell %}
$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"
{% endhighlight %}

### New PS Credential Object

Now I have to create a PS Credential object that I can extract out the password from. This was the fun part as I hadn't dealt with this to much before.
Mainly because most cmdlets allow for encrypted credentials to be passed to them... at any rate. Lines 1-3 create the PS credential object and line 4 creates
a variable with the password in it. It's a string, but at least it's not stored in the script. Perhaps I should of titled the post secureish? If you don't like the
read-host prompt, you can turn this code into an advanced function and require a credential parameter. Once I finish mine, I'll be sure to link it here.

{% highlight powershell %}
$SecurePassword = $password = Read-Host -AsSecureString
$UserName = "svc_account"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 
{% endhighlight %}

### Register the ScheduledTask

Lastly I have to create the ScheduledTask and then register it. If you just create it, it will only be stored in memory. Registering it is what adds it to the task
scheduler. 

{% highlight powershell %}
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
$Task | Register-ScheduledTask -TaskName 'ScheduledTaskName' -User "svc_account" -Password $Password
{% endhighlight %}

### Complete script


{% highlight powershell %}
$Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShellv1.0\powershell.exe' -Argument "-NonInteractive -NoLogo `
-NoProfile -File 'C:\scripts\PowerShellscript.ps1'" -WorkingDirectory "C:\scripts"

$Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup

$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"

$SecurePassword = $password = Read-Host -AsSecureString
$UserName = "svc_account"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
$Task | Register-ScheduledTask -TaskName 'ScheduledTaskName' -User "svc_account" -Password $Password
{% endhighlight %}


### Sources
[How To Build Scheduled Tasks In PowerShell](http://www.tomsitpro.com/articles/powershell-build-scheduled-tasks,2-832.html)


[Working with Passwords, Secure Strings and Credentials in Windows PowerShell](https://social.technet.microsoft.com/wiki/contents/articles/4546.working-with-passwords-secure-strings-and-credentials-in-windows-powershell.aspx)


[Scheduled Task via Powershell](http://powershell.com/cs/forums/t/20758.aspx)