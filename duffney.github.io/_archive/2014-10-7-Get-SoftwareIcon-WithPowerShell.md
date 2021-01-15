---
layout: post
title: Get Software Icon from an .exe with PowerShell
comments: true
tags: [PowerShell]
modified: 2015-10-7 8:00:00
date: 2015-10-7 8:00:00
---
#### Applies to: Windows PowerShell 3.0+

There are a few software applications out there that can extract the .ico image from an executable. However, why would you download and install software for something PowerShell can do for you. This fucntion [Get-Icon](https://github.com/Duffney/PowerShell/blob/master/FileSystems/Get-Icon.ps1) will do exactly what the name leads you to believe, which is getting a .ico file from a .exe file. It will also name the .ico the same name as the .exe, just with a different file extension of course. 
I've used this function over 100 times to extract an .ico file from an .exe so I had a nice Icon to attach to an application with in SCCM.

To use this function simply copy the code and save it as Get-Icon.ps1 on your computer. Then open and run it with PowerShell or PowerShell ISE, since this is an advanced function using the CmdletBinding command it will act as a cmdlet. After running the function you'll notice that Get-Icon shows up when you enter help *icon*. An example of how to use the fucntion is seen below. I've copied the Visual Studio Code .exe from C:\Program Files (x86)\Microsoft VS Code to C:\temp\exe.

{% highlight powershell %}
Get-Icon -folder 'C:\temp\exe'
{% endhighlight %}

![vscodeIcon](/images/posts/2014-10-7/vscodeIcon.png "vscodeIcon")