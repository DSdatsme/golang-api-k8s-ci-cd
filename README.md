
# Go API Deployment

This repo demonstrates how you can setup a complete CI/CD solution for an application developed using GoLang on Kubernetes.

## Introduction

> This repo is implemented in such a way that it should be possible to deploy and PoC on any k8s cluster with little to no change in configs.

### Goals

- Automatic container builds for GoLang app
- TLS offboarding for multiple service
- Infra as Code

### Architecture Overview[WIP]

[TODO]

- add basic diagrams
- components created
- how request flows

### Technologies Used

I wanted to keep the solution simple so that it can be used easily and by many engineers.

- GoLang ->  for basic http server
- Docker -> for packing the go app
- Kubernetes -> for orchestrating containers
- Helm -> for templating K8s configs
- cert-manager -> for generating SSL certs
- ingress-nginx -> for serving app traffic and performing TLS termination.
- Github Actions -> for implementing CI/CD

## Setup

The following is category explanation of different stages/components.

### Continious Integration

#### What

This is a steup we can perform all types of code validation or analysis based on the usecase.

#### Why

- Here we decided to go with GitHub actions as its easy to setup and implement.
- Other GitHub users can fork this repo and run for themselves.
- No need to setup hook triggers or commit watchers.
- Free.
- Will work for private repos as well without no additional effort.

#### How

So to demonstrate this, we are performing very basic lint check and also running go lang unit tests. You can checkout the workflow file called [static-tests.yml](.github/workflows/static-tests.yml) in this repo.

The GoLang tests are inside [test](./test) folder.

This action gets triggered when you create a pull request or add more commits to the already created PR.

#### Improvements

- Can add more variety of validators like code coverage, vulnerability scanners, code analysis(SonarQube), and lot of other awesome stuff!
- Add notifiations.
- Test after docker images are built.

### Continious Delivery

#### What

This is make your app ready to be deployed(this step does not actually deploy.)

#### Why

- Again, since we wanted master merged based trigger, so we chose GitHub actions.

#### How

- The goal of CD here is just to create a Docker image and push it to docker registry of your choice. Here we choose a public registry on Docker Hub as its free and easy to demonstrate the usecase.
- This is a GitHub action that gets triggered automatically when there is a commit in Master branch. Generally in prod repos, master/main branch is locked, we are assuming the same here, any master/main branch will only come from pull requests.
- So when a PR is merged this action is triggered, and this runs a docker build command and pushes to Docker Hub.
- The action used for CD is [docker-publish.yml](.github/workflows/docker-publish.yml)
- Since this is pushing to Docker Hub, you need to add `DOCKERHUB_TOKEN` and `DOCKERHUB_USERNAME` to your GitHub repo secrets.

### Continious Deployment[WIP]

#### What

The goal is to make your dockerfile live. The dockerfile build in continious delivery step is deployd on k8s cluster.

#### Why

- GitHub actions, no need to manage any server.

#### How

- For CD we use github action [deploy-app.yml](.github/workflows/docker-publish.yml) which basically runs our custom helm chart present in this repo.

#### Improvements

- If its a prod like setup, you can go for Jenkins, Harness, ArgoCD, etc.
- If you want something free, you can also explore options like TravisCI, CircleCI, etc.

### Go App

Since this is a demo repo, we have create a demo http app inside `basicserver` directory.

The structure of GoApp is in such a way that module file and main file has to be outside, hence there exists `go.mod` and `main.go` in the root dir of the repo.

So to run the app locally just run

```bash
go run main.go
```

If you wish to build the binary and then test, you can build and run it using the following command

```bash
go build -o myserver
./myserver
```

### DNS

You will need a DNS which you can modify and add am IP to it. This is required as we will create SSL cert and also perform TLS ofboarding using it.

In this repo we are using `noip.com` as it provides a free subdomain, and thats enough for us to generate a new SSL cert.

### Cert Manager

#### What

- This component is used to generate SSL certs that will enable us to serve our GoLang app on HTTPS.
- Cert manager generates Lets Encrypt certs, which are trusted by most of the modern browsers.

#### Why

- Cert manager automatically updates the cert when cert is about 30days before expiry, hence there is no overhead of cert rotation.
- Amazing integration with ingress-nginx for issuing new certs.
- Helm chart becasue its easier to deploy and tweak.

#### How

- This is a helm chart using which we are setting up a cert manager pods, which are responsible for issuing SSL certs on any certificate CRD or ingress's TLS block.
- Since this repo has generic k8s config so it can be deployed on any k8s cluster. So to make things generic for cert issuer, we are doing HTTP challenge for Lets Encrypt cert generation.
- To setup cert manager in your cluster run the following commands.

```bash
# creating a namespace for certmanager
kubectl create namespace certmanager
# installing all required certmanager components
helm upgrade --install --namespace certmanager cert-manager jetstack/cert-manager -f cert-manager/values.yaml --debug
# Setting up a Cluster issuer
kubectl apply -f cert-manager/certificate-issuer.yaml
```

- If you want cert issuer only for specific namespaces in your cluster, then create object of kind `Issuer` in your desired namespace so that it remains restriced to that namespace.
- Here, we just want to provide cert manager cluster wide hence we chose `ClusterIssuer`.

- If you wish to test the cert manager is working or now, you can modify the k8s [config](cert-manager/certificate-issuer.yaml) which is commented and apply it. This will generate secrets in your namespace and also you can check the status of the certificate, it should be in ready state. The following are some commands you can use to check:

```bash
# create certificate
kubectl apply -f cert-manager/certificate-issuer.yaml
# check if secret is generated
kubectl get secrets --namespace go-app | grep no-secret-name
# check if certificate is created, the output will should show certificate in `READY` state.
kubectl get certificate --namespace go-app
```

- To remove cert manager from cluster

```bash
helm uninstall  --namespace certmanager cert-manager
```

### Ingress Nginx

#### What

- This is a wonderful implementation of Nginx for k8s where using k8s objects you can add nginx rules.

#### Why

- As per the usecase we want to do TLS termination but it can be for any service you deploy.
- So that means, there can be many domains/subdomains in future, you want to support for any.
- You can have a different loadbalancer for each and every service you deploy and ask LB to TLS terminate, but it will be quite expensive for small scale business as you are paying for each and every LB.
- Where as in case of Nginx ingress, you are just creating a single LB for serving all of your cluster's public apps, and your Nginx ingress pods will perform TLS termination.

#### How

- Values file for ingress is stored in [ingress-nginx](./ingress-nginx/ingress-values.yaml) folder.
- To deploy ingress, we are using public helm chart, the following are the commands to setup:

```bash
# creating a namespace for ingress-nginx
kubectl create namespace coresystem
# setting up ingress
helm upgrade --install --namespace coresystem publicingress ingress-nginx/ingress-nginx -f ingress-nginx/values.yaml --debug
# get loadbalancer IP, there you will see nginx controller of type LB
kubectl get svc --namespace coresystem
```

- This will create a loadbalancer, you can use that DNS or IP and add it to your DNS manager, for our demo its noip.com.

- To remove nginx ingress

```bash
helm uninstall --namespace coresystem publicingress
```

### Go App Deploy

#### What

The process on how to deploy your GoLang api to cluster.
#### Why

- Creating helm charts was a good option as that avoids config repition and adds templating functionality with vars. So using this you can change a value at one place and it automatically updates everywhere.

#### How

- The helm chart for go app is in `godeploy` folder.
- This chart is the modification of the boiler plate chart generated by command

```bash
helm create godeploy
```

- All the components related to GoLang app are deployed to namespace `go-app`.

```bash
kubectl create ns go-app
```

- To deploy this chart run the following command:

```bash
helm upgrade --install go-deploy-chart godeploy/ --values godeploy/values.yaml --debug
```

- This chart also creates an Ingress object of class `publicingress` which we deployed in ingress-nginx section.
- If you look at the values file we are adding `ingress.tls.hosts`, this will basically ask cert manager to request Lets Encrypt to geneate certs for those domains.
- After certs are generated, ingress controller reloads the config and is ready to servce HTTPS!

- To uninstall your helm, you can run following

```bash
helm uninstall --namespace go-app go-deploy-chart
```

#### Improvements

- Deployments can have proper nodeSelectors, so that app gets deployed on secure/desired subnets.

### Helper Folder

#### What

This is a folder(`helpers`) where there are some random useful script or config that might be useful in future.

Files have comments inside them explaining what are they and why its used.
