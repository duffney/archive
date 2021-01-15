# AppProvisionOctopusDSC
Application Provisioning with DSC and Octopus Deploy Presentation Demo

## Requirements

* Docker
    * [Windows 10](https://docs.docker.com/docker-for-windows/install/)
    * [Windows Server 2016](http://www.tomsitpro.com/articles/how-to-deploy-windows-server-docker-containers,1-3326.html)
    * [Windows 1709](https://docs.docker.com/engine/installation/windows/docker-ee/)
* [Docker-Compose](https://docs.docker.com/compose/install/)
    * `choco install docker-compose -y`
* [Git](https://git-scm.com/download/win)
    * `Choco Install git -y`

## Clone Repository

```powershell
git clone https://github.com/Duffney/AppProvisionOctopusDSC.git
```

## Compose Environment

```powershell
cd AppProvisionOctopusDSC
docker-compose up
```
_Pulling images will take awhile, wait for all containers to be built._

## Update OctopusDeploy Host File

```powershell
$ip =(docker inspect appprovisionoctopusdsc_tentacle_1 | ConvertFrom-Json).NetworkSettings.Networks.nat.IPAddress
$scriptblock = "Add-Content C:\Windows\System32\drivers\etc\hosts -Value '$ip web1'"
docker exec appprovisionoctopusdsc_octopus_1 powershell $scriptblock
```

## Open Octopus UI

```powershell
$docker = docker inspect appprovisionoctopusdsc_octopus_1 | convertfrom-json;start "http://$($docker[0].NetworkSettings.Networks.nat.IpAddress):81"
```

*API Key: API-BVZYH4VGBHEGD06DIL1PTFHJNW*