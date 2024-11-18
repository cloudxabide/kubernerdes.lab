# kubernerdes.lab
Lab environment consisting of Amazon EKS Anywhere and VMware vSphere for hosting containers and VMs

## Status
Status:  Work In Progress

I am redoing my "lab content" and separating the different environments in to repos 
[eksa.kubernerdes.lab](../eksa.kubernerdes.lab) (original repo)
rancher.kubernerdes.lab


## Overview
This implementation pattern represents an "edge deployment" facilitating a hybrid cloud architecture.  This will enabling you to run containers and virtual machines on gear that requires lower resources (space, power, cooling, etc...) in an enclave capable of being independent of external resources.

I, intentionally, did not do any of this work using Terraform or Ansible, etc.. and instead used BASH shell scripting so that you can see what is actually occurring (rather than simply seeing: SUCCESS! after some magic stuff happens)

![Environment Overview](Images/Kubernerdes-Lab-Overview.drawio.png)

## Purpose 
This repository will provide an opinionated deployment to create an environemnt to run containers and virtual machines on commodity hardware using Open Source Software where possible.  In general, this approach will rely on the standard implementation guidance and focus on the integration of all the different technologies.


## Getting Started

Firstly, you should grab the example "ENV.vars" file and update it with your own values (or continue using the user/repo from this repo

replace <GIT_OWNER> with the Git Owner where the repo is being stored, then run the following:
```
git clone https://github.com/<GIT_OWNER>/kubernerdes.lab.git
cd kubernerdes.lab
vi Files/ENV.vars
. ./Files/ENV.vars
cd Scripts
```

I have created the scripts using the old Init Script notation of numerically numbered files.  You can decided which ones you would like to run, or not.


