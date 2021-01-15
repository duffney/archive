---
layout: post
title: Setting up a Vyos Virtual Router in Hyper-V
comments: true
tags: [PowerShell, Vyos, Router, Hyper-V]
modified: 2015-12-4 8:00:00
date: 2015-12-4 8:00:00
---
#### Applies to: Windows PowerShell 5.0, Windows 10, Windows Server 2016

![VyosLogo](/images/posts/2015-12-4/vyoslogo.png "vyoslogo")

In this post we'll be walking through how to setup a Vyos virtual router for a Hyper-V lab. Vyos is an open source virtual router, which allows us to have a separate network for all of our Hyper-V virtual machines and route it's traffic through our normal private network to the internet. We'll keep it simple and have only two networks to worry about. One will be named Internal, meaning the internal Hyper-V network. The second will be named External referring to our private network we'll use to access the internet.

### Creating the Hyper-V Switches

First things first, we need to identify the network adapter that provides internet access to our host machine. Of course we'll use PowerShell to determine this, the cmdlet is Get-NetAdapter. I've added a select statement to only show the name and interface description to make it easier to read. Warning, this cmdlet will only work on Windows 8.1 and above.

![Get-NetAdapter](/images/posts/2015-12-4/get-netadapter.png "get-netadapter")

You can discard the Pertino Connection adapter, it's an awesome VPN solution but we care about the Local Area Connection. That is the name of the adapter on my desktop that provides internet access to my Hyper-V host. With this knowledge we can create the Hyper-V network switches. Again, we are going to create two networks for Hyper-V to use one called Internal and one called External. With the external being our internet source. We could create them in the Hyper-V manager GUI, but why right? Below is a gist of code that will create the adapters, since I have two Local Area Connection and the Pertino adapter I'm specifying the Local Area Connection by using $NetAdapterName[0]

{% gist 2d1489abc3ac31315edb %}

### Creating the Virtual Machine

Now the fun begins! With the adapters configured we can now create the Vyos virtual machine. You'll soon realize why you might want to use Vyos over a Windows Server with routing features, the size and resources required are much lower. With only 2GB of hard drive space required and 512mb of ram, any modern computer can run this easily. You will need the Vyos .iso which can be downloaded here. With that downloaded we can create the virtual machine in Hyper-V with the below gist. The gist will create the virtual machine to spec and attach a hard drive and disk drive along with mounting the required .iso. Update the code to match your .iso path and hard drive location. You've just gotta love PowerShell.

{% gist 35c61d2c9a441951310c %}

### Warning! Linux ahead!

The next steps will involve configuring the Vyos router, there really isn't a need to be scared (Windows Guys & Gals). Let's start by powering the Vyos router on and connecting to it. Right click hit connect and then hit the green button at the top to start, or use Start-VM. Next we're presented with the below screen, log in with the following credentials.

Vyos Login: vyos

Password: vyos

![vyosstartscreen](/images/posts/2015-12-4/vyosstartscreen.png "vyosstartscreen")

### Install and Configure Vyos

After we get logged into the device issue the following commands to install and configure the virtual router. Hit ctrl alt left arrow to escape the virtual machine.

1. install system
    1. Accept all defaults
    2. say yes to (This will destroy all data on /dev/sda)
2. After the install completes power off the virtual machine and eject the dvd drive
    1. poweroff
    2. Remove mounted media
    
    {% highlight powershell %}Get-VM -Name vyos | Get-VMDvdDrive | Set-VMDvdDrive -path $null{% endhighlight %}
     
3. Start up Vyos
    1. Start the virtual machine
    
    {% highlight powershell %} 
    Start-VM -Name vyos
    {% endhighlight %}

4. Login
    1. username: vyos
    2. password:  vyos ( or whatever you set in the install section)
5. Configure the networks
    1. configure
    2. set interfaces ethernet eth1 address dhcp
    3. set interfaces ethernet eth0 address 192.168.2.1/24
    4. set nat source rule 10 outbound-interface eth1
    5. set nat source rule 10 source address 192.168.2.0/24
    6. set nat source rule 10 translation address masquerade
    7. commit
    8. save
    9. exit
    0. reboot
6. After reboot verify the interfaces
    1. show interfaces ethernet
    
Make sure Ethernet eth1 gets and IP address from DHCP, if it doesn't eth0 is your internet interface. Now any virtual machine in Hyper-V with the internal adapter will be on its own network and will have internet access if configured on the 192.168.2.0/24 network with a default gateway of 192.168.2.1.

![VyosInterface](/images/posts/2015-12-4/vyosinterface.png "vyosinterface")

Sources

[deploymentresearch](http://deploymentresearch.com/Research/Post/285/Using-a-virtual-router-for-your-lab-and-test-environment)