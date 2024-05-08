#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

# Objectives
# In this lab you learn how to perform the following tasks:

# Create HTTP and health check firewall rules
# Configure two instance templates
# Create two managed instance groups
# Configure and test an internal load balancer

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
#export SUBNET_A_REG=
#export SUBNET_B_REG=
export ZONE1=$ZONE
export ZONE2=

#Task 1. Configure HTTP and health check firewall rules
#Configure firewall rules to allow HTTP traffic to the backends and TCP traffic from the Google Cloud health checker.

#Explore the my-internal-app network
echo "Project configured: $PROJECT_ID"
echo "starting script... "

gcloud compute networks list


#Create the HTTP firewall rule
gcloud compute firewall-rules create app-allow-http \
--description="Allow incoming traffic on TCP port 80 on my-internal-app" \
--direction=INGRESS \
--priority=1000 \
--network=my-internal-app \
--action=ALLOW \
--rules=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=lb-backend

#Create the health check firewall rules
gcloud compute firewall-rules create app-allow-health-check \
--description="Allow " \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp \
--source-ranges=130.211.0.0/22,35.191.0.0/16 \
--target-tags=lb-backend

# #call the library and list firewall rules
 firewall_List 

# # Task 2. Configure instance templates and create instance groups
gcloud compute instance-templates create instance-template-1 \
--project=$PROJECT_ID \
--machine-type=e2-micro \
--network-interface=network=my-internal-app,subnet=subnet-a \
--metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh,enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--region=$REGION \
--tags=lb-backend \
--create-disk=auto-delete=yes,boot=yes,device-name=instance-template-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

#Configure the next instance template
gcloud compute instance-templates create instance-template-2 \
--project=$PROJECT_ID \
--machine-type=e2-micro \
--network-interface=network=my-internal-app,subnet=subnet-b \
--metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh,enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--region=$REGION \
--tags=lb-backend \
--create-disk=auto-delete=yes,boot=yes,device-name=instance-template-2,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any


#Create the managed instance groups
#Create a managed instance group in subnet-a and one subnet-b.
gcloud beta compute instance-groups managed create instance-group-1 \
--project=$PROJECT_ID \
--base-instance-name=instance-group-1 \
--template=projects/$PROJECT_ID/global/instanceTemplates/instance-template-1 \
--size=1 \
--zone=$ZONE1 \
--default-action-on-vm-failure=repair --no-force-update-on-repair --standby-policy-mode=manual \
--list-managed-instances-results=PAGELESS && gcloud beta compute instance-groups managed set-autoscaling instance-group-1 \
--project=$PROJECT_ID \
--zone=$ZONE1 \
--mode=on --min-num-replicas=1 --max-num-replicas=5 --target-cpu-utilization=0.8 --cool-down-period=45

gcloud beta compute instance-groups managed create instance-group-2 \
--project=$PROJECT_ID \
--base-instance-name=instance-group-2 \
--template=projects/$PROJECT_ID/global/instanceTemplates/instance-template-2 \
--size=1 \
--zone=$ZONE2 \
--default-action-on-vm-failure=repair --no-force-update-on-repair --standby-policy-mode=manual \
--list-managed-instances-results=PAGELESS && gcloud beta compute instance-groups managed set-autoscaling instance-group-2 \
--project=$PROJECT_ID \
--zone=$ZONE2 \
--mode=on --min-num-replicas=1 --max-num-replicas=5 --target-cpu-utilization=0.8 --cool-down-period=45

#Verify that VM instances are being created in both subnets and create a utility VM to access the backends' HTTP sites.
gcloud compute instances create utility-vm \
--zone=$ZONE1 \
--machine-type=e2-micro \
--image=debian-12-bookworm-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB \
--network=my-internal-app \
--subnet=subnet-a \
--stack-type IPV4_ONLY \
--private-network-ip 10.10.20.50



# Task 3. Configure the Internal Load Balancer
