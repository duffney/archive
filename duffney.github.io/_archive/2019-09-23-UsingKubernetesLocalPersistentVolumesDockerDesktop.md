---
layout: post
title:  "Using Kubernetes Local Persistent Volumes on Docker-Desktop"
date:   2019-09-23 13:37:00
comments: true
modified: 2019-09-23
---

In this blog post, I'll be walking through how to create a persistent volume in Kubernetes. There are several volume types in Kubernetes, but to get started I'll be using the local volume type. A local volume represents a mounted local storage device such as a disk, partition or directory. I'll be using a Kubernetes cluster running within docker-desktop. Because of this, there isn't an easy way (at least that I've found) to access the node running in the docker-desktop instance that hosts the Kubernetes cluster. Because of that the maintenance of the volumes is a bit different than you'd expect. Before we dive in first let's answer the question of __why would you create a persistent volume?__

If you've been working with virtual machines most of your career this isn't something you've given much thought. The reasons for that is most virtualized environments are static. You create a virtual machine and make changes to that virtual machine. You only delete it when it is time to decommission it. Which we all know is a very unlikely scenario. When administering containers on the other hand the deletion of a container happens all the time. Everytime you want to update the container, you delete it and replace it with a new one. With that in mind how do we keep the data the container wrote? Persistent volumes answer that question. The example I'll be using in this blog post is persisting data stored by mysql for hosting a TeamCity database. 

* TOC
{:toc}

### Methods for Creating Persistent Volumes

There are two options you have used when creating persistent volumes. You can create the volume as a pod volume. Which means that you define the volume and mount it within a single Kubernetes pod spec. While this is the simplest option, but it also had a draw back. By defining the volume in the Pod spec you couple the data layer in with your application. This will make scaling and management of the data layer more difficult. It also requires that you have a good understanding of the data layer. The other option you have is to create a persistent volume and persistent volume claim. By doing so you decouple the data layer and the application layer. Making the management of each simpler. In this blog post I'll be using a persistent volume and persistent volume claim.

Two Options
* Pod Volume
* Persistent Volume & Persistent Volume Claim

### Creating a Local PersistentVolume

You can think of a persistent volume as a datastore to steal some vmWare terminology. Persistent volumes are provisioned by cluster administrators or dynamically provisioned using storage classes. For now, let's keep it simple and provision it by hand. You'll have to define a Kubernetes manifest with the kind of `PersistentVolume`. The manifest requires a few details about the storage that will be provisioned. You'll have to give it a name, storageClassName, specify the capacity, access modes and path since I'm using the local storage type. These options will change with the type of storage you choose to use. 

There are two important pieces of information that are worth explaining a bit more. Capacity and accessModes are used by the persistent volume claims. Capacity is straight forward. It's the amount of space available for a claim to take. Claims use this information to determine which persistent volumes it can bind to. accessModes define what operations can be performed on the volume. There are a few different accessModes; ReadWriteOnce, ReadOnlyMany and ReadWriteMany. These define how the pods can read and write data to the volume. Claims use capacity and access mode to determine which volumes to bind to do fulfill the claim. 

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: "/tmp/teamcitydata"
```

```
#save above as mysql-pv.yaml
kubectl apply -f mysql-pv.yaml

#Get pv (persistentVolume)
kubectl get pv
```



### Creating a Persistent Volume Claim

Storage is now available and ready to be claimed. Next, is to create a persistent volume claim. This claim will be used by the pod spec and mounted to the container. As I mentioned previously the volume needs to define the capacity and access mode. The volume claim also needs to specify this information because it uses those to match up the claim with the volume. 


```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```
#save above as mysql-pvc.yaml
kubectl apply -f mysql-pvc.yaml

#get pvc (persistentVolumeClaims)
kubectl get pvc
```

### Using Persistent Volume Claims with Deployments

At this point, a persistent volume and a persistent volume claim have been created. The persistent volume claim has been bound to the persistent volume by matching the access modes and capacity. You can confirm this by running the `kubectl get pv` command and looking at the _STATUS_ column of the `mysql-pv-volume`. The claim is now ready to be used by a pod or deployment spec. To demonstrate this I'll use a mysql deployment that creates a service for mysql and runs a single mysql container. Pay close attention to the volumes and volumeMounts sections. The volumeMounts section of the container spec specifies the name of the volume and the mountPath inside the container. The volumes section creates uses the persistent volume claim as it's mapping to an actual volume that can be used by the container.

```
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
  clusterIP: None
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
          # Use secret in real usage
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

```
#save the above as mysql-deployment.yaml
kubectl apply -f mysql-deployment.yaml

#get pods (confirm mysql container is running)
kubectl get po -l app=mysql
```

### Staging a Database

With a running pod I can now stage some configuration for my TeamCity database. To do this I'm going to load up a side-car container with mysql-client on it. Once I'm connected to the mysql database I'll create a database for Teamcity, provision a user account for TeamCity to use when connecting to the database and grant that user permissions to the new database. After you issue the mysql commands you can check the mounted folder on your local operating system to verify that data has been written to it. In my case I'm using docker-desktop for mac and my shared path is `/tmp/teamcitydata`. Inside that location I now see a folder `teamcitydata`. Which is for the new database I created. It contains a single file db.opt that has some of the settings of the database. At this point I can could attach a TeamCity instance to the mysql pod and have a working TeamCity instance. However, I'll skip those steps for now and focus on volume management. Everything up to this point has taught you how to provision, mount, and use persistent volumes. But what about deletion and cleanup?

```
#run side-car mysql-client container
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -ppassword

#mysql commands to run
create database teamcity collate utf8_bin;
create user teamcity identified by 'password';
grant all privileges on teamcity.* to teamcity;
grant process on *.* to teamcity;

#list contents of mysql volume
ls /tmp/teamcitydata
```

### Understanding Persistent Volume Reclaim Policies

There is a setting you can defined called `persistentVolumeReclaimPolicy` in the PersistentVolume manifest. This setting determines what happens to the data in a volume when its released from a claim. Meaning the claim was deleted and the volume is no longer bound to any claim. There are three options for `persistentVolumeReclaimPolicy`; Retain, Delete, and Recycle. Retain preserves the data and the volume. When a claim is removed the volume simply remains as it was and can be attached to new claims that fit the requirements of the claim. Note, that by using retain the new claims would have access to the old data stored on the volume. Delete will delete the volume when a claim is deleted. It does not however delete the data inside the volume, just the volume. So, if you re-create a volume at the same path it will load up the old data into the volume. Recycle is being deprecated in favor of dynamic volumes. But, it's worth knowing that it can be used to preserve the volume but to delete the data in the volume when a claim is deleted. You can learn more about reclaim policies [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming).

Reclaim Policies

* Retain
* Delete
* Recycle (deprecated in favor of dynamic volumes)

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: "/tmp/teamcitydata"
```

# Manual Clean Up With Local Persistent Volumes

An interesting note in the official documentation about local persistent volumes states that _The local PersistentVolume requires manual cleanup and deletion by the user if the external static provisioner is not used to manage the volume lifecycle._ Which means in my case I'll have to manually go and delete `/tmp/teamcitydata` from the node. I have the persistentVolumeReclaimPolicy on the persistent volume set to Delete which means after I delete the claim the volume will be deleted right after, but the data the volume held will persist. This tripped me up on docker-desktop because I didn't know how to directly access the docker-desktop kubernetes node. It also caused errors in Kubernetes when I deleted the claim. These errors caused the persistent volume to go into an error state and I'd have to manually delete the volume with `kubectl delete pv`. I discovered caused by using `kubectl describe pv`. The problem on docker-desktop was I was using a path that wasn't' shared by docker. Once I switched my hostPath to `/tmp` (which is shared) all was well and Kubernetes could clean up the volume after the claim was deleted.

TL:DR

  Use shared folders for hostPaths when using Kubernetes on docker-desktop.


### Sources

[run-single-instance-stateful-application](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/)

[Setting up a MySQL External Database for TeamCity](https://www.jetbrains.com/help/teamcity/setting-up-an-external-database.html?_ga=2.213872598.374019039.1565610915-964155662.1565610915#SettingupanExternalDatabase-MySQL)

[Kubernetes.io - Reclaiming volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming)