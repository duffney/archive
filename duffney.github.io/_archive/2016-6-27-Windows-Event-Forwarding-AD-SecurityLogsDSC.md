---
layout: post
title: Windows Event Forwarding for Active Directory Security Logs with DSC
comments: true
tags: [Hyper-V, DSC, WindowsEventForwarding, ActiveDirectory, Desired State Configuration, SecurityLogs]
modified: 2016-6-27 8:00:00
date: 2016-6-26 8:00:00
---

In this post, I will be teaching you how to configure Windows Event Logs Forwarding for Active Directory Security Logs that are stored on Domain Controllers. This is
a real world example of how to use DSC in your environments and showcases the benefits of using DSC. If you are not currently using some logging system, I highly encourage
you take the lessons learned here and use them to build a simple logging solution. In a [previous post](http://duffney.github.io/Creating-Labs-with-LabBuilder/), I walked
through how to use [LabBuilder](https://github.com/PlagueHO/LabBuilder) to build the lab environment. With the lab ready to go, lets begin!

### Add Collector node to Event Log Readers AD Group

Since Domain Controllers do not have local groups, you must add the collector node to the Event Log Readers AD Group. This allows the system to read the logs on the system. Below is the
command to add it to the group with PowerShell, stay out of the GUIs my friends. There is also a command to verify the membership, issue that cmdlet just to verify it was added. 

{% highlight powershell %}
Set-ADGroup -Add:@{'Member'="CN=COLLECTOR,CN=Computers,DC=WEF,DC=COM"} -Identity:"CN=Event Log Readers,CN=Builtin,DC=WEF,DC=COM" -Server:"DC1.WEF.COM" -Verbose

Get-ADGroupMember -Identity 'Event Log Readers'
{% endhighlight %} 

### Configure Log Access Group Policy

Next you must modify the Log Access for the Domain Controllers security logs. By default they do not allow read access, for semi-obvious reasons. There are a few options here we could use the wecutil utility, but Group Policy
still has it's place and usefulness so that what I've chosen to do. Open the Group Policy Management Console and follow the steps outlined below. Sorry! I know I just said stay out of GUIs...
Sidenote, what the configure log access value is doing is grant the Network Service Account read rights. It's not opening it up for everyone.

1. Open Group Policy Management Console [Start-Process $env:systemdrive:\windows\system32\gpmc.msc]
2. Local the [Default Domain Controllers Policy]
3. Right click Edit
4. Navigate to Computer Management > Preferences > Administrative Template > Windows Component > Event Log Service > Security
5. Double click Configure log access
6. Select Enabled
7. Enter O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20) in the Log Access field
8. Click OK

![configurelogaccess](/images/posts/2016-6-27/configurelogaccess.png "configurelogaccess")

### Enable Auditing on Domain Controllers

If it is not already configured enabling auditing on the Domain Controllers. This way all the changes are track and log to event viewer on the Domain Controllers and then 
forwarded to the collector node. Follow the below steps to enable some auditing.

1. Open Group Policy Management Console [Start-Process $env:systemdrive:\windows\system32\gpmc.msc]
2. Local the [Default Domain Controllers Policy]
3. Right click Edit
4. Navigate to Computer Management > Polices > Windows Settings > Security Settings > Local Polices > Audit Policy
5. Double click Audit account logon events
6. Check Define these policy settings
7. Click Success
8. Repeat steps 5-7 for the following policies; Aduit account management, Audit directory service access, Audit logon events, Audit object access, Audit policy change, 
Audit privilege use.

![adauditing](/images/posts/2016-6-27/adauditing.png "adauditing")

### Restart Domain Controllers

Because the Group Policy that changes the security log access requires a reboot to apply, you'll need to restart all the Domain Controllers. This made my change board
uncomfortable.... :) DO NOT RPD INTO THEM! PowerShell can of course do this better, the below commands will get all of the Domain Controllers within the domain executed and 
reboot them one by one waiting for the first to finish before the second is started.

{% highlight powershell %}
$DCs = (Get-ADDomainController -filter *).Name

$DCs | % {Restart-Computer -ComputerName $_ -Wait -For PowerShell -Force}
{% endhighlight %}

### Deploy xWindowsEventForwarding DSC Configuration to Collector Node

Now the fun begins! Next I'll be deploying the DSC configuration that will create the subscriptions. These subscriptions are what defines what logs to gather from what sources.
There are two options for a collector, collector initiated and source initiated. I'll be setting up a collector initiated subscription. Lucky for me there was a custom
DSC resource for this [xWindowsEventForwarding](https://github.com/PowerShell/xWindowsEventForwarding). Ensure that is available on the collector node before executing the DSC configuration.

While this configuration is simple, it saves a lot of clicking. Also notice line 22, see how I'm gathering all the Domain Configuration names? Not typing them in one
by one is how. Once the configuration is completed, you can view it in the Event Viewer GUI.

{% highlight powershell %}
#Install xWindowsEventForwarding custom DSC resource module
Install-Module xWindowsEventForwarding -Confirm:$false

#Open Event Viewer
Start-Process "c:\windows\system32\eventvwr.msc" -ArgumentList "/s"
{% endhighlight %}

{% gist 58ec33acf0e01dd67861c02d4b651821 %}

![eventviewer](/images/posts/2016-6-27/eventviewer.png "eventviewer")


![forwardedevents](/images/posts/2016-6-27/forwardedevents.png "forwardedevents")


### Troubleshooting

If you do not see any logs being forwarded, it's most likely because the Group Policy did not apply yet. Simply rebooting the Domain Controllers again will fix this issue.
You can see the status of the Event Sources by right clicking the subscription and clicking Runtime Status. Once the Domain Controllers reboot don't forget to right click and retry.

![runtimestatus](/images/posts/2016-6-27/runtimestatus.png "runtimestatus")