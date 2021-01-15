---
layout: post
title:  "Creating an AWS EC2 Windows Instance with Cloudformation and PowerShell"
date:   2019-08-10 13:37:00
comments: true
modified: 2019-08-10
---

In this blog post I'll be walking through how to use the [AWSPowerShell.NetCore](https://www.powershellgallery.com/packages/AWSPowerShell.NetCore/3.3.365.0) PowerShell module to deploy a Windows virtual machine to AWS EC2. If you're unfamiliar with AWS, EC2 stands for Amazon Web Services Elastic Compute Cloud. It's AWS's IaaS offering that allows you to spin up virtual machines in their cloud. Cloudformation is another service offered by AWS that allows you to define your infrastructure as code (IaC). And PowerShell well... it says it all. It is a powerful shell. 


* TOC
{:toc}


### Creating a Key Pair

In order to provision a useful Ec2 instance, I'll first need to create a key pair. AWS Ec2 uses public–key cryptography to encrypt and decrypt login information. Luckily, I can do this in PowerShell. The cmdlet to create new AWS Key Pairs is `New-EC2KeyPair`. The results of that cmdlet has a member called `KeyMaterial` that contains the private key for the keypair. Which I'll need to save as a .pem file. If I do not do that I won't be able to decrypt the Ec2 instances administrator password to login. Note before you can run the following commands, you'll need the AWS PowerShell module for your operating system installed and set it up to connect to your AWS account. Check out [Guide: Setting up the AWS PowerShell Module]("https://www.youtube.com/watch?v=Z4rNHjEXoSs") to learn more.


```
$awsPSKeyPair = New-EC2KeyPair -KeyName awsPSKeyPair
$awsPSKeyPair.KeyMaterial | Out-File -Encoding ascii awsPSKeyPair.pem
```

To confirm the key pair was generated and is availabe in AWS we can run the cmdlet `Get-Ec2KeyPair`

```
Get-EC2KeyPair -KeyName awsPSKeyPair
```

### Create the Cloudformation Template

Now that a key pair exists, I can move on to creating a Cloudformation template. A Cloudformation template is a document that defines the AWS resources you want to provision. Cloudformation calls the combination of those resources a _stack_. I've used several infrastructure as code (IaC) tools and Cloudformation is by far one of my favorites. Cloudformation allows you to write the IaC documents in one of two formats; JSON or YAML. I write a fair amount of ansible code at my day job so I'm going to choose to write it in YAML. 

In my cloudformation template I'm going to need a few things. First off I'll need to define an Ec2 instance. Secondly, I'll need to specify the keypair I just created so I can access my Ec2 instance after it's been provisioned. I want it to be a Windows 2019 virtual machine. AWS offers pre built templates called AMIs (Amazon Machine Image). I'll also need to decide on an instance type (how big I want the virtual machine). I'll stay within the free-tier of AWS so I'll define the type as t2.micro. For more information on instance types check out the [AWS Instance Types docs](https://aws.amazon.com/ec2/instance-types/). I'll also need a way to access this Ec2 instance via RDP. To do that I'll have to create a security group and allow RDP access on port 5985. Lastely, I'll bootstrap a command under the userdata section that installs [chocolatey](https://chocolatey.org/).

There is a lot to learn when it comes to Cloudformation and I myself am just scratching the surface. An excellent way to get a great foundation understanding of Cloudformation is to check out acloudgurus's [Introduction to AWS CloudFormation](https://acloud.guru/learn/intro-aws-cloudformation) course.

{% gist 3e9dae330f9f76ea65a744cfdfe43d7a %}

### Writing Cloudformation Templates to AWS S3 with PowerShell

At this point we have a key pair and a Cloudformation template. Where should I put this template file? Of course, I could create a new repository on Github, but I want to learn more about AWS. Another option is to store it in AWS S3 (Simple Storage Service). AWS S3 has a concept called buckets. You can think of buckets as network shares. In the bucket you can create directories and or upload files. Before you can store things in S3 you'll need a bucket. The bucket name has to be unique across all of AWS and in lower-case. Once the bucket is created you can start to upload files to it. S3 does version all the files uploaded to it so don't worry about overwriting them.

```
#Create new s3 bucket
New-S3Bucket -BucketName duff-awspsbucket

#Write to s3 bucket
Write-S3Object -BucketName duff-awspsbucket -File simpleWinStack.yaml

#Verify object exist in s3
Get-S3Object -BucketName duff-awspsbucket
```

![get-duff-awspsbucket](/images/posts/CreatingWinEc2CFNPowerShell/get-duff-awspsbucket.png "get-duff-awspsbucket")

### Deploying a Cloudformation Stack with PowerShell

To recap, I now have a key pair in AWS and a Cloudformation template stored in an AWS S3 bucket. The most exciting is I now get create a new Cloudformation stack using PowerShell. Stack is a term Cloudformation uses to describe all the AWS resources defined in a Cloudformation template. In my example the stack consists of two resources an Ec2 instance and a security group. Because the stack does not already exist, I'll use the `New-CFNStack` cmdlet. Since I previously uploaded my Cloudformation template to S3, I'll use the `-TemplateURL` parameter to specify the location of the template file to use for the stack. I also need to pick an AWS region. In this example I've chosen to provision my stack in the us-east-1 region. You can get the URL of the S3 object from the S3 GUI or you can figure out the URL yourself. The URL is always `htts://bucketname.s3.amazonaws.com/fullfilename`.

```
$templateURL = "https://duff-awspsbucket.s3.amazonaws.com/simpleWinStack.yaml"
New-CFNStack -StackName "SimpleWinStack" -TemplateURL $templateURL -Region us-east-1
```

### Getting Information about a Cloudformation Stack

Inside the Cloudformation console under events you can see the progress of the stack deployment. After about a minute the stack resources were created. I now have an Ec2 instance I can log into and a security group that the EC2 instance is assigned allowing RDP access to that machine. There are several other tabs in the Cloudformation console you can look at to see different information about your stack. Such as the resources, template, outputs and parameters used for the stack. However, me being a PowerShell person I prefer to gather all that information with PowerShell. Luckily enough AWS's PowerShell module lets me do that quite easily. The AWSPowerShell.NetCore has 20 cmdlets that will retrieve the status and various information about a Cloudformation stack.

![getcfnstackcmd](/images/posts/CreatingWinEc2CFNPowerShell/getcfnstackcmd.png "getcfnstackcmd")

```
 Get-CFNStack -StackName 'SimpleWinStack' 
```

![get-cnfstack](/images/posts/CreatingWinEc2CFNPowerShell/get-cnfstack.png "get-cnfstack")

```
Get-CFNStackResources -StackName 'SimpleWinStack'
```

![Get-CFNStackResources](/images/posts/CreatingWinEc2CFNPowerShell/Get-CFNStackResources.png "Get-CFNStackResources")

### Deleting a Cloudformation Stack

This is by far my favorite part of using Cloudformation. Since it's aware of all the resources it created from the template it can easily delete all of them. When you're dealing with On-Prem infrastructure or even your own lab environment on your laptop. Deleting things isn't something you worry about until you run out of resources. That's of course because there isn't a direct cost associated with consumption. The cloud however, is purely based on consumption of resources. Therefore, it's VERY important that you clean up after yourself. Especially if your credit card is tied to the account. Deleting resources with Cloudformation in PowerShell is just as easy as creating them. Yep, that's right it's a single cmdlet `Remove-CFNStack`.

```
Remove-CFNStack -StackName 'SimpleWinStack' -Confirm:$false
```

![remove-cfnstack](/images/posts/CreatingWinEc2CFNPowerShell/remove-cfnstack.png "remove-cfnstack")