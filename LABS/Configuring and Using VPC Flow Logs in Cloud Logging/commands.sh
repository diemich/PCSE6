#!/bin/bash 

#variable definition

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)



#Task 1. Enable VPC flow logging
#To enable flow logging in two subnets, run the following commands in Cloud Shell:

gcloud compute networks subnets update default \
--region us-central1 --enable-flow-logs \
--logging-metadata=include-all

gcloud compute networks subnets update default \
--region europe-west1 --enable-flow-logs \
--logging-metadata=include-all


#To create three instances in different subnets (to be used for later testing), run the following commands:

gcloud compute instances create default-us-vm \
--machine-type e2-micro \
--zone=us-central1-a --network=default

gcloud compute instances create default-eu-vm \
--machine-type e2-micro \
--zone=europe-west1-b --network=default

gcloud compute instances create default-ap-vm \
--machine-type e2-micro \
--zone=asia-east1-a --network=default

#Task 2. Generate network traffic for testing

gcloud compute instances list

#When connected via SSH, issue the following commands:
gcloud compute ssh default-us-vm --zone="us-central1-a" 

gcloud compute ssh default-eu-vm --zone="europe-west1-b"

gcloud compute ssh default-ap-vm --zone="asia-east1-a"



#Task 7. Disable flow logging
gcloud compute networks subnets update default \
--region europe-west1 --no-enable-flow-logs
