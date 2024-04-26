#!/bin/bash

#variable definition
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)


#Enable the Service Networking API:
gcloud services enable servicenetworking.googleapis.com \
    --project=$PROJECT_ID

#Enable the Cloud IDS API:
gcloud services enable ids.googleapis.com \
    --project=$PROJECT_ID

#Enable the Cloud Logging API:
gcloud services enable logging.googleapis.com \
    --project=$PROJECT_ID

#Task 2. Build the Google Cloud networking footprint

#create a VPC
gcloud compute networks create cloud-ids \
--subnet-mode=custom

#Add a subnet to the VPC for mirrored traffic in us-east1:
gcloud compute networks subnets create cloud-ids-useast1 \
--range=192.168.10.0/24 \
--network=cloud-ids \
--region=us-east1

#Configure private services access:
gcloud compute addresses create cloud-ids-ips \
--global \
--purpose=VPC_PEERING \
--addresses=10.10.10.0 \
--prefix-length=24 \
--description="Cloud IDS Range" \
--network=cloud-ids

#Create a private connection:
gcloud services vpc-peerings connect \
--service=servicenetworking.googleapis.com \
--ranges=cloud-ids-ips \
--network=cloud-ids \
--project=$PROJECT_ID

#Task 3. Create a Cloud IDS endpoint

#To create a Cloud IDS endpoint

gcloud ids endpoints create cloud-ids-east1 \
--network=cloud-ids \
--zone=us-east1-b \
--severity=INFORMATIONAL \
--async

#Verify that the Cloud IDS endpoint is initiated

gcloud ids endpoints list --project=$PROJECT_ID


#Task 4. Create Firewall rules and Cloud NAT

#To create the allow-http-icmp rule
gcloud compute firewall-rules create allow-http-icmp \
--direction=INGRESS \
--priority=1000 \
--network=cloud-ids \
--action=ALLOW \
--rules=tcp:80,icmp \
--source-ranges=0.0.0.0/0 \
--target-tags=server

#Create the allow-iap-proxy rule
gcloud compute firewall-rules create allow-iap-proxy \
--direction=INGRESS \
--priority=1000 \
--network=cloud-ids \
--action=ALLOW \
--rules=tcp:22 \
--source-ranges=35.235.240.0/20

#To create a Cloud Router, run the following command:
gcloud compute routers create cr-cloud-ids-useast1 \
--region=us-east1 \
--network=cloud-ids

#To configure a Cloud NAT, run the following command:
gcloud compute routers nats create nat-cloud-ids-useast1 \
--router=cr-cloud-ids-useast1 \
--router-region=us-east1 \
--auto-allocate-nat-external-ips \
--nat-all-subnet-ip-ranges

#Task 5. Create two virtual machines

#To create a virtual machine to be a server mirroring to Cloud IDS
gcloud compute instances create server \
--zone=us-east1-b \
--machine-type=e2-medium \
--subnet=cloud-ids-useast1 \
--no-address \
--private-network-ip=192.168.10.20 \
--metadata=startup-script=\#\!\ /bin/bash$'\n'sudo\ apt-get\ update$'\n'sudo\ apt-get\ -qq\ -y\ install\ nginx \
--tags=server \
--image=debian-10-buster-v20210512 \
--image-project=debian-cloud \
--boot-disk-size=10GB


#Create a virtual machine to be a client sending attack traffic:
gcloud compute instances create attacker \
--zone=us-east1-b \
--machine-type=e2-medium \
--subnet=cloud-ids-useast1 \
--no-address \
--private-network-ip=192.168.10.10 \
--image=debian-10-buster-v20210512 \
--image-project=debian-cloud \
--boot-disk-size=10GB


#Prepare your server
gcloud compute ssh server --zone=us-east1-b --tunnel-through-iap

sudo systemctl status nginx

cd /var/www/html/

echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' | sudo tee eicar.file


#Task 6 Create a Cloud IDS packet mirroring policy

#1.To verify that your Cloud IDS endpoint is active, in Cloud Shell,
#run the following command to show the current state of the Cloud IDS endpoint:
gcloud ids endpoints list --project=$PROJECT_ID | grep STATE

#Identify the Cloud IDS endpoint forwarding rule and confirm that the Cloud IDS endpoint state is READY:
export FORWARDING_RULE=$(gcloud ids endpoints describe cloud-ids-east1 --zone=us-east1-b --format="value(endpointForwardingRule)")
echo $FORWARDING_RULE

#Create and attach the packet mirroring policy:
gcloud compute packet-mirrorings create cloud-ids-packet-mirroring \
--region=us-east1 \
--collector-ilb=$FORWARDING_RULE \
--network=cloud-ids \
--mirrored-subnets=cloud-ids-useast1

#Verify that the packet mirroring policy is created:
gcloud compute packet-mirrorings list






#Task 7. Simulate attack traffic
#Task 8. Review threats detected by Cloud IDS



