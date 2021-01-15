---
layout: post
title:  "Deploying Traefik as a Kubernetes Ingress Controller with TLS"
date:   2019-09-17 13:37:00
comments: true
modified: 2019-09-17
---

In this blog post I'll be documenting my several day struggle of figuring out how to deploy Traefik as a Kubernetes ingress controller with TLS. The end result of this article is an ingress controller running in kubernetes cluster on docker-desktop. The Traefik instance will be secured using TLS and will have a redirect rule to point all http traffic to https. Docker-desktop doesn't have a built-in ingress controller and Traefik is a great open source ingress controller you can use. I've been wanting to learn Kubernetes for awhile now and was struggling were to start. I reached out to a friend of mine (Josephe Beaudry) who's knowledgeable about it and he gave me this assignment. Before you get started make sure you have [docker desktop](https://www.docker.com/products/docker-desktop) installed and [Kubernetes enabled](https://thenewstack.io/how-to-install-docker-desktop-with-kubernetes-on-macos/).

* TOC
{:toc}

## Creating Roles for Role Based Access Control

Traefik interacts with the Kubernetes api and to do that it needs to be granted access. There are several ways to grant that access but the official Traefik documentation recommends a _RoleBindings per namespace enable to restrict granted permissions to the very namespaces only that Traefik is watching over, thereby following the least-privileges principle._ Save the below snippet as `traefik-rbac.yaml`.

```
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: traefik-ingress-controller
rules:
  - apiGroups:
      - ""
    resources:
      - services
      - endpoints
      - secrets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: traefik-ingress-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: traefik-ingress-controller
subjects:
- kind: ServiceAccount
  name: traefik-ingress-controller
  namespace: kube-system
```

```
kubectl apply -f traefik-rbac.yaml
```

## Deploy Traefik using a DaemonSet

Kubernetes is a container orchestrator and luckily enough for us Traefik is a container. The next step is to deploy the Traefik container using a daemon set. You could deploy the Traefik container as a pod or as part of a deployment. But, for my purposes using a daemonset has a few benefits (listed below) over a deployment. Save the below code snippet as `traefik-ds.yaml`.

* DaemonSets automatically scale to new nodes, when the nodes join the cluster, whereas Deployment pods are only scheduled on new nodes if required.
* DaemonSets ensure that only one replica of pods run on any single node. Deployments require affinity settings if you want to ensure that two pods don't end up on the same node.
* DaemonSets can be run with the NET_BIND_SERVICE capability, which will allow it to bind to port 80/443/etc on each host. This will allow bypassing the kube-proxy, and reduce traffic hops. Note that this is against the Kubernetes Best Practices Guidelines, and raises the potential for scheduling/scaling issues. Despite potential issues, this remains the choice for most ingress controllers.

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: traefik-ingress-controller
  namespace: kube-system
---
kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: traefik-ingress-controller
  namespace: kube-system
  labels:
    k8s-app: traefik-ingress-lb
spec:
  template:
    metadata:
      labels:
        k8s-app: traefik-ingress-lb
        name: traefik-ingress-lb
    spec:
      serviceAccountName: traefik-ingress-controller
      terminationGracePeriodSeconds: 60
      containers:
      - image: traefik:1.7.20
        name: traefik-ingress-lb
        ports:
        - name: http
          containerPort: 80
          hostPort: 80
        - name: admin
          containerPort: 8080
        securityContext:
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        args:
        - --api
        - --kubernetes
        - --logLevel=INFO
---
kind: Service
apiVersion: v1
metadata:
  name: traefik-ingress-service
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress-lb
  ports:
    - protocol: TCP
      port: 80
      name: web
    - protocol: TCP
      port: 8080
      name: admin
```

```
kubectl apply -f traefik-ds.yaml
```

## Deploy Traefik using Helm Chart

Helm is a package manager of sorts for Kubernetes applications. I won't lie, I don't yet fully understand all of what helm is doing. What I do know is, it creates the pods, services, etc... for the Traefik dashboard application and configures it. You'll have to install helm before you can run the following commands. 

### Installing Helm

Below are the commands for install helm on MacOS. For other setups check out the [installing helm docs](https://helm.sh/docs/using_helm/#installing-helm). Once helm is installed, you'll have to run `helm init` to configure the kubernetes cluster. 

```
brew install kubernetes-helm
helm init
```

### Deploy Traefik

A chart is a collection of files that describe a related set of Kubernetes resources. The chart can be fed a values file. The values file can be thought of as a list of parameters  to determine the configuration. Under the ssl: block is where I'm setting values to configure http to https redirection and the generation of self-signed certificates to be used to encrypt the traffic using TSL. You can learn more about the configuration options on the [GitHub page](https://github.com/helm/charts/tree/master/stable/traefik). Create a file called `values.yaml` with the below contents saved inside. 

```
dashboard:
  enabled: true
  domain: traefik-ui.minikube
ssl:
  enabled: true
  enforced: true
  generateTLS: true
kubernetes:
  namespaces:
    - default
    - kube-system
```

After you've created the `values.yaml` file you can deploy Traefik dashboard with helm by running the following commands.

```
helm install --values values.yaml stable/traefik
```

## Exposing the Traefik Web UI

At this point Traefik is deployed and ready to be used as an ingress controller for your kubernetes cluster. However, the web ui still needs to be exposed so you can access it and have a GUI to interact with your different ingresses. To expose the Traefik web UI, you need to deploy two more kubernetes resources; a service and an ingress for it. Create a file called `ui.yaml` and save the following content in it. Then create the resources with the kubectl command.

```
apiVersion: v1
kind: Service
metadata:
  name: traefik-web-ui
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress-lb
  ports:
  - name: web
    port: 80
    targetPort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-web-ui
  namespace: kube-system
spec:
  rules:
  - host: traefik-ui.minikube
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-web-ui
          servicePort: web
```

```
kubectl apply -f ui.yaml 
```

## Add a DNS Entry for the Traefik WebUI domain

The final step is to update your hosts file with the domain name specified in the values.yaml file that was fed to helm. _traefik-ui.minikube_ was the domain name used and it will need to resolve to the loopback Ip address for the kubernetes cluster running within docker-desktop. For MacOS and Linux the host file is located at `/etc/hosts` and for Windows it is `C:\Windows\System32\Drivers\etc\hosts`

```
127.0.0.1 traefik-ui.minikube
```

## Open up the WebUI

Now that all the necessary kubernetes resources have been deployed and the webUI is exposed via an ingress and DNS can resolve you can now access the Traefik dashboard by opening a web browser and going to `traefik-ui.minikube`. Since http to https redirection was specified in the helm chart values it will prompt you with a certificate warning and redirect you to the https entrypoint. 


### Sources 

[Traefik Helm Chart GitHub Repo](https://github.com/helm/charts/tree/master/stable/traefik)

[Official Traefik Kubenetes Ingress Controller docs](https://github.com/helm/charts/tree/master/stable/traefik)

[Docker for Mac with Kubernetes — Ingress Controller with Traefik](https://medium.com/@thms.hmm/docker-for-mac-with-kubernetes-ingress-controller-with-traefik-e194919591bb)

