
# Go API Deployment

This repo demonstrates how you can setup a complete CI/CD solution for an application developed using GoLang on Kubernetes.

## Introduction

### Architecture Overview



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
- Others can fork this repo and run for themselves.
- No need to setup hook triggers or commit watchers.
- Free.

#### How

So to demonstrate this, we are performing very basic lint check and also running go lang unit tests. You can checkout the workflow file called [static-tests.yml](.github/workflows/static-tests.yml) in this repo.

The GoLang tests are inside [test](./test) folder.

This action gets triggered when you create a pull request or add more commits to the already created PR.

#### Improvements

- Can add more variety of validators like code coverage, vulnerability scanners, code analysis(SonarQube), and lot of other awesome stuff!
- Add notifiations.

### Continious Delivery

#### Why

This is make your app ready to be deployed(this step does not actually deploy.)

#### How



### Continious Deployment






















kubectl create ns certmanager
kubectl create ns coresystem
kubectl create ns go-app

# helm upgrade --install --namespace certmanager cert-manager jetstack/cert-manager -f cert-manager/values.yaml --set installCRDs=true --debug 
helm upgrade --install --namespace certmanager cert-manager jetstack/cert-manager -f cert-manager/values.yaml --debug

helm upgrade --install go-deploy-chart godeploy/ --values godeploy/values.yaml --debug



helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update
# helm upgrade --namespace coresystem --install  ingress-nginx -f ingress-nginx/values.yaml


helm upgrade --install --namespace coresystem publicingress ingress-nginx/ingress-nginx  -f ingress-nginx/values.yaml --debug
