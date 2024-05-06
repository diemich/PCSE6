#!/bin/bash


# Objectives
# In this lab, you learn how to perform the following tasks:

# Create an nginx web server on a vpc network
# Create tagged firewall rules
# Create a service account with IAM roles
# Explore permissions for the Network Admin and Security Admin roles 

#variables 
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export SCRIPT_LOCATION="./install-web.sh" #relative path to script
export SACCOUNT="Network-admin"
export SA_ROLE1="roles/compute.networkAdmin"
export SA_ROLE2="roles/compute.securityAdmin"
export BUCKET_NAME=${PROJECT_ID:0:9}$(tr -dc a-z0-9 </dev/urandom | head -c 6)-$(date +%F) #random bucket name including date of creation and Project


#OPTIONAL -BUCKET CREATION FOR START UP SCRIPT
gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --location=$REGION 
gcloud storage cp $SCRIPT_LOCATION gs://$BUCKET_NAME
gcloud storage ls 


#Task 1. Create the web servers
gcloud compute instances create blue \
--zone=$ZONE \
--machine-type=e2-medium \
--metadata=startup-script-url=gs://$BUCKET_NAME/install-web.sh 
--image=debian-12-bookworm-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \
--tags=web-server

gcloud compute instances create green \
--zone=$ZONE \
--machine-type=e2-medium \
--metadata=startup-script-url=gs://$BUCKET_NAME/install-web.sh 
--image=debian-12-bookworm-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \

#Task 2. Create the firewall rule

gcloud compute firewall-rules create allow-http-web-server \
--description="Allow incoming traffic on TCP port 80 and PING" \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:80,icmp \
--source-ranges=0.0.0.0/0 \
--target-tags=web-server

#Create a test-vm
gcloud compute instances create test-vm --machine-type=e2-micro --subnet=default --zone=$ZONE


#Test HTTP connectivity

#gcloud compute ssh test-vm


#Task 3. Explore the Network and Security Admin roles
#Create a service account

#service account creation 
gcloud iam service-accounts create Network-admin --display-name "Network-admin"

NET_ADM_SA=$(gcloud iam service-accounts list --format='value(email)' | grep Network)

#ROLE DEFINITION Compute Engine > Compute Network Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$NET_ADM_SA --role $SA_ROLE1

#Service account key creation 
gcloud iam service-accounts keys create credentials.json --iam-account=$NET_ADM_SA

#Authorize test-vm and verify permissions
gcloud compute copy-files ./credential.json test-vm:/HOME --zone=$ZONE

#Authorize the VM with the credentials you just uploaded:
gcloud auth activate-service-account --key-file credentials.json

#Try to list the available firewall rules:
gcloud compute firewall-rules list

#Try to delete the allow-http-web-server firewall rule:
gcloud compute firewall-rules delete allow-http-web-server

#Update service account and verify permissions