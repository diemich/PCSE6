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
#NETWORK & SUBNETS
export ACME_VPC="acme-vpc"
export MGMT_SUBNET=192.168.10.0/24
export APP_SUBNET=192.168.11.0/24
#NETWORK TAGS
export IAP_TAG="accept-ssh-iap-ingress-ql-623"
export HTTP_TAG="accept-http-ingress-ql-623"
export MGMT_SSH_TAG="accept-ssh-internal-ingress-ql-623"
#FIREWALL RULES
export IAP_RULE_NAME="accept-ssh-iap-ingress"
export HTTP_RULE_NAME="accept-http-ingress"
export MGMT_SSH_RULE="accept-ssh-internal-ingress"

#gcloud services enable iap.googleapis.com
#gcloud compute backend-services update juice-shop --global --iap=enabled

# Suggested order of action.
# 1-Remove the overly permissive rules
ls_firewall
gcloud compute firewall-rules delete open-access

# 2-Start the bastion host instance
ls_instance
gcloud compute instances start bastion --zone=$ZONE

# 3-Create a firewall rule that allows SSH (tcp/22) from the IAP service and add network tag on bastion
gcloud compute firewall-rules create $IAP_RULE_NAME \
--network $ACME_VPC \
--source-ranges 35.235.240.0/20 \
--target-tags $IAP_TAG \
--allow tcp:22

#network tags
gcloud compute instances add-tags bastion --tags $IAP_TAG

# 4-Create a firewall rule that allows traffic on HTTP (tcp/80) to any address and add network tag on juice-shop

gcloud compute firewall-rules create $HTTP_RULE_NAME \
--network $ACME_VPC \
--source-ranges 0.0.0.0/0 \
--allow=tcp:80 \
--description="Allow incoming traffic on TCP port 80" \
--direction=INGRESS \
--target-tags $HTTP_TAG

# 5-Create a firewall rule that allows traffic on SSH (tcp/22) from acme-mgmt-subnet

gcloud compute firewall-rules create $MGMT_SSH_RULE \
--network $ACME_VPC \
--source-ranges $MGMT_SUBNET \
--allow tcp:22 \
--target-tags $MGMT_SSH_TAG

gcloud compute instances add-tags juice-shop --tags "$HTTP_TAG","$MGMT_SSH_TAG"
#gcloud compute instances add-tags bastion --tags "$MGMT_SSH_TAG"

ls_instance

# 6-SSH to bastion host via IAP and juice-shop via bastion
gcloud compute ssh bastion \
--zone $ZONE \
--tunnel-through-iap \
--command="gcloud compute ssh juice-shop --zone=$ZONE --internal-ip"

#THE LAST PART OF THE LAB WILL FAIL IF THE FLAG "--internal-ip" IS NOT SPECIFIED
