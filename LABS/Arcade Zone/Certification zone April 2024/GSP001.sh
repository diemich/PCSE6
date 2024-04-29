#!/bin/bash

#variables 

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export REGION=us-central1
export ZONE=us-central1-b

#Project Region 
gcloud config set compute/region us-central1

#TASKS
#Task 1. Create a new instance from the Cloud console 
#Task 2. Install an NGINX web server


gcloud compute instances create gclab \
--zone=$ZONE \
--machine-type=e2-medium \
--metadata=startup-script=\#\!\ /bin/bash$'\n'sudo\ apt-get\ update$'\n'sudo\ apt-get\ -qq\ -y\ install\ nginx \
--image=debian-11-bullseye-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \
--tags=webserver

#Firewall rule to allow connection on port 80 
gcloud compute firewall-rules create webserver \
--allow=tcp:80 \
--description="Allow incoming traffic on TCP port 80" \
--direction=INGRESS \
--target-tags webserver


#Task 3. Create a new instance with gcloud
gcloud compute instances create gcelab2 --machine-type e2-medium --zone=$ZONE




