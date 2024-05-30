#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Cloud Monitoring: Qwik Start
#GSP089

# Objectives
# In this lab, you learn how to:
# Monitor a Compute Engine virtual machine (VM) instance with Cloud Monitoring.
# Install monitoring and logging agents for your VM

source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)




gcloud compute instances create lamp-1-vm \
--project=qwiklabs-gcp-04-677444c65081 \
--zone=us-west1-c \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true 
--maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=838532309321-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=lamp-1-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240515,mode=rw,size=10,type=projects/qwiklabs-gcp-04-677444c65081/zones/us-west1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
