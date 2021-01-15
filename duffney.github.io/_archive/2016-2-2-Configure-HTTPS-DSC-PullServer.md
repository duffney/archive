---
layout: post
title: Configuring an HTTPS Pull Server for Desired State Configuration
comments: true
tags: [PowerShell, Pull, DSC, HTTPS, Encrypting, PullServer, Securing]
modified: 2016-2-2 8:00:00
date: 2016-2-2 8:00:00
---
#### Applies to: Windows PowerShell 4.0, Windows PowerShell 5.0

This blog post will guide you through the process of setting up and configuring an HTTPS Pull Server to deploy Desired State Configurations to nodes. It will also walk you through the process of requesting the cert from the CA (Certificate Authority)! That is the main reason I'm taking the time to write the post, almost all the DSC training I've watched skips that step and leaves the viewer clueless on how to configure HTTPS since a cert is kind of a requirement. There are however some requirements for this blog post, most of which I've written about previously and I'll link them below.

### Requirements

* PowerShell Version 4 or 5
* [Active Directory Domain](http://blogs.technet.com/b/ashleymcglone/archive/2015/03/20/deploy-active-directory-with-powershell-dsc-a-k-a-dsc-promo.aspx)
* [Active Directory Certificate Service (ADCS) for PKI (Public Key Infrastructure)](http://duffney.io/Build-ADCS-DSC)
* Prebuild Virtual Machine (PullServer) {Domain Joined, Network connectivity established to domain}
* xPSDesiredStateConfiguration DSC Resource

### Prepare the DSC Resource

Assuming you have a virtual machine joined to the domain with network connectivity, the very next thing we need is to get the xPSDesiredStateConfiguration DSC 
resource copied to the VM. If the VM has internet connectivity you can issue the below cmdlet to pull down the resource from the PowerShell gallery. An alternative to that would be download it to a computer with internet access and get it copied over somehow. Also verify the resource got installed, see screenshot.

{% gist a3c7bdf1a928022fc8c8 %}

![Get-DscResource](/images/posts/2016-2-2/Get-DscResource.png "Get-DscResource")

### Creating the Web Cert

Next up, you have to request a web cert for your HTTPS Pull Server. To do that, log into the Certificate Authority server and open the IIS manager. You can start it in PowerShell with the command start inetmgr. The following steps outline how to request a cert.

1. Open IIS Manager
2. PS:> start inetmgr
3. Expand The server site
4. Double Click Server Certificates
5. Click "Create Domain Certificate" on the right side panel under actions
6. Common Name = Full Qualified Domain Name of Pull Server Example:ZPULL01.zephyr.org
7. Fill in: Organization, Organizational Unit, City, State with whatever you'd like
8. Click Next
9. Hit select next to specify online certification authority
10. select your server and hit OK
11. Input a Friendly name of PSDSCPullServerCert
12. Finish

![WebCert](/images/posts/2016-2-2/WebCert.png "WebCert")

### Exporting & Importing the Web Cert onto the PullServer

Since I am not using the Certificate Authority [ZCert01] as the Pull server I need to export the certificate then import it on the PullServer. Follow the below steps to export and import the certificate.

1. From the IIS manager select the certificate PSDSCPullServerCert
2. On the right hand side click export under actions
3. Hit the ... to browse
4. Navigate to the Pull servers system drive Example [\\ZPull01\c$]
5. Input a password 
6. click OK
7. Log into the Pull Server
8. Locate the PSDSCPullServerCert.pfx file and double click
9. Enter the password
10. Select Local Machine
11. Accept all defaults and finish the wizard

### DSC Config for HTTPS DSC Pull Server

Now that I have a certificate created, I can now start to write the DSC config for the HTTPS Pull server. Yes, I'll be creating a DSC Pull server with DSC, fantastic right? But, before I can begin we'll need to get the certificate thumbprint from the cert, which can be accomplished with the below command. Replace ZCert01 with your Certificate Authority server name and the friendly name. In my case the freindly name is PSDSCPullServerCert and the server is ZCert01.

{% gist 3bb74fa5411ff8bc9358 %}

With the thumbprint in hand, I can write the DSC Config for the HTTPS Pull Server. Really the only difference between an HTTP and HTTPS is this thumbprint. 
You replace AllowUnencryptedTraffic in the CertificateThumbPrint field with the thumbprint of the certificate, which I got from ZCert01 in this example.

![DscConfig](/images/posts/2016-2-2/DscConfig.png "DscConfig")

I've now got all I need, it's time to generate the .mof by running the config and then apply it to the PullServer. Take the below snippet of code modify it for your environment and run it. For a full configuration including IP address domain join etc.. see my Github Repo [DSC_LabAsCode](https://github.com/Duffney/DSC_LabAsCode). Please also noticed that I included the module version, I had two version of the xPSDesiredStateConfiguration on the machine. Which forced me to include -moduleVersion, you may not have to do this and if you do make sure it's the right version number.

{% gist aa2a51ab565fa607af75 %}

### Verify the PullServer URL

Once the configuration has finished, you'll want to verify that it's working properly. Below is a snippet of code that will start internet explorer and go to the pull server URL, modify this
string to match your environment. [Replace zpull01.zephyr.org with your PullServers FQDN]

{% gist 019393caa040c583490d %}

![VerifyPullWebURL](/images/posts/2016-2-2/VerifyPullWebURL.png "VerifyPullWebURL")