---
layout: post
title: Disable ADComputer in Action
comments: true
tags: [PowerShell, ActiveDirectory]
modified: 2015-8-24 8:00:00
date: 2015-8-24 8:00:00
---
#### Applies to: Windows PowerShell 3.0+


Cleaning up Active Directory isn't something every organization does or does well, but it's very important. For semi obvious reasons 
it's best practice to disable computers after X amount of days and is part of any System Administrators job. The script in this blog 
post will help automate the disabling and moving of objects to a specified OU. This task is fairly easy to script out within a simple 
foreach loop or piping get-adcomputer to set-adcomputer. Instead of rewriting a few loops or using a prebuild script, you can use the 
advanced function [Disable-ADComputer](https://github.com/Duffney/PowerShell/blob/master/ActiveDirectory/Disable-ADComputer.ps1) I wrote to disable computers.

Because it's an advanced function it acts and behaves like a normal PowerShell cmdlet. Once you load the function into your PowerShell session you can use get-help to 
learn how to use the function. It allows you to specify a description as well as the disabed OU that you'd like to move the object to. It also allows you to specify the domain
you are wanting to target and the alternate credentials if needed.

![disable-adcomputer](/images/posts/2015-8-24/disable-adcomputer.gif "disable-adcomputer")

### Disable-ADComputer Gist

{% gist dd9efb09e84829ac7126 %}