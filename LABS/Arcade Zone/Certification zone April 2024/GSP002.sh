#!/bin/bash

#Getting Started with Cloud Shell and gcloud

#variables 

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export REGION=us-central1
export ZONE=us-central1-a

#Task 1. Configuring your environment

gcloud config set compute/region $REGION

gcloud config get-value compute/region 

gcloud config set compute/zone $ZONE

gcloud config get-value compute/zone

#Finding project information

gcloud config get-value project

gcloud compute project-info describe --project $PROJECT_ID

echo -e "PROJECT ID: $PROJECT_ID\nZONE: $ZONE"

#Creating a virtual machine with the gcloud tool

gcloud compute instances create gcelab2 --machine-type e2-medium --zone $ZONE

#Task 2. Filtering command-line output

gcloud compute instances list
gcloud compute instances list --filter="name=('gcelab2')"
gcloud compute firewall-rules list
gcloud compute firewall-rules list --filter="network='default'"

gcloud compute firewall-rules list --filter="NETWORK:'default' AND ALLOW:'icmp'"

#Task 3. Connecting to your VM instance
gcloud compute ssh gcelab2 --strict-host-key-checking="no" --zone $ZONE --command="sudo apt install -y nginx && exit" 

#Task 4. Updating the firewall

gcloud compute firewall-rules list

gcloud compute instances add-tags gcelab2 --tags http-server,https-server

gcloud compute firewall-rules list --filter=ALLOW:'80'

curl http://$(gcloud compute instances list --filter=name:gcelab2 --format='value(EXTERNAL_IP)')

#Task 5. Viewing the system logs
gcloud logging logs list
gcloud logging logs list --filter="compute"
gcloud logging read "resource.type=gce_instance" --limit 5
gcloud logging read "resource.type=gce_instance AND labels.instance_name='gcelab2'" --limit 5
