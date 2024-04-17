#!/bin/bash

#VPC Network Peering
#GSP193

#gcloud auth list

#list projects
gcloud config list project

#choose a project 
gcloud config set project {projectname}

#variable definition 
export PROJECT_A=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export PROJECT_B=$(gcloud config list --format 'value(core.project)' 2>/dev/null)


#Task 1. Create a custom network in both projects

gcloud config set project $PROJECT_A

gcloud config set project $PROJECT_B


#Project-A / Project-B

#Create a custom network:
gcloud compute networks create network-a --subnet-mode custom

#Create a subnet within this VPC and specify a region and IP range by running:
gcloud compute networks subnets create network-a-subnet --network network-a \
    --range 10.0.0.0/16 --region us-east4

#Create a VM instance:
gcloud compute instances create vm-a --zone  --network network-a --subnet network-a-subnet --machine-type e2-small

#Run the following to enable SSH and icmp, because you'll need a secure shell to communicate with VMs during connectivity testing:
gcloud compute firewall-rules create network-a-fw --network network-a --allow tcp:22,icmp

#Task 2. Set up a VPC network peering session
gcloud compute networks peerings create peering-name --network=local-network --peer-network=peer-network --export-custom-routes --import-custom-routes --export-subnet-routes-with-public-ip --import-subnet-routes-with-public-ip


#Task 3. Test connectivity

gcloud compute instances list
gcloud compute instances ssh vm-b --zone=us-east4-c
gcloud compute ssh vm-b --zone=us-east4-c