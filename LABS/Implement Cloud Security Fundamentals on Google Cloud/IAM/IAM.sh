#!/bin/bash

#variable definition 
#
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export BUCKET_NAME=${PROJECT_ID:0:9}$(date +%F)
export USER1=
export USER2=
export ROLE=


#Sign in to Cloud Console as the first user

gcloud init --no-browser --skip-diagnostics #use alias gcinit

gcloud auth login --no-browser

#list users 
gcloud auth list 

#change to user2
gcloud config set account "${USER2}"

#change to user1
gcloud config set account "$USER1"

gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter="bindings.members:user:${USER1}" --format='value(bindings.role)'

gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter="bindings.members:user:${USER2}" --format='value(bindings.role)'


echo "Setting up bucket name to: " $BUCKET_NAME

echo "Creating bucket $BUCKET_NAME on $PROJECT_ID"

gcloud storage buckets create gs://$BUCKET_NAME

echo " Creating sample file"
touch sample.txt && lscpu >> sample.txt 

echo " Copying Sample file to bucket"

gcloud storage cp sample.txt gs://$BUCKET_NAME 


#Verify project viewer access
gcloud config set account "$USER2"
gcloud storage ls --recursive gs://$BUCKET_NAME





#Remove project access
gcloud projects remove-iam-policy-binding "${PROJECT_ID}" --member="${USER1}" --role="roles/viewer"

#Verify that Username 2 has lost access

gcloud config set account "{$USER2}"
gcloud storage ls --recursive gs://$BUCKET_NAME

#Add Storage permissions

gcloud projects add-iam-policy "{$PROJECT_ID}" --member="${user2}" --role='roles/storage.objectViewer'







unset BUCKET_NAME PROJECT_ID USER1 USER2