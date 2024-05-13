#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Protect Cloud Traffic with BeyondCorp Enterprise (BCE) Security: Challenge Lab
#GSP373

#Challenge scenario
#In this challenge lab, you deploy a web application. You will then utilize IAP to protect access and authorize the Tester account access to the application.

source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)


# Task 1. Deploy a provided web application in REGION to Google Cloud
gcloud services enable iap.googleapis.com

#get the app from github
git clone --depth 1 --no-checkout https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples
git sparse-checkout set appengine/standard_python3/hello_world
git checkout

#Deploy the application to app engine
gcloud app create --project=$(gcloud config get-value project) --region=$REGION

gcloud app deploy

gcloud app browse


# Task 2. Configure OAuth Consent for the web application deployed


# Task 3. Configure the deployed web application to utilize IAP to protect traffic

export AUTH_DOMAIN=$(gcloud config get-value project).uc.r.appspot.com

echo $AUTH_DOMAIN

# Task 4. Authorize the test account access to the App Engine application



#Open your web browser to the home page address with /_gcp_iap/clear_login_cookie added to the end of the URL,
# as in https://iap-example-999999.appspot.com/_gcp_iap/clear_login_cookie