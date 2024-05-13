#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Build a Secure Google Cloud Network: Challenge Lab
#GSP322
source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
#USERS
export $USER1="student-00-88feab478f8f@qwiklabs.net"
export $USER2="student-00-4d4bea13d4b7@qwiklabs.net"
Secret="RszKHwX3QWCS"
export PROJECT_ID2="qwiklabs-gcp-03-5aed952d4f85"


gcloud compute instances list

gcloud compute ssh centos-clean --zone=$ZONE --command="gcloud --version"

SA=$(gcloud iam service-accounts list --format="value(email)" --filter "displayName=devops")