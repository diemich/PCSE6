#!/bin/bash

# Objectives
# In this lab, you learn how to perform the following tasks:

# Create HTTP and health check firewall rules
# Configure two instance templates
# Create two managed instance groups
# Configure an HTTP Load Balancer with IPv4 and IPv6
# Stress test an HTTP Load Balancer
# Denylist an IP address to restrict access to an HTTP Load Balancer

#variables 
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
#export SCRIPT_LOCATION="./install-web.sh" #relative path to script
#export SACCOUNT="Network-admin"
#export SA_ROLE1="roles/compute.networkAdmin"
#export SA_ROLE2="roles/compute.securityAdmin"
#export BUCKET_NAME=${PROJECT_ID:0:9}$(tr -dc a-z0-9 </dev/urandom | head -c 6)-$(date +%F) #random bucket name including date of creation and Project

# Task 1. Configure HTTP and health check firewall rules
# Configure firewall rules to allow HTTP traffic to the backends and TCP traffic from the Google Cloud health checker.

gcloud compute firewall-rules create default-allow-http \
--description="Allow incoming traffic on TCP port 80 and PING" \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=http-server

# Create the health check firewall rules
# Health checks determine which instances of a load balancer can receive new connections. 
# For HTTP load balancing, the health check probes to your load balanced instances come from addresses in the ranges 130.211.0.0/22 and 35.191.0.0/16.
#  Your firewall rules must allow these connections.

gcloud compute firewall-rules create default-allow-health-check \
--description="Allow " \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp \
--source-ranges=130.211.0.0/22,35.191.0.0/16 \
--target-tags=http-server

# Task 2. Configure instance templates and create instance groups
# A managed instance group uses an instance template to create a group of identical instances. Use these to create the backends of the HTTP Load Balancer.

#Configure the instance templates
#An instance template is an API resource that you use to create VM instances and managed instance groups. 
#Instance templates define the machine type, boot disk image, subnet, labels, and other instance properties.

gcloud compute instance-templates create us-east1-template --project=qwiklabs-gcp-01-3f7e126d7a31 \
--machine-type=e2-micro \
--network-interface=network-tier=PREMIUM,subnet=default \
--metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=480969220075-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--region=us-east1 \
--tags=http-server \
--create-disk=auto-delete=yes,boot=yes,device-name=us-east1-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

gcloud compute instance-templates create europe-west1-template --project=qwiklabs-gcp-01-3f7e126d7a31 \
--machine-type=e2-micro \
--network-interface=network-tier=PREMIUM,subnet=default \
--metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=480969220075-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--region=europe-west1 \
--tags=http-server \
--create-disk=auto-delete=yes,boot=yes,device-name=europe-west1-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

gcloud beta compute instance-groups managed create us-east1-mig \
--project=qwiklabs-gcp-01-3f7e126d7a31 \
--base-instance-name=us-east1-mig \
--template=projects/qwiklabs-gcp-01-3f7e126d7a31/global/instanceTemplates/us-east1-template \
--size=1 \
--zones=us-east1-b,us-east1-c,us-east1-d \
--target-distribution-shape=EVEN \
--instance-redistribution-type=PROACTIVE \
--default-action-on-vm-failure=repair \
--no-force-update-on-repair \
--standby-policy-mode=manual \
--list-managed-instances-results=PAGELESS && gcloud beta compute instance-groups managed set-autoscaling us-east1-mig \
--project=qwiklabs-gcp-01-3f7e126d7a31 \
--region=us-east1 \
--mode=on \
--min-num-replicas=1 \
--max-num-replicas=2 \
--target-cpu-utilization=0.8 \
--cool-down-period=45

gcloud beta compute instance-groups managed create europe-west1-mig \
--project=qwiklabs-gcp-01-3f7e126d7a31 \
--base-instance-name=europe-west1-template \
--template=projects/qwiklabs-gcp-01-3f7e126d7a31/global/instanceTemplates/europe-west1-template \
--size=1 \
--zones=europe-west1-b,europe-west1-d,europe-west1-c \
--target-distribution-shape=EVEN \
--instance-redistribution-type=PROACTIVE \
--default-action-on-vm-failure=repair \
--no-force-update-on-repair \
--standby-policy-mode=manual \
--list-managed-instances-results=PAGELESS && gcloud beta compute instance-groups managed set-autoscaling europe-west1-mig \
--project=qwiklabs-gcp-01-3f7e126d7a31 \
--region=europe-west1 \
--mode=on \
--min-num-replicas=1 \
--max-num-replicas=2 \
--target-cpu-utilization=0.8 \
--cool-down-period=45


#Task 3. Configure the HTTP Load Balancer

gcloud compute backend-services list

gcloud compute instances create siege-vm \
--zone=$ZONE3 \
--machine-type=e2-micro \
--image=debian-12-bookworm-v20240415 \
--image-project=debian-cloud \
--boot-disk-size=10GB 