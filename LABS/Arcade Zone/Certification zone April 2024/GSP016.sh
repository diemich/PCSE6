#!/bin/bash

#Networking 101

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export REGION_A=us-central1
export REGION_B=us-east4
export REGION_C=europe-west1
export ZONE_A=us-central1-b
export ZONE_B=us-east4-c
export ZONE_C=europe-west1-c



#Set your region and zone
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION


#Task 1. Review the default network

gcloud compute networks subnets list --sort-by=NETWORK | grep default

#Task 2. Creating a custom network


#Task 4. Create custom network with Cloud Shell
gcloud compute networks create taw-custom-network --subnet-mode custom

#Now create subnets for your new custom network. You'll create three of them.
gcloud compute networks subnets create subnet-$REGION_A \
   --network taw-custom-network \
   --region $REGION_A \
   --range 10.0.0.0/16


gcloud compute networks subnets create subnet-$REGION_B \
   --network taw-custom-network \
   --region $REGION_B \
   --range 10.1.0.0/16

gcloud compute networks subnets create subnet-$REGION_C \
   --network taw-custom-network \
   --region $REGION_C \
   --range 10.2.0.0/16 

#List your networks:
gcloud compute networks subnets list \
   --network taw-custom-network


#Task 5. Adding firewall rules

#HTTP
gcloud compute firewall-rules create nw101-allow-http \
--allow tcp:80 --network taw-custom-network --source-ranges 0.0.0.0/0 \
--target-tags http

#ICMP
gcloud compute firewall-rules create "nw101-allow-icmp" --allow icmp --network "taw-custom-network" --target-tags rules

#Internal Communication
gcloud compute firewall-rules create "nw101-allow-internal" --allow tcp:0-65535,udp:0-65535,icmp --network "taw-custom-network" --source-ranges "10.0.0.0/16","10.2.0.0/16","10.1.0.0/16"

#SSH
gcloud compute firewall-rules create "nw101-allow-ssh" --allow tcp:22 --network "taw-custom-network" --target-tags "ssh"

#RDP
gcloud compute firewall-rules create "nw101-allow-rdp" --allow tcp:3389 --network "taw-custom-network"


#list firewall rules
gcloud compute firewall-rules list --sort-by=NETWORK


#Task 6. Connecting to your lab VMs and checking latency
#Creating a VM in each zone

gcloud compute instances create us-test-01 \
--subnet subnet-$REGION_A \
--zone $ZONE_A \
--machine-type e2-standard-2 \
--tags ssh,http,rules

gcloud compute instances create us-test-02 \
--subnet subnet-$REGION_B \
--zone $ZONE_B \
--machine-type e2-standard-2 \
--tags ssh,http,rules

gcloud compute instances create us-test-03 \
--subnet subnet-$REGION_C \
--zone $ZONE_C \
--machine-type e2-standard-2 \
--tags ssh,http,rules
