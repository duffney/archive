---
layout: post
title: Rename Enable and Reset the Local Administrator Account with PowerShell
comments: true
tags: [PowerShell]
modified: 2014-7-3 8:00:00
date: 2014-7-3 8:00:00
---

We all know it's not best practice to leave the local administrator account named administrator, for that reason most of us rename it. So why not save a little time while doing it? Below lists a simple PowerShell script that will rename the account enable it and reset the password. I've gotten a little tricky with the password and added the serial number as part of it. However that can easily be changed to whatever you'd like it to be.

{% highlight PowerShell %}
#-------Enable, Rename, & Reset Local Administrator Password-------#
####################################################################

#Get Service Tag
$servicetag = (gwmi win32_bios).SerialNumber

#Rename Local Admin Account
$admin=[adsi]"WinNT://./Administrator,user" 
$admin.psbase.rename("Ron.Johnson")

#Enables & Sets User Password
invoke-command { net user Ron.Johnson Adm.$servicetag /active:Yes }

########################################################################
#----------------------Creator - Joshua.Duffney------------------------#
#----------------------        Sources         ------------------------#
#Sources
#http://myitforum.com/cs2/blogs/yli628/archive/2010/05/19/mdt-create-a-task-sequence-using-powershell-to-rename-local-administrator-account.aspx
#http://jdhitsolutions.com/blog/2014/04/set-local-user-account-with-powershell/
#https://community.spiceworks.com/topic/493143-trimming-variables-with-powershell?page=1#entry-3306064
#----------------------      Notes              ------------------------#
#must run the following command in SCCM for the script to run
#Powershell.exe -command "Set-ExecutionPolicy RemoteSigned;
{% endhighlight %}

### Acknowledgements
[myitforum](http://myitforum.com/cs2/blogs/yli628/archive/2010/05/19/mdt-create-a-task-sequence-using-powershell-to-rename-local-administrator-account.aspx)


[jdhitsolutions](http://jdhitsolutions.com/blog/2014/04/set-local-user-account-with-powershell/)


[Spiceworks](https://community.spiceworks.com/topic/493143-trimming-variables-with-powershell?page=1#entry-3306064)