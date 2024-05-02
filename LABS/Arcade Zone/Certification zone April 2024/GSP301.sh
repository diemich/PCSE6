#!/bin/bash

#Deploy a Compute Instance with a Remote Startup Script: Challenge Lab

#variables 
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export BUCKET_NAME=${PROJECT_ID:0:9}$(tr -dc a-z0-9 </dev/urandom | head -c 6)-$(date +%F) #random bucket name including date of creation and Project
export SCRIPT_LOCATION="./startup-scritps/install-web.sh" #relative path to script
export INSTANCE_NAME=gsp301


#Enabling serial port access
gcloud compute project-info add-metadata \
    --metadata serial-port-enable=TRUE

#Task 1. Create a storage bucket

gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --location=$REGION 
gcloud storage ls 
gcloud storage cp $SCRIPT_LOCATION gs://$BUCKET_NAME

#Task 2. Create a VM instance with a remote startup script
gcloud compute instances create $INSTANCE_NAME \
--zone=$ZONE \
--machine-type=e2-medium \
--metadata=startup-script-url=gs://$BUCKET_NAME \
--image=debian-11-bullseye-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \
--tags=webserver

#SERIAL CONSOLE
gcloud compute instances add-metadata $INSTANCE_NAME \
    --metadata serial-port-enable=TRUE


#Task 3. Create a firewall rule to allow traffic (80/tcp)
gcloud compute firewall-rules create webserver \
--allow=tcp:80 \
--description="Allow incoming traffic on TCP port 80" \
--direction=INGRESS \
--target-tags webserver

#Task 4. Test that the VM is serving web content

#curl http://$(gcloud compute instances list --filter=name:$INSTANCE_NAME --format='value(EXTERNAL_IP)')

export PUBLIC_IP=$(gcloud compute instances list --filter=name:$INSTANCE_NAME --format='value(EXTERNAL_IP)')

curl -f -LI http://$PUBLIC_IP | grep HTTP


#gcloud compute connect-to-serial-port $INSTANCE_NAME --port=1