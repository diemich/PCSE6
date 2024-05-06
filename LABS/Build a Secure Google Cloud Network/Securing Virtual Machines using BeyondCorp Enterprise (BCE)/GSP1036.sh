#!/bin/bash

#Securing Virtual Machines using BeyondCorp Enterprise (BCE)

#In this lab, you will explore how you can use BeyondCorp Enterprise (BCE) and 
#Identity-Aware Proxy (IAP) TCP forwarding to enable administrative access to 
#VM instances that do not have external IP addresses or do not permit direct access over the internet.

#What You’ll Do
# Enable IAP TCP forwarding in your Google Cloud project
# Create Linux and Windows Instances
# Test connectivity to your Linux and Windows instances
# Configure the required firewall rules for BCE
# Grant permissions to use IAP TCP forwarding
# Demonstrate tunneling using SSH and RDP connections

#variables 
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export VM_NAME_LINUX=linux-iap
export VM_NAME_WIN=windows-iap
export VM_NAME_WIN=windows-connectivity


#Task 1. Enable IAP TCP forwarding in your Google Cloud project

gcloud services enable iap.googleapis.com

#Task 2. Create Linux and Windows Instances

gcloud compute instances create $VM_NAME_LINUX \
--network-interface network=default,subnet=default \
--no-address \
--zone=$ZONE \
--machine-type=e2-medium \
--image=debian-11-bullseye-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \
--tags=webserver

#gcloud compute images list --project windows-cloud --no-standard-images 

gcloud compute instances create $VM_NAME_WIN \
--network default \
--subnet default \
--no-address \
--image-project windows-cloud \
--image-family [IMAGE_FAMILY] \
--no-shielded-secure-boot

#Task 3. Configure the required firewall rules for BCE

gcloud compute firewall-rules create allow-ingress-from-iap \
--direction=ingress \
--network=[NETWORK] \
--action=ALLOW \
--rules=tcp:1688 \
--destination-ranges=35.190.247.13/32 \
--priority=0

gcloud compute firewall-rules create allow-ingress-from-iap \
--direction=INGRESS \
--priority=0 \
--network=default \
--action=ALLOW \
--rules=tcp:22,tcp:3389 \
--source-ranges=35.235.240.0/20

#Task 4. Grant permissions to use IAP TCP forwarding

#Compute Engine default service account
gcloud iam service-accounts list ./ | grep developer

#Task 5. Use IAP Desktop to Connect to the Windows and Linux Instances
gcloud compute ssh $VM_NAME_LINUX \
--region $REGION \
--tunnel-through-iap

#gcloud beta compute --project "qwiklabs-gcp-01-83ae6c9e5510" reset-windows-password "windows-connectivity" --zone "us-east1-d"

#Task 6. Demonstrate tunneling using SSH and RDP connections
#Start a ssh tunnel to connect to remote desktop 
gcloud compute start-iap-tunnel windows-iap 3389 --local-host-port=localhost:0  --zone=us-east1-d