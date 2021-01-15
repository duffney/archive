---
layout: post
title: Build Active Directory Certificate Services with DSC
comments: true
tags: [PowerShell, ADCS, DSC, CustomResources, PKI, Certificate]
modified: 2015-12-14 8:00:00
date: 2015-12-14 8:00:00
---
#### Applies to: Windows PowerShell 5.0, Windows Server 2012r2+

Today we will be standing up a Public Key Infrastructure (PKI) with Active Directory Certificate Services, but not the manual click click way. We'll be applying a desired state configuration that will set it up for us! The end result will be a standalone PKI server, perfect for lab environments. This post won't be to helpful if you're looking to stand up a production ready PKI environment. Before we begin lets talk about some prerequisites to this blog post, see below. Some of the DSC resources are optional, I chose to include them to configure thing such as IP address, Default Gateway and timeZone, xAdcsDeployment is the only required resource to configure ADCS.

### Prerequisites

[Active Directory Domain](http://blogs.technet.com/b/ashleymcglone/archive/2015/03/20/deploy-active-directory-with-powershell-dsc-a-k-a-dsc-promo.aspx)

2 Windows Servers 2012R2+ (1 Domain Controller, 1 PKI)

PowerShell v5

[DSC Resources](https://github.com/PowerShell)

    1. xAdcsDeployment
    2. xNetworking
    3. xComputerManagement
    4. xTimeZone
    
### Downloading Resources & Pushing the ADCS Config

Download the required custom DSC resources from the PowerShell Gallery.

{% gist 8813111b269b433cca92 %}

Generate the .mof file by executing the configuration and push the configuration to
the node. Modify the below code to match your environment. Things like the domain name, ip address and user name might be different.

{% gist 54fbdc57076835c34a19 %}

After executing the configuration you should see output similar to the one displayed below.

![verboseCertconfig](/images/posts/2015-12-14/verboseCertconfig.png "verboseCertconfig")

### Verifying the Config

There are a few cmdlets worth mentioning for DSC, first off is Test-DscConfiguration. This cmdlet will return a true or false value, letting us know if the target node is in it's desired state. The next one is Get-DscConfigurationStatus, which provides more detailed information about the configuration.

![TestCertConfig](/images/posts/2015-12-14\testcertconfig.png "testcertconfig")

We can also verify if the ADCS install properly and is operational by opening the Certification Authority tool included in RSAT and connecting to our new certificate authority.

![CAGUI01](/images/posts/2015-12-14/CAgui01.png "CAgui01")

![CAGUI02](/images/posts/2015-12-14/CAgui02.png "CAgui02")
