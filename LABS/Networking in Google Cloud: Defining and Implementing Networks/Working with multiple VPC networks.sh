#!/bin/bash
set -euxo pipefail #Bash Strict Mode

#Run the following command to create the privatenet network:
#gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-us \
--network=privatenet \
--region=us-east1 \
--range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-eu \
--network=privatenet \
--region=europe-west4 \
--range=172.20.0.0/20

#gcloud compute networks list
gcloud compute networks create managementnet \
--project=qwiklabs-gcp-04-cd4fdf314915 \
--subnet-mode=custom \
--mtu=1460 \
--bgp-routing-mode=regional


gcloud compute networks subnets create managementsubnet-us \
--project=qwiklabs-gcp-04-cd4fdf314915 \
--range=10.130.0.0/20 \
--stack-type=IPV4_ONLY \
--network=managementnet \
--region=us-east1


gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
--direction=INGRESS \
--priority=1000 \
--network=managementnet \
--action=ALLOW \
--rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0


gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
--direction=INGRESS \
--priority=1000 \
--network=privatenet \
--action=ALLOW \
--rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0


gcloud compute firewall-rules list --sort-by=NETWORK


#Task 2. Create VM instances

gcloud compute instances create managementnet-us-vm \
--zone=us-east1-c \
--machine-type=e2-medium \
--subnet=privatesubnet-us \
--network=managementnet \
--subnet=managementsubnet-us

gcloud compute instances create privatenet-us-vm \
--zone=us-east1-c \
--machine-type=e2-medium \
--subnet=privatesubnet-us


gcloud compute instances list --sort-by=ZONE


# Replace these with actual IP addresses or domain names
machines=("10.142.0.2" "172.16.0.2" "10.164.0.2" "10.130.0.2")

# Number of pings per machine
num_pings=5

# Loop through each machine and ping it
for machine in "${machines[@]}"; do
    echo "Pinging $machine..."
    ping -c "$num_pings" "$machine"
    echo  # Add an empty line for readability
done