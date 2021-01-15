---
layout: post
title: Stale Active Directory Groups
excerpt: "Discover Stale AD Groups with PowerShell"
comments: true
tags: [PowerShell, Active Directory]
modified: 2014-03-03 22:00:00
date: 2014-03-30 22:00:00
---
#### Applies to: Windows PowerShell 3.0, Windows PowerShell 4.0, Windows PowerShell 5.0, ActiveDirectory Module 1.0

Arguably one of the most difficult objects to clean up within Active Directory is groups. Lucky after watching <a href="https://www.microsoftvirtualacademy.com/en-US/training-courses/using-powershell-for-active-directory-8397" target="_blank">Using PowerShell for Active Directory </a>on Microsoft Virtual Academy there was hope! [Ashley McGlone](https://twitter.com/GoateePFE) and [Jason Helmick](https://twitter.com/theJasonHelmick) did a fantastic job on the 7+ hour series.

This is just one more example of how powerful PowerShell is, it gives you visibility into something often forgotten about or ignored because of how hard it is to maintain. The best indicators for a group being stale are as follows; Members, Memberof, and last changed. Ashley wrote the below script to provide this information in a readable format, I simply put that data into an object so that one might be able to parse it a bit easier.


{% gist 597e07ed8394134c013f %}

Now that we have all of our Active Directory groups in an object we can filter on specific attributes. The below line would be your low hanging fruit as far as stale group are concerned. These groups have no members no member ofs and have not been touched in 190 days. When I ran this in my current environment came back with 1,200 results!

Warning! There are most likely some built-in groups in these results, which should not be deleted. Be careful when cleaning up AD.

{% gist ba2d523bc25204e3267a %}

![Out-GridView](/images/posts/StaleADGroupsOGV.PNG)
