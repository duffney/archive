---
layout: post
title:  "Setting up Windows for Docker Container Development"
date:   2018-01-10 09:02:00
comments: true
tags: [PowerShell, visualstudio, visualstudiocode, vscode, docker, dockercompose, windows, development, dockersetup, container, containers]
modified: 2018-01-10
---

Containers are here! and if you haven't already used them I highly recommend you start even if it's for lab only environments. I say this for a few reasons the most important being it will advance your career. Containers are going to be the way forward if that isn't clear enough from all the buzz going around for the past few years. Another equality good reason you should start messing around with them is it's fun! A friend of mine [Josephe Beaudry](https://www.linkedin.com/in/josephebeaudry/) convinced me to start using them only a few weeks ago and I'll be honest, I'm a little addicted to the technology. Containers are quick to spin up, easy to modify, and best of all easy to destroy. If you're already configuring your servers with code DSC etc... do yourself a favor and start tinkering with containers. In this blog post I'm going to cover setting up your Windows environment for docker development. There are a number of tools that are extremely useful for helping you learn and use docker containers, all of which will be covered in this post.

*TL:DR Containers are not only for developers. They are quick to spin up, easy to modify and, easy to destroy. Will help your resume & it's fun!*


* TOC
{:toc}

## Install Docker

Before you begin you will need to have docker installed either Docker for Windows on Windows 10 or the Docker service for Windows Server 2016. I will also be demonstrating a number of Visual Studio Code extensions so having VSCode installed is a requirement as well.

* Docker Installed
    * [Windows Server 2016](http://www.tomsitpro.com/articles/how-to-deploy-windows-server-docker-containers,1-3326.html) or [Windows Server 1709](https://docs.docker.com/engine/installation/windows/docker-ee/)
    * [Windows 10](https://docs.docker.com/docker-for-windows/install/)
* [Docker Compose](https://docs.docker.com/compose/) (Optional)
    * `choco install docker-compose -y`
* [Visual Studio Code](https://code.visualstudio.com/download)
    * `choco install visualstudiocode -y`


## [Posh-Docker: PowerShell Module](https://github.com/samneirinck/posh-docker)

Posh-Docker is a PowerShell module that makes docker commands PowerShelly. To understand and appreciate this module you'll have to have used the docker commands without it. By default, after you install docker you get a number of command line commands you can run, but they are just that commands not cmdlets. So, you cannot do normal PowerShell things like tab completion, pipe to where-object etc... Posh-Docker takes care of all that and allows you to use the docker commands like they are PowerShell cmdlets. It also lets you convert docker output from a simple string to PowerShell objects. This allows you the pipe those objects to Where-Object etc. to filter and do all the normal PowerShell things.

### How to Install
```powershell
Install-Module -Scope CurrentUser posh-docker
```
### Tab Completion

![TabExpansion](/images/posts/SettingUpWindowsForDocker/TabExpansion.gif "TabExpansion")


### ConvertFrom-Docker

Converts docker output to PSCustomObjects

![ConvertFrom-Docker](/images/posts/SettingUpWindowsForDocker/ConvertFrom-Docker.gif "ConvertFrom-Docker")

## [Docker: VSCode Extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker)

The Docker extension from Microsoft has a lot of really cool features. It can generate Dockerfiles, docker-compose.yml files and docker-compose.debug.yml files. It also provides intellisense for Dockerfiles and docker-compose.yml files. Intellisense is by far my favorite feature of this extension. It also has explorer integration, which allows you to see all the images you have, all the containers stopped or started on the system and the registries you have setup. The interaction you have with the containers though this explorer is limited but gives you a nice birds eye view of what you've got downloaded, stopped and or running. Another feature worth mentioning is it allows you to issue docker command from Visual Studio Code's command palette. To access it hit F1 and then `Docker:` to see a list of all the commands. I personally don't use this feature much as I prefer to do all my work at the command line.

### IntelliSense for Docker

![IntelliSense](/images/posts/SettingUpWindowsForDocker/IntelliSense.png "IntelliSense")


### Explorer Integration

![ExplorerIntegration](/images/posts/SettingUpWindowsForDocker/ExplorerIntegration.png "ExplorerIntegration")

## [Docker Explorer: VSCode Extension](https://marketplace.visualstudio.com/items?itemName=formulahendry.docker-explorer)

Docker Explorer is a lot like the explorer integration provided by the Docker extension, but is quicker and overall much smoother. It lets you manage docker images, containers registries and the Azure container registry if you have one setup. This extension was really helpful when I was first learning the commands. I could right click a container and select the command I wanted and it would output in the terminal so I could see the syntax.

### Docker Explorer vs Docker Extension

![dockerExplorer](/images/posts/SettingUpWindowsForDocker/dockerExplorer.png "dockerExplorer")


## [Docker Extension Pack](https://marketplace.visualstudio.com/items?itemName=formulahendry.docker-extension-pack)

As far as I can tell this is just an easy way to install the two pervious extensions mentioned at once. Installing this installs the Docker Explorer and Docker extensions, but add not additional functionality. So, if you want to be lazy just install this one. If I'm missing some features, please leave a comment below.

## Summary

1. Install Docker
    1. Install Docker-Compose
2. [Posh-Docker: PowerShell Module](https://github.com/samneirinck/posh-docker)
3. [Docker: VSCode Extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker)
4. [Docker Explorer: VSCode Extension](https://marketplace.visualstudio.com/items?itemName=formulahendry.docker-explorer)
    1. Contains both [Docker Extension Pack](https://marketplace.visualstudio.com/items?itemName=formulahendry.docker-extension-pack)
5. Have fun learning!

_Special thanks to [Josephe Beaudry](https://www.linkedin.com/in/josephebeaudry/) for pushing me to learn about containers and sharing these tools with me._
