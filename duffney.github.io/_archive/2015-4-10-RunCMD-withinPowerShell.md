---
layout: post
title: Run CMD Commands within a PowerShell Script
comments: true
tags: [PowerShell, CMD]
modified: 2015-4-10 8:00:00
date: 2015-4-10 8:00:00
---
#### Applies to: Windows PowerShell 2.0+


Sometimes when you enter commands into PowerShell they don't execute the same way as they would in the command prompt. I ran into this issue with an uninstall string for a security software called Cylance Protect. The uninstall string looks like this:

{% highlight powershell %}
msiexec /Lvx* c:\Temp\MsiUnInstall.log /x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /qn
{% endhighlight %}

When I executed it within the command prompt it ran as expected, however when executed in PowerShell it pulled up the msi info page. The way I resolved this was by using cmd C\ followed by my uninstall command. The below code demonstrates this. Long story short use cmd /C "Command" to run cmd commands inside a PowerShell script.

### Run CMD commands in PowerShell

{% highlight powershell %}
cmd /c "msiexec /Lvx* c:\Temp\MsiUnInstall.log /x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /qn"
{% endhighlight %}