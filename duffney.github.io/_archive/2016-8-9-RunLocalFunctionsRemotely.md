---
layout: post
title: Run Local Functions Remotely in PowerShell
comments: true
tags: [PowerShell]
modified: 2016-8-9 8:00:00
date: 2016-8-9 8:00:00
---

Have you ever had functions loaded into your local PowerShell session and needed to run them on a remote system? The typical solution
to this problem is to copy the code to the remote system and then load the functions on the remote system to use them. What if I told you
it is possible to run functions you have stored on your local machine and execute them remotely with Invoke-Command? This post will teach
you how to do this.

### Execute Local Functions Remotely

To demonstrate how to do this, I'll use a famous Hell-World example. I have written an extremely simple function that writes
"Hello, World!" to the console. It is called MyFunction and has no parameters. I've loaded to into my local PowerShell session
and to run it remotely I will use Invoke-Command. Here is the trick, place a $ symbol out side the curly braces of the scriptblock.
Then put Function: inside the scriptblock before the name of the function as seen below.

{% highlight PowerShell %}
function MyFunction ()
{
    Write-Host 'Hello, World!'
}

Invoke-Command -ComputerName DC1 `
-ScriptBlock ${Function:MyFunction}
{% endhighlight %}


![MyFunction](/images/posts/2016-8-9/MyFunction.gif "MyFunction")


### Using Parameters

While the above example works, most functions aren't that simple. Most require several parameters and how do you pass those
parameters to the function running remotely? To illustrate, I've written another simple function called Get-NetConfig. Provided
an InterfaceIndex and AddressFamily parameter, it will gather information about the network settings of the system it runs on. 
In the below example I am passing the values for the InterfaceIndex and AddressFamily by using the -ArgumentList parameter of
Invoke-Command.

{% highlight PowerShell %}
function Get-NetConfig
{
    [CmdletBinding()]
    Param (
        $InterfaceIndex,
        $AddressFamily
    )

    $NodeName = $env:ComputerName
    $NetAdapter = Get-NetAdapter -InterfaceIndex $InterfaceIndex
    $IPconfig = Get-NetIPAddress -InterfaceIndex $InterfaceIndex -AddressFamily $AddressFamily
    $DNS = (Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex).ServerAddresses
    $obj = [PSCustomObject]@{NodeName=$NodeName;IPAddress=$IPconfig.IPAddress;MacAddress=$NetAdapter.MacAddress;DNS=$DNS}
    $obj
}

Invoke-Command -ComputerName DC1 `
-ScriptBlock ${Function:Get-NetConfig} `
-ArgumentList '5','IPV4' |
Select-Object NodeName,IPaddress,MacAddress,DNS
{% endhighlight %}


![Get-NetConfig](/images/posts/2016-8-9/Get-NetConfig.gif "Get-NetConfig")


### Changing Parameter Order

Often you do not specify the parameters in the order they are listed in the function. This is a problem,
because executing function remotely requires they be in the exact same order. This means that if I provided
AddressFamily first and IPAddress second in the above example it would error out. There are ways around this
of course. Method 1 would be to set default values for all the parameters, but that's not an ideal solution.
Method 2 is setting the position of the parameter to the order you want. In the below code I'm giving AddressFamily
the first position by specify 0 and assigning position 1, the second position to AddressFamily.


{% highlight PowerShell %}
function Get-NetConfig
{
    [CmdletBinding()]
    Param (
        [Parameter(Position = 1)] #<--- Second Param
        $InterfaceIndex,
        [Parameter(Position = 0)] #<-- First Param
        $AddressFamily
    )

    $NodeName = $env:ComputerName
    $NetAdapter = Get-NetAdapter -InterfaceIndex $InterfaceIndex
    $IPconfig = Get-NetIPAddress -InterfaceIndex $InterfaceIndex -AddressFamily $AddressFamily
    $DNS = (Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex).ServerAddresses
    $obj = [PSCustomObject]@{NodeName=$NodeName;IPAddress=$IPconfig.IPAddress;MacAddress=$NetAdapter.MacAddress;DNS=$DNS}
    $obj
}

Invoke-Command -ComputerName DC1 `
-ScriptBlock ${Function:Get-NetConfig} `
-ArgumentList 'IPV4','5' | #<---- Changed Arguement Order
Select-Object NodeName,IPaddress,MacAddress,DNS
{% endhighlight %}


![PositionalParams](/images/posts/2016-8-9/PositionalParams.gif "PositionalParams")
