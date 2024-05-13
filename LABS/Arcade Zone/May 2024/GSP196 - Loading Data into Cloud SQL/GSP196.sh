#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Loading Data into Cloud SQL
#GSP196

source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export BUCKET=${PROJECT_ID}-ml


# Task 1. Prepare your environment
# This lab uses a set of code samples and scripts developed for the Data Science on the Google Cloud Platform, 2nd Edition book from O'Reilly Media, Inc. 
# It covers the configuration of Cloud SQL and importing data tasks covered in the first part of Chapter 3, "Creating Compelling Dashboards". 
# You clone the sample repository used in Chapter 2 from Github to the Cloud Shell and carry out all of the lab tasks from there.

#Clone the Data Science on Google Cloud repository
git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/

#Change to the repository directory:
cd data-science-on-gcp/03_sqlstudio

#Create the environment variables used later in the lab for your project ID and the storage bucket that contains your data:

#Enter following command to stage the file into Cloud Storage bucket:
gsutil cp create_table.sql \
gs://$BUCKET/create_table.sql

#Task 2. Create a Cloud SQL instance
#Enter the following commands to create a Cloud SQL instance:

gcloud sql instances create flights \
--database-version=POSTGRES_13 --cpu=2 --memory=8GiB \
--region=$REGION --root-password=Passw0rd

#Create an environment variable with the Cloud Shell IP address:
export ADDRESS=$(curl -s http://ipecho.net/plain)/32

gcloud sql instances patch flights --authorized-networks $ADDRESS


#Use a PostgreSQL client on a local machine or a Compute Engine VM
# sudo apt-get update
# sudo apt-get install postgresql-client




#Create database and table


