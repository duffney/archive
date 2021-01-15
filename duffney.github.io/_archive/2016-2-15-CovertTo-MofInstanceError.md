---
layout: post
title: CovertTo MofInstance Certificate Cannot be used for Encryption
comments: true
tags: [PowerShell, DSC, encryption, certificates, certificate, Document-Encryption, encipherment]
modified: 2016-02-15 8:00:00
date: 2016-02-15 8:00:00
---
#### Applies to: Windows PowerShell 5.0

![convertto-mofinstance-error](/images/posts/2016-2-15/convertto-mofinstance-error.png "convertto-mofinstance-error")

You probably ran into this error while using a Windows 10 or Windows Server 2016 Technical Preview when attempting to encrypt DSC configuratiosn, as I did. For some reason, the certificates I had been using no loneger worked. 
When I attempted to ecnrypt my DSC configurations I got the above error saying the the function ConvertTo-MofInstance failed and that the certificate that I was using could not be used
for document encryption. It also told me what the issue was "encryption certificates must contain the data encipherment or key encipherment key usage, and include the document encryption
enchanged key usage" At the time, I had no clue what that meant. To fix this continue reading....  

### How to Fix the Certificate

Examining the output, it says the certificate I gave the configuration cannot be used for encryption. It also points out why by 
saying that our certificate doesn't have the Data Encipherment or Key Encipherment key usages. At first this turned into a short 
moment of insanity while I just ran the config over and over again hoping the error would go away. I even rebooted all my virtual 
machines a few times for good measure, but the error always returned. After a little light reading on certificates and Active Directory 
Certificate Services I understood what I needed to do. What I discovered was in PowerShell version 5, the version on Windows 10 and Windows Server 2016
require that the certificates have the extension Document Encryption. From what I understood it requires this to allow a longer encryption password. 

#### Certificates Issued through Active Directory Certificate Services
So..... how do you fix it? Start by opening the Certification Authority administration tool from either a client machine with RSAT on it or by 
logging into the Certification Server (This is a trick don't do it). Then follow the steps below to include document encryption into the existing certificate.

1. Expand the server name within Certification Authority
2. Locate Certificate Templates
3. Right click select Manage
4. Find the certificate issued to the machines (typically a duplicate of the Computer or workstation authentication template)
5. Right click and select Properties
6. Click on the Extensions tab
7. Click Application Policies and then edit
8. Click add
9. Locate Document Encryption and double click it then hit OK
10. Click OK twice to close out of both Property boxes

![certextensions](/images/posts/2016-2-15/certextensions.png "certextensions")

#### Reenroll Certificates

With the certificate extension updated you now need to re-enroll all of the certificate. To do that right click on the certificate and click "Reenroll All Certificate Holders"

![reenroll](/images/posts/2016-2-15/reenroll.png "reenroll")

With all certificate holders re-enrolled you can begin encrypting .mof files once again!

#### Self Signed Certificates

Another way you might have issued the certificates is by generating a self signed certificate. I'm currently not aware of how you'd modify an existing certificate, but you could use the [New-SelfSignedCertificateEX](https://gallery.technet.microsoft.com/scriptcenter/Self-signed-certificate-5920a7c6)
to generate a new certificate. Below is a snippet of code that shows the syntax of how to accomplish that, I'm using a technique called splatting to provide the parameters. 

{% highlight powershell %}
$params = @{
    'Subject' = 'CN=Cert'
    'StoreLocation' = 'LocalMachine'
    'StoreName' = 'My'
    'EnhancedKeyUsage' = 'Document Encryption'
    'FriendlyName' = 'SelfSigned'
}
New-SelfSignedCertificateEx @params
{% endhighlight %}