---
layout: post
title: Encrypting Credentials with DSC Configurations
comments: true
tags: [PowerShell, ADCS, DSC, mof, Encrypting, Certificate, credentials, passwords, clear-text]
modified: 2016-1-11 8:00:00
date: 2016-1-11 8:00:00
---
#### Applies to: Windows PowerShell 4.0, Windows PowerShell 5.0

In this blog post we'll be covering how to encrypt credentials stored in Desired State Configuration (DSC) .mof files. This is a secure alternative to secure plain text passwords in the .mof files. Before we begin I'm assuming a few things, such as an existing Active Directory domain environment and a PKI (Public Key Infrastructure) has been setup. Below is a summarized list of things you need to have completed in order to move forward.

* [Active Directory Domain](http://blogs.technet.com/b/ashleymcglone/archive/2015/03/20/deploy-active-directory-with-powershell-dsc-a-k-a-dsc-promo.aspx)
* [Active Directory Certificate Services for PKI](http://powershellscripter.com/2015/12/14/standing-up-a-pki-with-adcs-and-dsc/)
* [Workstation or Server Authentication templates deployed to all endpoints](https://technet.microsoft.com/en-us/library/cc731242%28v=ws.10%29.aspx)
* [Enhanced Key Usage Document Encryption Required for Certificates](https://dscottraynsford.wordpress.com/2015/11/15/windows-10-build-10586-powershell-problems/) (Only applies to PSv 5.0)

### Verifying & Harvesting the Certificate

First we want to confirm that the Group Policy auto enrollment has worked and issued a certificate to our target system S3. Since I've issued two certificates, two will show up here. The below snippet of code displays the thumbprint and subject of the certificate. PSComputerName shows which computer the invoke-command was ran against. In our example here we will be using the certificate with the thumbprint D2504957B1259FD16109F8041A00EFD94FBFFB40.

{% gist 121544ca0359abe9d1ed %}

![view-Certificate-thumbprints](/images/posts/2016-1-11/view-certificate-thumbprints.png "view-certificate-thumbprints")

Next we need to harvest the certificate, which simply means copying it from the target system S3 to our client computer S4. To do this we'll be using excerpted code from Pluralsight's Advanced Windows PowerShell Desired State Configuration course, available here. Copyright 2015 Pluralsight, LLC." Written by Jeff Hicks. The function is called Export-MachineCert, it does exactly what it leads you too believe. It exports the machine cert off S3 and copies it to S4. I've modified the original code a bit to include an additional parameter for the type of template used during the creation process. It provides parameter validation so you don't have to remember what it's exactly called. Load the code into your PowerShell session and then execute the export-machine command against your remote system to get the certificate copied locally.

{% gist 7522ec3edd561e916d06 %}

![Export-MachineCert](/images/posts/2016-1-11/export-machinecert.png "export-machinecert")

With the certificate harvested and the location of the certificate known the final piece of information we need before we can start building the DSC config is the certificate thumbprint, which is used to identify which certificate is used for encryption and decryption. The certificate we exported has the public key used to encrypt the file and the remote system has the private key to decrypt. Below is the command you can use to gather the thumbprint data. Again we are using the certificate with the thumbprint D2504957B1259FD16109F8041A00EFD94FBFFB40.

![view-Certificate-thumbprint02](/images/posts/2016-1-11/view-certificate-thumbprints02.png "view-certificate-thumbprints02")

### Generating an Encrypted .Mof

We are now at the point where we can generate the .mof file. With the certificate and the thumbprint we can encrypt the password stored in it.  The example configuration I'm using will create a group on the target system and then add an Active Directory user to that group. The user part, is where the credentials are needed to validate against Active Directory. I took this example from a DSC course title [Desired State Configuration with PowerShell 5.0](https://services.premier.microsoft.com/customers/home2#/courseview/298). It's taught by Ashley McGlone and Ben Wikinson both Premier Field Engineers at Microsoft. This is a Microsoft Premier customer offering and does cost money, but it's by far the best DSC resource collection I've seen thus far. They do an excellent job of walking through the entire technology and dive deep into the concepts and terminology. Below is the configuration and the commands to generate and push the configuration to S3.

{% gist d070710b3e6a785199e5 %}

Let's start by walking through the DSC configuration, as mentioned this is a very simple DSC config that creates a group on the local system and add a domain user in this case jduffney from the domain source to the group. You'll want to change it to a valid user in your active directory domain for this to work when you run it. Next up is the configdata, this contains the data used to encrypt the .mof. Be sure to update nodename, certificatefile and thumbprint to match your environment before running. Lines 35-36 call the configuration to execute which results in the creation of the encrypted .mof file named s3.mof in our example. Line 38 configures the LCM on S3 with the thumbprint of the certificate we encrypted the .mof with, now it knows which certificate private key to use when decyrpting. Line 40 starts the DSC configuration, making it so. Below is the output from these commands.

![verbose-output](/images/posts/2016-1-11/verbose-output.png "verbose-output")

### Verify the .Mof was Encrypted

To verify the .mof was successfully encrypted we can view it's contents. We can open it in notepad or any text editor to validate the password wasn't stored in clear text.

![encryptmof](/images/posts/2016-1-11/encryptedmof.png "encryptedmof")
