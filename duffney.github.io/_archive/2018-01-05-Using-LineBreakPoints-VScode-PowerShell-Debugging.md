---
layout: post
title:  "Using Line Breakpoints in VScode to Debug PowerShell"
date:   2018-03-20 09:02:00
comments: true
tags: [PowerShell, visualstudio, visualstudiocode, vscode, debug, debugging, breakpoints, conditional breakpoints, function breakpoints]
modified: 2018-03-20
---

Write-Host messages are not the only way to debug PowerShell code. In this blog post you'll learn how to use the debugger in Visual Studio Code to set line breakpoints. Line breakpoints allows you to pause the code's execution on a specific line. Which makes debugging much easier. I will also show you how to manage breakpoints. You'll learn how to enable, disable, and remove breakpoints. By the end of this blog post you'll be able to debug PowerShell code with Visual Studio Code. For this blog post you'll need two things; [Visual Studio Code](https://code.visualstudio.com/) and the [PowerShell extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell).


* TOC
{:toc}

# Line Breakpoints


Line breakpoints are the simplest and most common break point. So common in fact that when most people say break point they are referring to line breakpoints. A line break point is as the name implies a line in the code where the code should break or pause. You can set line break points a few ways in Visual Studio Code. You can either use your mouse or a keyboard shortcut.


## Setting Line Breakpoints: Mouse


To create a break point with your mouse hover to the left of a line number. You'll notice a dim red circle appear. To create the break point left click the mouse. At that point the dim red circle becomes a vibrant red circle. The break point also appears under breakpoints in the debugger panel. This panel keeps track of every break point. If you do not see this panel right click on the debug icon on the left side of the editor. It is the bug with the crossed out circle.

![linebreakpoint-mouse](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/linebreakpoint-mouse.gif "linebreakpoint-mouse")


## Setting Line Breakpoints: Keyboard F9


Another way to set line breakpoints is to use the keyboard shortcut `F9`. Select the line you want the break point to be on and hit the F9 key. You can remove the break point as well by hitting F9 again on the same line or on other lines with breakpoints. Hitting F9 creates a break point under the breakpoints section of the debugger panel. A keyboard shortcut to open that panel is `Ctrl+Shift+D`


![linebreakpoint-keyboard](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/linebreakpoint-keyboard.gif "linebreakpoint-keyboard")


# Using Line Breakpoints


Visual studio code has two ways to debug. You can use the single file debugger or you can use the work space debugger. The single file debugger is the default when you haven't setup a work space, but what is a work space? A work space is a set of files that customize your editor. These customization can be theme colors, formatting rules, and of course debugging settings. You can learn more about work spaces [here](https://code.visualstudio.com/docs/getstarted/settings).

To determine which of the two debugging option you're using by looking at the top of the debugger panel. If it says No Configuration next to the green start button, you're using the single file debugger. If it says anything other than No Configuration, then you're using the work space debugger. The work space debugger gives you several options for debugging. These settings change the way the debugger interacts with your code. To learn more about work space debugging checkout [Debugging PowerShell script in Visual Studio Code – Part 2](https://blogs.technet.microsoft.com/heyscriptingguy/2017/02/13/debugging-powershell-script-in-visual-studio-code-part-2/).

_You Can NOT debug unsaved files_


### Single File Debugger


![singlefiledebugger](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/singlefiledebugger.png "singlefiledebugger")


### Workspace Debugger

![workspacedebugger](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/workspacedebugger.png "workspacedebugger")


## Starting the Debugger


To enter or start the debugger you either click the green start button at the top of the debugger panel. Or you can hit the F5 keyboard shortcut. After the debugger has started you'll notice a few things. Your integrated terminal terminal prompt change. It now has `[DBG]` on each line indicating it's inside the debugger. You'll also notice a yellow line in your editor, this is the line the debugger is currently on. A third indication is the debugger Action Panel at the top. This is what you use to navigate the code while inside the debugger. The debugger program will stop every time it hits your break point. The benefit to this is you get to see all the variables inside the code. To do that expand or look at the variable section inside the debugger panel. It contains several different variable scopes. Making it easier to navigate the variables.


![startdebugger](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/startdebugger.png "startdebugger")


## Managing Breakpoints


Having to deal with one or two breakpoints is easy. But, what happens when you have ten or more? Moving your cursor around and removing them one by one would be painful.
The breakpoints section in the debugger panel gives you a few more was to manage the breakpoints. You can toggle on and off breakpoints one by one. You can add new ones, you can deactivate or disable all breakpoints at once. And you can also remove all breakpoints which a single click. To see this options you have to hover your mouse on the breakpoints bar in the debugger panel.

### Breakpoint Section Options


* Toggle breakpoints on\off
* Create new breakpoints
* Deactive all breakpoints
* Remove all breakpoints


![breakpointoptions](/images/posts/UsingLineBreakpointsVScodeDebugPowerShell/breakpointoptions.png "breakpointoptions")

# Summary


This blog post introduced you to the debugger in Visual Studio Code. You learned how to use line breakpoints to debug PowerShell code. As well as how to manage those breakpoints. I hope you found this useful and that you start using the debugger for your daily debugging. It will make you a much more efficient coder in the end.  This is only the tip of the iceberg. The debugger in Visual Studio Code has a lot more to offer. Things like function and conditional breakpoints. The call stack, watches, and much much more. If you're interested in learning more consider checking out my latest Pluralsight course.  [Debugging PowerShell in VS Code](https://app.pluralsight.com/library/courses/debugging-powershell-vs-code). If you've already watched it I'd love to hear your feedback!
