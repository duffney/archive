---
layout: post
title: Move all Members of an ActiveDirectory Group to being just Members with PowerShell
comments: true
tags: [PowerShell, ActiveDirectory]
modified: 2015-7-27 8:00:00
date: 2015-7-27 8:00:00
---
#### Applies to: Windows PowerShell 3.0+


Recently my team and I discovered an Active Directory group that was causing token bloat within our environment. The reason was due to someone place 246 objects in the members of section of the AD group, when they should have been in the members section. Active Directory Administration tool makes removing them from the member of easy, but add them to the members section first not so easy. To solve this problem I wrote a little function that takes all the "member of" groups puts it into a variable and loops through adding then to the member section. It then, removes the group or object from the member of section. I wrote it as an advanced function \ cmdlet called [Move-ADGroupMembersofToMember](https://github.com/Duffney/PowerShell/blob/master/ActiveDirectory/Move-ADGroupMemberofToMember.ps1).

To use this function, either copy the code and paste into your ISE session or save it as a .ps1 file and load the script into your PowerShell session. This function only has one
parameter called TargetGroup. This is the group that you want to move all the members of to members and remove them from the members of section. Below demonstrates how to use this function.

![moveadgroupmemberof](/images/posts/2015-7-27/moveadgroupmemberof.gif "moveadgroupmemberof")

{% gist 804daede01d58cfa1118 %}

### Acknowledgements

[Spiceworks Community post credit to cduff for helping out](http://community.spiceworks.com/topic/1032967-remove-member-of-from-active-directory-group)

